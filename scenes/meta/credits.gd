extends Control


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/meta/title.tscn")


func _on_rich_text_label_meta_clicked(meta) -> void:
	OS.shell_open(meta)
