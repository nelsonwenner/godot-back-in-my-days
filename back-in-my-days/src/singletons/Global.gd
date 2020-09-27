extends Node

onready var player = preload("res://src/scenes/player/Player.tscn")
onready var world = get_tree().current_scene.get_node("World")


func _ready():
	randomize()
	get_tree().multiplayer.connect("network_peer_connected", self, "_player_connected")
	get_tree().multiplayer.connect("network_peer_disconnected", self, "_player_disconnected")


func runGame(id):
	var player_instance = player.instance()
	player_instance .name = str(id)
	player_instance .set_network_master(id)
	world.add_child(player_instance)


func _player_connected(id):
	if id > 1: rpc_id(id, "register_player")
	
	
func _player_disconnected(id):
	if id > 1 and id != multiplayer.get_network_unique_id():
		world.get_node_or_null(str(id)).queue_free()
	

remote func register_player():
	var id = get_tree().get_rpc_sender_id()
	var new_player = player.instance()
	new_player.set_name(str(id))
	new_player.set_network_master(id)
	world.add_child(new_player)
