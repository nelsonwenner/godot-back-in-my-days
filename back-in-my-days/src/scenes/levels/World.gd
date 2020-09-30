extends Node2D


func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var player = load("res://src/scenes/player/Player.tscn")
	
	var new_player = player.instance()
	
	new_player.set_name(str(get_tree().get_network_unique_id()))
	new_player.set_network_master(get_tree().get_network_unique_id())
	get_node("Players").add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, info.hunter)
	

func _on_player_disconnected(id):
	get_tree().current_scene.get_node("/root/World/Players/" + str(id)).queue_free()
