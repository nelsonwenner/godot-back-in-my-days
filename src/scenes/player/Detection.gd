extends Area2D


func _on_Detection_body_entered(_body):
	if not _body.is_in_group('players'): return
	if is_network_master():
		_body.rpc("master_gotchar")
