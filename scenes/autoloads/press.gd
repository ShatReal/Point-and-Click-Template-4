extends AcceptDialog


signal event_selected(event: InputEvent)


func _unhandled_key_input(event: InputEvent) -> void:
	event_selected.emit(event)
	
	
func _on_visibility_changed() -> void:
	set_process_unhandled_key_input(visible)
	if visible and gui_get_focus_owner():
		gui_get_focus_owner().release_focus()
