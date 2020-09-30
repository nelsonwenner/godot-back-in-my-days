extends Area2D


func _on_Detection_body_entered(_body):
	if not _body.is_in_group('players'): return
	if is_network_master():
		var id = int(_body.name)
		if (id > 1) and (not _body.is_hunter(id)):
			_body.rpc("picke")
		if id == 1 and Network.players[id].position != Vector2(360, 180):
			if not _body.is_hunter(id):
				_body.rpc("picke")


func _on_Detection_body_exited(_body):
	_body.rpc("despicke")
