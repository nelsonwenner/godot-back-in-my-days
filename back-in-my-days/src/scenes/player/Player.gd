extends KinematicBody2D

var SPEED = 200

enum MoveDirection { UP, DOWN, LEFT, RIGHT, REST }

var animated_sprite: AnimatedSprite
puppet var puppet_position = Vector2()
puppet var puppet_motion = MoveDirection.REST

var visibility_control_slave = false
var hunter = false
var picked = false

func init(nickname, start_position, is_hunter):
	global_position = start_position
	hunter = is_hunter
	
	if is_hunter:
		var animated_male = get_node("AnimatedMale")
		animated_male.visible = true
		animated_sprite = animated_male
		SPEED = 250
	else:
		var animated_female = get_node("AnimatedFemale")
		animated_female.visible = true
		animated_sprite = animated_female


func _physics_process(_delta):
	var direction = MoveDirection.REST
	
	if is_network_master():
		if Input.is_action_pressed("player_up"):
			direction = MoveDirection.UP
		elif Input.is_action_pressed("player_down"):
			direction = MoveDirection.DOWN
		elif Input.is_action_pressed("player_right"):
			direction = MoveDirection.RIGHT
		elif Input.is_action_pressed("player_left"):
			direction = MoveDirection.LEFT

		rset_unreliable("puppet_position", position)
		rset("puppet_motion", direction)
		_move(direction)
	else:
		_move(puppet_motion)
		position = puppet_position
	
	if (not is_network_master()) and (not visibility_control_slave) and (not hunter):
		"""
		If it is not a network master, it will leave the 
		slave invisible for 60 seconds.
		"""
		get_node(".").visible = false
		yield(get_tree().create_timer(10), "timeout")
		get_node(".").visible = true
		visibility_control_slave = true
	
	
func _move(direction):
	match direction:
		MoveDirection.REST:
			animated_sprite.play("rest")
		MoveDirection.UP:
			move_and_slide(Vector2(0, -SPEED))
			_anime_move()
		MoveDirection.DOWN:
			move_and_slide(Vector2(0, SPEED))
			_anime_move()
		MoveDirection.LEFT:
			move_and_slide(Vector2(-SPEED, 0))
			_anime_left()
		MoveDirection.RIGHT:
			move_and_slide(Vector2(SPEED, 0))
			_anime_right()


puppet func puppet_gotchar():
	"""
	Usado para atualizar os seus fantachos no jogo,
	no caso os clientes.
	"""
	picked = true
	get_node("Ballon").visible = true


puppet func puppet_desgotchar():
	picked = false
	get_node("Ballon").visible = false
	

master func master_gotchar():
	"""
	Usado para poder atualizar seu proprio contexto,
	e podendo avisar para os escravos, sua atualizações,
	apenas o mestre da rede, executa essa função.
	"""
	if picked: return
	rpc("puppet_gotchar") # sincroniza com os escravos, para que eles poção ver a msg, gotchar também!
	puppet_gotchar() # mestre da rede, dando updade na sua propria variavel, e pondo a msg gotchar!.
	

master func master_desgotchar():
	rpc("puppet_desgotchar")
	puppet_desgotchar()


remote func restart(pos):
	rpc("master_desgotchar")
	
	global_position = pos
	
	if picked == true and hunter ==  false:
		hunter = true
		SPEED = 250
		
	if picked == false and hunter == true:
		visibility_control_slave = false
		hunter = false
		SPEED = 200
		
		
func _anime_right():
	animated_sprite.play("move")
	animated_sprite.flip_h = false

	
func _anime_left():
	animated_sprite.play("move")
	animated_sprite.flip_h = true


func _anime_move():
	animated_sprite.play("move")
	
	
func is_hunter():
	return self.hunter
	

func _on_RestartGame_timeout():
	if get_tree().is_network_server():
		print("Restart game!!!")
		var world = get_tree().get_root().get_node("/root/World/")
		
		var spawn_points = {}
		var spawn_point_idx = 0
		
		for peer in multiplayer.get_network_connected_peers():
			if peer > 1:
				spawn_points[peer] = spawn_point_idx
				spawn_point_idx += 1
		
		for player_id in spawn_points:
			var spawn_position = world.get_node("SpawnPoints/" + str(spawn_points[player_id])).position
			rpc_id(player_id, "restart", spawn_position)
		restart(Vector2(2898.67, 777.252)) # update servidor position
