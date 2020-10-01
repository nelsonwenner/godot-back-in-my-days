extends KinematicBody2D

var SPEED = 200

enum MoveDirection { UP, DOWN, LEFT, RIGHT, REST }

var animated_sprite: AnimatedSprite
puppet var puppet_position = Vector2()
puppet var puppet_motion = MoveDirection.REST
puppet var picked = false

var visibility_control_slave = false
var hunter = false

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
	
	if (not is_network_master()) and (not visibility_control_slave) and (not self.hunter):
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


sync func gotchar():
	if picked: return
	picked = true
	get_node("Ballon").visible = true
	

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
	

func change_hunter(id, value):
	self.hunter = value
