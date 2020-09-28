extends Area2D


func _on_Detection_body_entered(_body):
	if is_network_master():
		if int(_body.name) > 1: # 1 peer server
			print("Pegueiiii => ", _body.get_node("Label").text)
