extends Control

onready var Connect_error_label = get_node("Connect/ErrorLabel")
onready var Connect_ip = get_node("Connect/IPAddress")
onready var Players_start = get_node("Players/Start")
onready var Connect_name = get_node("Connect/Name")
onready var Players_list = get_node("Players/List")
onready var Connect_host = get_node("Connect/Host")
onready var Connect_join = get_node("Connect/Join")
onready var Error_dialog = get_node("ErrorDialog")
onready var Players = get_node("Players")
onready var Connect = get_node("Connect")


func _ready():
	Server.connect("connection_succeeded", self, "_on_connection_success")
	Server.connect("player_list_changed", self, "refresh_list_players")
	Server.connect("game_error", self, "_on_game_error")
	Server.connect("game_ended", self, "_on_game_ended")


func _on_Host_pressed():
	if Connect_name.text == "":
		Connect_error_label.text = "Invalid name!"
		return
	
	Connect.hide()
	Players.show()
	Connect_error_label.text = ""
	
	var player_name = Connect_name.text
	Server.create_server(player_name)
	refresh_list_players()
	

func refresh_list_players():
	var players = Server.get_player_list()
	players.sort()
	Players_list.clear()
	Players_list.add_item(Server.get_player_name() + " (You)")
	for player in players:
		Players_list.add_item(player)
	Players_start.disabled = not get_tree().is_network_server()


func _on_Join_pressed():
	if Connect_name.text == "":
		Connect_error_label.text = "Invalid name!"
		return

	Connect_error_label.text = ""
	Connect_host.disabled = true
	Connect_join.disabled = true

	var player_name = Connect_name.text
	Server.connect_to_server(player_name)


func _on_game_ended():
	show()
	Connect.show()
	Players.hide()
	Connect_host.disabled = false
	Connect_join.disabled = false


func _on_game_error(errtxt):
	Error_dialog.dialog_text = errtxt
	Error_dialog.popup_centered_minsize()
	Connect_host.disabled = false
	Connect_join.disabled = false


func _on_connection_success():
	Connect.hide()
	Players.show()


func _on_Start_pressed():
	Server.begin_game()
