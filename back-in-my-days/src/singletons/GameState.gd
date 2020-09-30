extends Node

const DEFAULT_PORT = 10567
const MAX_PEERS = 12

var players = { }
var self_data = { name = '', position = Vector2(0,0) }

var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell 
	#the connected player that we are here.
	rpc_id(id, "register_player")


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Main management functions.
remote func register_player():
	var id = get_tree().get_rpc_sender_id()
	players[id] = self_data
	emit_signal("player_list_changed")


func create_server(player_name):
	self_data.name = player_name
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	

func connect_to_server(ip, new_player_name):
	self_data.name = new_player_name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func get_player_list():
	return players.values()


func get_player_name():
	return players[1].name
	

func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")
	

func begin_game():
	assert(get_tree().is_network_server())
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for player_id in players:
		rpc_id(player_id, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)


remote func pre_start_game(spawn_points):
	var world = load("res://src/scenes/levels/World.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Main").hide()

	var player_scene = load("res://src/scenes/player/Player.tscn")

	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()
		
		player.set_name(str(p_id))
		player.position=spawn_pos
		player.set_network_master(p_id)
		
		player.set_player_name(players[p_id].name)

		world.get_node("Players").add_child(player)

	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false)


remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	
	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()
		
		
func update_position(id, position):
	players[id].position = position
