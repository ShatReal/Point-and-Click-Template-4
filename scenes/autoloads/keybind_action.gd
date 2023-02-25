extends HBoxContainer


signal deleted(event: InputEvent)

var event: InputEvent


func init(e: InputEvent) -> void:
	$Label.text = e.as_text()
	event = e


func _on_delete_pressed() -> void:
	deleted.emit(event)
	queue_free()
