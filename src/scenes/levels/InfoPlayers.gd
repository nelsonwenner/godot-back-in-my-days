extends Node2D

var players = {  }
	
	
func _process(_delta):
	var current_player = get_tree().get_network_unique_id()
	get_node("Nickname").text = players[current_player].name
	
	if current_player > 1:
		get_node("PlayerInfo").play("female")
	else:
		get_node("PlayerInfo").play("male")
	
	var player = get_node_or_null("../Players/" + str(current_player))
	
	if player:
		if player.hunter:
			get_node("Mode").play("hunter")
		else:
			get_node("Mode").play("runner")
	
	
func add_player(id, nickname):
	players[id] = {name= nickname}
