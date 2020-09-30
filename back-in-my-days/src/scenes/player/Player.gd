extends KinematicBody2D

onready var animated_female = get_node("AnimatedFemale")
onready var animated_male = get_node("AnimatedMale")

var SPEED = 200

enum MoveDirection { UP, DOWN, LEFT, RIGHT, REST }

puppet var animated_sprite: AnimatedSprite
puppet var puppet_position = Vector2()
puppet var puppet_motion = MoveDirection.REST
puppet var picked = false
puppet var hunter = false


func init(nickname, start_position, is_hunter):
	get_node("Label").set_text(nickname)
	global_position = start_position
	hunter = is_hunter
	
	if is_hunter:
		animated_male.visible = true
		animated_sprite = animated_male
	else:
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
	
	if get_tree().is_network_server():
		Network.update_position(int(name), position)
		#print(Network.players)
		
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


func _anime_right():
	animated_sprite.play("move")
	animated_sprite.flip_h = false

	
func _anime_left():
	animated_sprite.play("move")
	animated_sprite.flip_h = true


func _anime_move():
	animated_sprite.play("move")
	

func is_hunter(id):
	return Network.players[id].hunter
	

func change_hunter(id, value):
	Network.players[id].hunter = value


sync func picke():
	picked = true
	get_node(".").visible = false
	

sync func despicke():
	picked = false
	get_node(".").visible = true

