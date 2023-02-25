extends Control


func _ready() -> void:
	UI.toggle_ui(false)
	Audio.play_music("res://music/puzzles.ogg")


func _on_start_pressed() -> void:
	GameState.rooms_state = {}
	UI.items = []
	UI.selected_item = -1
	UI.call_deferred("clear")
	get_tree().change_scene_to_file("res://scenes/rooms/room_0.tscn")


func _on_load_pressed() -> void:
	SaveLoad.show_save_load()


func _on_settings_pressed() -> void:
	Settings.show_settings()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/meta/credits.tscn")


func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/meta/help.tscn")
	
