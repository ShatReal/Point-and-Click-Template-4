extends Control


func _ready() -> void:
	UI.toggle_ui(false)


func _on_title_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/meta/title.tscn")
