extends VBoxContainer


signal event_requested(this: VBoxContainer)
signal event_deleted

@export var KeybindAction: PackedScene

var action: String


func init(a: String) -> void:
	action = a
	$HBoxContainer/Label.text = action
	for event in InputMap.action_get_events(action):
		var k := KeybindAction.instantiate()
		k.init(event)
		add_child(k)
		k.deleted.connect(on_event_deleted)


func on_event_deleted(event: InputEvent) -> void:
	InputMap.action_erase_event(action, event)
	event_deleted.emit()


func _on_add_pressed() -> void:
	event_requested.emit(self)
	

func add_event(event: InputEvent) -> void:
	var k := KeybindAction.instantiate()
	k.init(event)
	add_child(k)
	k.deleted.connect(on_event_deleted)
	InputMap.action_add_event(action, event)
