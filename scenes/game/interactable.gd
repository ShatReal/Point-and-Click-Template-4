extends TextureButton
class_name Interactable


signal interacted(actions: Array[Action], id:int, times_interacted: int)
signal interacted_with_item(id: int)

@export var id: int
@export var actions: Array[ActionGroup]
@export var times_interacted := -1


func _pressed() -> void:
	if UI.selected_item != -1:
		interacted_with_item.emit(id)
	else:
		times_interacted += 1
		interacted.emit(actions[min(times_interacted, actions.size() - 1)].actions, id, times_interacted)
