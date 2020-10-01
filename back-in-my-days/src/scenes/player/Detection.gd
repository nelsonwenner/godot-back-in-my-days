extends Area2D


func _on_Detection_body_entered(_body):
	if not _body.is_in_group('players'): return
	if is_network_master():
		var id = int(_body.name)
		if (id > 1) and (not _body.is_hunter()):
			_body.rpc("picke")
	
		
func _on_Detection_body_exited(_body):
	var id = int(_body.name)
	if (id > 1):
		_body.rpc("despicke")
