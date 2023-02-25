extends Window


signal jump


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") or event.is_action_pressed("ui_accept"):
		jump.emit()
