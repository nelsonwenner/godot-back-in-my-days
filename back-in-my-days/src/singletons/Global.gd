extends Node


func _ready():
	randomize()
	get_tree().multiplayer.connect("network_peer_connected", self, "_player_connected")
	get_tree().multiplayer.connect("network_peer_disconnected", self, "_player_disconnected")


func runGame(id):
	var player = preload("res://src/scenes/player/Player.tscn").instance()
	player.name = str(id)
	player.set_network_master(id)
	get_tree().current_scene.get_node("World").add_child(player)


func _player_connected(id):
	if id > 1: rpc_id(id, "register_player")
	
	
func _player_disconnected(id):
	if id > 1 and id != multiplayer.get_network_unique_id():
		get_tree().current_scene.get_node("World").get_node_or_null(str(id)).queue_free()
	

remote func register_player():
	var id = get_tree().get_rpc_sender_id()
	var new_player = preload("res://src/scenes/player/Player.tscn").instance()
	new_player.set_name(str(id))
	new_player.set_network_master(id)
	get_tree().current_scene.get_node("World").add_child(new_player)
