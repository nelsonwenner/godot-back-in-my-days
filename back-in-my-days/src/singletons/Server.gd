extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 10

var player_name = null

var players_ready = []
var players = { }

signal player_disconnected()
signal server_disconnected()
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func _player_connected(id):
	"""
	Listen to network_peer_connected, and call the
	register_player function sending the customer 
	data and the peer id to be registered. 
	"""
	rpc_id(id, "register_player", player_name)


remote func register_player(new_player):
	"""
	Register a new player, and register your
	datain the server.
	"""
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player
	emit_signal("player_list_changed")


func _on_player_disconnected(id):
	"""
	Game is in progress.
	"""
	if has_node("/root/World"):
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else:
		"""
		Game is not in progress.
		Unregister this player.
		"""
		unregister_player(id)
		
		
func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")
	

func create_server(player_nickname):
	"""
	Creates the server
	"""
	player_name = player_nickname
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)


func connect_to_server(player_nickname):
	"""
	starts the client connection, already 
	setting your nick name.
	"""
	player_name = player_nickname
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func _connected_ok():
	"""
	Callback from SceneTree, only 
	for clients (not server). We 
	just connected to a server
	""" 
	emit_signal("connection_succeeded")


func _server_disconnected():
	"""
	Callback from SceneTree, only 
	for clients (not server).
	"""
	emit_signal("game_error", "Server disconnected")
	end_game()


func begin_game():
	"""
	It is called only by the server, configures the
	players' spawn, and your own too, and then calls
	in the server logs the player recorder, and with
	their id send an rpc_id calling a pre_start_game
	function for each player, and send the spawn 
	points where that player can spawn.
	
	# Server in spawn point 0.
	"""
	assert(get_tree().is_network_server())
	
	var spawn_points = {}
	spawn_points[1] = 0 
	var spawn_point_idx = 1
	
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	
	for player_id in players:
		"""
		Call to pre-start game with the spawn points.
		"""
		rpc_id(player_id, "pre_start_game", spawn_points)
	pre_start_game(spawn_points)


remote func pre_start_game(spawn_points):
	"""
	Configure the world, player instances and 
	configure where the player will spawn and 
	add that player to the scene.
	"""
	var world = load("res://src/scenes/levels/World.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Main").hide()

	var player_scene = load("res://src/scenes/player/Player.tscn")
	
	for player_id in spawn_points:
		var spawn_position = world.get_node("SpawnPoints/" + str(spawn_points[player_id])).position
		var player = player_scene.instance()
		player.set_name(str(player_id))
		player.set_network_master(player_id)
		
		var nick_name = null
		
		if player_id == get_tree().get_network_unique_id():
			nick_name = player_name
		else:
			nick_name = players[player_id]
		
		player.init(
			nick_name,
			spawn_position,
			true if player_id == 1 else false
		)

		world.get_node("Players").add_child(player)
		
	if not get_tree().is_network_server():
		"""
		if not the server, send a remote call to it, sending your id 
		to be able to call the function on the ready_to_start server 
		to be able to initialize the game for players.
		"""
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		"""
		if you’ve already read all the players to start the game, 
		it will pause the game,and the game will boot to all
		"""
		post_start_game()


remote func ready_to_start(id):
	"""
	Read all registered player, and send an rpc_id
	for each player belonging to that id, to unspause
	the game, this function is only used by the server.
	"""
	assert(get_tree().is_network_server())
	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			"""
			calls the pos start game function for all 
			customers to unspause the game and start up.
			"""
			rpc_id(p, "post_start_game")
		post_start_game()


remote func post_start_game():
	"""
	Unpause the game for the current player.
	"""
	get_tree().set_pause(false)


func end_game():
	if has_node("/root/World"):
		get_node("/root/World").queue_free()
	emit_signal("game_ended")
	players.clear()


func get_player_list():
	return players.values()


func get_player_name():
	return player_name
