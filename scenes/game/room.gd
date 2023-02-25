extends Node2D
class_name Room


const PICKUP_SOUND_PATH := "res://sounds/pickup.wav"
@export_file("*.ogg", "*.wav", "*.mp3") var music_path: String

var current_actions: Array[Action]


func _ready() -> void:
	if music_path:
		Audio.play_music(music_path)
	UI.toggle_ui(true)
	for interactable in $Interactables.get_children():
		interactable.interacted.connect(on_interactable_interacted)
		interactable.interacted_with_item.connect(on_interactable_interacted_with_item)
	if GameState.rooms_state.has(scene_file_path):
		for interactable in $Interactables.get_children():
			if not GameState.rooms_state[scene_file_path].has(interactable.id):
				GameState.rooms_state[scene_file_path][interactable.id] = {}
				GameState.rooms_state[scene_file_path][interactable.id].times_interacted = interactable.times_interacted
				GameState.rooms_state[scene_file_path][interactable.id].visible = interactable.visible
			else:
				for key in GameState.ROOMS_STATE_KEYS:
					if GameState.rooms_state[scene_file_path][interactable.id].has(key):
						interactable.set(key, GameState.rooms_state[scene_file_path][interactable.id][key])
					else:
						GameState.rooms_state[scene_file_path][interactable.id][key] = interactable.get(key)
	else:
		GameState.rooms_state[scene_file_path] = {}
		for interactable in $Interactables.get_children():
			GameState.rooms_state[scene_file_path][interactable.id] = {}
			GameState.rooms_state[scene_file_path][interactable.id].times_interacted = interactable.times_interacted
			GameState.rooms_state[scene_file_path][interactable.id].visible = interactable.visible
	UI.dialogue_finished.connect(advance_actions)


func on_interactable_interacted(actions: Array[Action], id: int, times_interacted: int) -> void:
	GameState.rooms_state[scene_file_path][id].times_interacted = times_interacted
	current_actions = actions.duplicate()
	call_deferred("advance_actions")


func advance_actions() -> void:
	if current_actions.size() == 0:
		return
	var action: Action = current_actions.pop_front()
	if action is AddItemAction:
		Audio.play_sound(PICKUP_SOUND_PATH)
		UI.add_item(action.item)
		UI.deselect_item()
		advance_actions()
	elif action is ChangeSceneAction:
		UI.deselect_item()
		get_tree().change_scene_to_file(action.new_scene)
		if current_actions.size() > 0:
			push_error("Additional actions cannot be carried out after scene change!")
	elif action is DialogueAction:
		UI.show_dialogue(action.dialogue)
	elif action is ToggleInteractableAction:
		UI.deselect_item()
		if action.scene_path:
			GameState.set_rooms_state(action.scene_path, action.target_id, "visible", action.show)
			advance_actions()
		else:
			for interactable in $Interactables.get_children():
				if interactable.id == action.target_id:
					interactable.visible = action.show
					GameState.set_rooms_state(scene_file_path, action.target_id, "visible", action.show)
					advance_actions()
					return
			push_warning("ID %s not found in %s!" % [action.target_id, scene_file_path])
			GameState.set_rooms_state(scene_file_path, action.target_id, "visible", action.show)
	elif action is RemoveItemAction:
		UI.deselect_item()
		UI.remove_item(action.target_id)
		advance_actions()
	elif action is PlaySoundAction:
		Audio.play_sound(action.sound_path)
		advance_actions()


func on_interactable_interacted_with_item(id: int) -> void:
	var actions = UI.items[UI.selected_item].get_combination_from_id(id)
	if actions:
		current_actions = actions.duplicate()
	else:
		current_actions = GameState.FALLBACK_COMBINATION.actions.duplicate()
	call_deferred("advance_actions")
