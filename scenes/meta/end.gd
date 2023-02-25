extends Control


func _ready() -> void:
	Audio.play_music("res://music/victory.ogg")
	UI.toggle_ui(false)


func _on_title_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/meta/title.tscn")
