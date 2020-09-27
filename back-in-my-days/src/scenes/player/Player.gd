extends KinematicBody2D

var SPEED = 200


func _ready():
	pass


func _process(_delta):
	var move = Vector2(0, 0)
	
	if is_network_master(): 
		if Input.is_action_pressed("player_up"):
			move.y = -1
		elif Input.is_action_pressed("player_down"):
			move.y = 1
		if Input.is_action_pressed("player_right"):
			move.x = 1
		elif Input.is_action_pressed("player_left"):
			move.x = -1
		
		for peer in multiplayer.get_network_connected_peers():
			if peer > 1:
				rpc_unreliable_id(peer, "setPosition", global_position)

	translate(move * SPEED * _delta)
	
	
puppet func setPosition(pos):
	global_position = pos
