extends Node
"""
var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909


func _ready():
	_connectToServer()


func _connectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_onConnectionSucceded")
	network.connect("connection_failed", self, "_onConnectionFailed")
	
	
func _onConnectionSucceded():
	Global.runGame(multiplayer.get_network_unique_id())
	print("Successfully connected!")


func _onConnectionFailed():
	print("Failed to connection!")
"""
