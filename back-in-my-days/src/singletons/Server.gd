extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909


func _ready():
	_connectToServer()


func _connectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_onConnectionFailed")
	network.connect("connection_succeeded", self, "_onConnectionSucceded")
	
	
func _onConnectionFailed():
	print("Failed to connection!")
	
	
func _onConnectionSucceded():
	print("Successfully connected!")
