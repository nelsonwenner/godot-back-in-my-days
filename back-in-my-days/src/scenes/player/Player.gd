extends KinematicBody2D

var SPEED = 200

enum MoveDirection { UP, DOWN, LEFT, RIGHT, REST }

var animated_sprite: AnimatedSprite
puppet var puppet_position = Vector2()
puppet var puppet_motion = MoveDirection.REST

var visibility_control_slave = false

# synchronize this variable if it is updated
# for all connected clients and servers.
sync var hunter_picked_player = false

var hunter = false
var picked = false

var rng

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	

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
			return
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
	if hunter or picked: return
	picked = true
	var animated_gotcha = get_node("AnimatedGotcha")
	animated_gotcha.visible = true
	animated_gotcha.play("gotcha")


puppet func puppet_desgotchar():
	picked = false
	var animated_gotcha = get_node("AnimatedGotcha")
	animated_gotcha.visible = false
	animated_gotcha.stop()


master func master_gotchar():
	"""
	Usado para poder atualizar seu proprio contexto,
	e podendo avisar para os escravos, sua atualizações,
	apenas o mestre da rede, executa essa função.
	"""
	if picked: return
	rpc("puppet_gotchar") # synchronizes with the slaves, so that they can see the msg, gotchar too!
	puppet_gotchar() # master of the network, giving update on its own variable, and putting the msg gotchar!
	
	# update for all clients and servers, this variable.
	rset("hunter_picked_player", true)


master func master_desgotchar():
	rpc("puppet_desgotchar")
	puppet_desgotchar()


remote func restart(pos):
	visibility_control_slave = false
	
	if picked == true and hunter == false:
		hunter = true
		SPEED = 250
	
	if picked == false and hunter == true and hunter_picked_player:
		hunter = false
		SPEED = 200
	
	global_position = pos
	rpc("master_desgotchar")
	
	#update for all clients and servers, this variable.
	rset("hunter_picked_player", false) 
		
func _anime_right():
	animated_sprite.play("move")
	animated_sprite.flip_h = false

	
func _anime_left():
	animated_sprite.play("move")
	animated_sprite.flip_h = true


func _anime_move():
	animated_sprite.play("move")
	

func _on_RestartGame_timeout():
	if get_tree().is_network_server():
		var world = get_tree().get_root().get_node("/root/World/")
		
		for player_id in multiplayer.get_network_connected_peers():
			if player_id > 1:
				var random_spawn_point = rng.randi_range(0, 4) # position de Spawnpoints.
				var spawn_position = world.get_node("SpawnPoints/" + str(random_spawn_point)).position
				rpc_id(player_id, "restart", spawn_position)
		var random_spawn_point = rng.randi_range(5, 9)
		var spawn_position = world.get_node("SpawnPoints/" + str(random_spawn_point)).position
		restart(spawn_position) # update servidor position
