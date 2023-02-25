extends PanelContainer
class_name ItemIcon


signal item_selected(index: int)
signal combine_requested(index: int)

@onready var icon := $Icon
@onready var selected := $Selected


func _ready() -> void:
	selected.hide()


func set_data(item: Item) -> void:
	icon.texture_normal = item.icon
	icon.tooltip_text = "%s\n%s" % [item.name, item.description]


func toggle_selected(enable: bool) -> void:
	selected.visible = enable
	if enable:
		for other_item_icon in get_tree().get_nodes_in_group("item_icons"):
			if not other_item_icon == self:
				other_item_icon.toggle_selected(false)
		item_selected.emit(get_index())


func _on_icon_pressed() -> void:
	toggle_selected(not selected.visible)
	if not selected.visible:
		item_selected.emit(-1)


func _on_icon_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		if not selected.visible:
			combine_requested.emit(get_index())
