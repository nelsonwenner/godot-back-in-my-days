extends Control

onready var Connect = get_node("Connect")
onready var Connect_name = get_node("Connect/Name")
onready var Connect_error_label = get_node("Connect/ErrorLabel")
onready var Players = get_node("Players")
onready var Players_list = get_node("Players/List")
onready var Players_start = get_node("Players/Start")
onready var Connect_ip = get_node("Connect/IPAddress")
onready var Connect_host = get_node("Connect/Host")
onready var Connect_join = get_node("Connect/Join")


var _player_name = ""

func _on_Name_text_changed(new_text):
	_player_name = new_text

func _on_Host_pressed():
	if _player_name == "": return
	Network.create_server(_player_name)
	_load_game()

func _on_Join_pressed():
	if _player_name == "": return
	Network.connect_to_server(_player_name)
	_load_game()

func _load_game():
	get_tree().change_scene("res://src/scenes/levels/World.tscn")

"""
func _ready():
	GameState.connect("connection_succeeded", self, "_on_connection_success")
	GameState.connect("player_list_changed", self, "refresh_list_players")


func _on_Host_pressed():
	if Connect_name.text == "":
		Connect_error_label.text = "Invalid name!"
		return
	
	Connect.hide()
	Players.show()
	Connect_error_label.text = ""
	
	var player_name = Connect_name.text
	GameState.create_server(player_name)
	refresh_list_players()
	

func refresh_list_players():
	var players = GameState.get_player_list()
	players.sort()
	Players_list.clear()
	Players_list.add_item(GameState.get_player_name() + " (You)")
	for player in players: 
		if GameState.get_player_name() != player.name:
			Players_list.add_item(player.name)
	Players_start.disabled = not get_tree().is_network_server()


func _on_Join_pressed():
	if Connect_name.text == "":
		Connect_error_label.text = "Invalid name!"
		return

	var ip = Connect_ip.text
	if not ip.is_valid_ip_address():
		Connect_error_label.text = "Invalid IP address!"
		return

	Connect_error_label.text = ""
	Connect_host.disabled = true
	Connect_join.disabled = true

	var player_name = Connect_name.text
	GameState.connect_to_server(ip, player_name)


func _on_connection_success():
	Connect.hide()
	Players.show()


func _on_Start_pressed():
	GameState.begin_game()
"""

