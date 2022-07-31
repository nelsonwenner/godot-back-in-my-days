extends Control

onready var Connect_error_label = get_node("Connect/ErrorLabel")
onready var Players_start = get_node("Players/Start")
onready var Players_server_code = get_node("Players/ServerCode")
onready var Connect_nickname_host = get_node("Connect/NickNameHost")
onready var Connect_nickname_join = get_node("Connect/NickNameJoin")
onready var Connect_server_code = get_node("Connect/ServerCode")
onready var Players_list = get_node("Players/List")
onready var Connect_host = get_node("Connect/Host")
onready var Connect_join = get_node("Connect/Join")
onready var Connect_submit_host = get_node("Connect/SubmitHost")
onready var Connect_submit_join = get_node("Connect/SubmitJoin")
onready var Error_dialog = get_node("ErrorDialog")
onready var Players = get_node("Players")
onready var Connect = get_node("Connect")

func _ready():
	Server.connect("connection_succeeded", self, "_on_connection_success")
	Server.connect("player_list_changed", self, "refresh_list_players")
	Server.connect("game_error", self, "_on_game_error")
	Server.connect("game_ended", self, "_on_game_ended")

func _on_Host_pressed():
	Connect_host.hide()
	Connect_join.hide()
	Connect_nickname_host.show()
	Connect_submit_host.show()

func _on_Join_pressed():
	Connect_host.hide()
	Connect_join.hide()
	Connect_nickname_join.show()
	Connect_server_code.show()
	Connect_submit_join.show()

func _on_Submit_Host_pressed():
	if Connect_nickname_host.text == "":
		Connect_error_label.text = "Invalid name!"
		return

	Connect.hide()
	Players.show()
	Server.generate_server_unique_code()
	Players_server_code.text = Server.get_server_code()
	Connect_error_label.text = ""

	var player_name = Connect_nickname_host.text
	Server.create_server(player_name)
	refresh_list_players()

func _on_Submit_Join_pressed():
	if Connect_nickname_join.text == "" && Connect_server_code.text == "":
		Connect_error_label.text = "Fields cannot be empty!"
		return

	Connect_error_label.text = ""
	Connect_host.disabled = true
	Connect_join.disabled = true

	var player_name = Connect_nickname_join.text
	var server_code = Connect_server_code.text
	Server.connect_to_server(player_name, server_code)

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

func refresh_list_players():
	var players = Server.get_player_list()
	players.sort()
	Players_list.clear()
	Players_list.add_item(Server.get_player_name())
	for player in players:
		Players_list.add_item(player)
	Players_start.disabled = not get_tree().is_network_server()
