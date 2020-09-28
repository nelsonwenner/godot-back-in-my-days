extends KinematicBody2D

var SPEED = 200

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()


func _ready():
	puppet_pos = position


func _physics_process(_delta):
	var motion = Vector2(0,0)
	
	if is_network_master(): 
		if Input.is_action_pressed("player_up"):
			motion.y -= SPEED
		elif Input.is_action_pressed("player_down"):
			motion.y += SPEED
		if Input.is_action_pressed("player_right"):
			motion.x += SPEED
		elif Input.is_action_pressed("player_left"):
			motion.x -= SPEED
		"""
		for peer in multiplayer.get_network_connected_peers():
			if peer > 1:
				rpc_unreliable_id(peer, "setPosition", global_position)
		"""
		
		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion
		
	motion = motion.normalized()
	motion = move_and_slide(motion * SPEED)
	
	if not is_network_master():
		puppet_pos = position
		
		
func set_player_name(new_name):
	get_node("Label").set_text(new_name)

"""
puppet func setPosition(pos):
	global_position = pos
"""
