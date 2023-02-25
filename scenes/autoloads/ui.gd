extends CanvasLayer


signal dialogue_finished

const TOGGLE_TIME := 0.2

@export var ItemIcon: PackedScene

var inventory_visible := true
var current_dialogue: Array[DialogueLine]
var dialogue_index := -1
var items: Array[Item] = []
var selected_item := -1

@onready var control := $Control
@onready var right := $Control/Right
@onready var toggle := $Control/Right/Toggle
@onready var inventory_vbox := $Control/Right/Inventory/Scroll/VBox
@onready var dialogue := $Control/Dialogue
@onready var portrait := $Control/Dialogue/HBox/Portrait
@onready var title := $Control/Dialogue/HBox/VBox/Title
@onready var speech := $Control/Dialogue/HBox/VBox/Speech
@onready var speech_timer := $Control/Dialogue/HBox/VBox/Speech/SpeechTimer
@onready var settings := $Control/TopLeft/Settings
@onready var save_load := $Control/TopLeft/SaveLoad


func _ready() -> void:
	dialogue.hide()
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_on_toggle_pressed()
	elif event.is_action_pressed("ui_accept") and dialogue.visible:
		jump_dialogue()


func _on_toggle_pressed() -> void:
	inventory_visible = not inventory_visible
	var tween := get_tree().create_tween()
	if inventory_visible:
		tween.tween_property(right, "position:x", control.size.x - right.size.x, TOGGLE_TIME)
		toggle.text = ">"
	else:
		tween.tween_property(right, "position:x", control.size.x - toggle.size.x, TOGGLE_TIME)
		toggle.text = "<"


func add_item(item: Item) -> void:
	items.append(item)
	var item_icon := ItemIcon.instantiate()
	inventory_vbox.add_child(item_icon)
	item_icon.set_data(item)
	item_icon.item_selected.connect(on_item_selected)


func show_dialogue(d: Array[DialogueLine]) -> void:
	settings.disabled = true
	save_load.disabled = true
	dialogue.show()
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	current_dialogue = d
	dialogue_index = -1
	advance_dialogue()
	

func advance_dialogue() -> void:
	dialogue_index += 1
	if dialogue_index >= current_dialogue.size():
		settings.disabled = false
		save_load.disabled = false
		dialogue.hide()
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dialogue_finished.emit()
		return
	var line := current_dialogue[dialogue_index]
	if line.portrait:
		portrait.texture = line.portrait
	if line.title:
		title.text = line.title
	speech.text = line.speech
	speech.visible_ratio = 0
	speech_timer.start()


func _on_speech_timer_timeout() -> void:
	speech.visible_characters += 1
	if not speech.visible_ratio == 1.0:
		speech_timer.start()


func jump_dialogue() -> void:
	if speech.visible_ratio == 1.0:
		advance_dialogue()
	else:
		speech_timer.stop()
		speech.visible_ratio = 1.0


func _on_control_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and dialogue.visible:
		jump_dialogue()


func on_item_selected(index: int) -> void:
	selected_item = index


func remove_item(target_id: int) -> void:
	for i in items.size():
		if items[i].id == target_id:
			items.remove_at(i)
			inventory_vbox.get_child(i).queue_free()
			if i == selected_item:
				selected_item = -1
			return
	push_warning("Couldn't find item with id %s in inventory to remove!" % target_id)


func deselect_item() -> void:
	if selected_item == -1:
		return
	inventory_vbox.get_child(selected_item).toggle_selected(false)
	selected_item = -1


func toggle_ui(enable: bool) -> void:
	control.visible = enable


func _on_save_load_pressed() -> void:
	SaveLoad.show_save_load(true)


# Will be called deferred, that's why I'm using free instead of queue_free
func clear() -> void:
	for child in inventory_vbox.get_children():
		child.free()
	items = []
	

func select_item(index: int) -> void:
	inventory_vbox.get_child(index).toggle_selected(true)


func _on_settings_pressed() -> void:
	Settings.show_settings(true)
