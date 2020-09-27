extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909

var max_players = 100


func _ready():
	_startServer()


func _startServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("[X] Server started!")
	
	network.connect("peer_connected", self, "_peerConnected")
	network.connect("peer_disconnected", self, "_peerDisconnected")
	
	
func _peerConnected(player_id):
	print("User " + str(player_id) + " Connected")
	
	
func _peerDisconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
