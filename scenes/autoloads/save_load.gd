extends PopupPanel


const PATH := "user://saves/"
const ENDING := ".ini"

@export var SaveSlot: PackedScene

var saves := []
var save_num := 0


func _ready() -> void:
	hide()
	if not DirAccess.dir_exists_absolute(PATH):
		DirAccess.make_dir_absolute(PATH)
		return
	var dir := DirAccess.open(PATH)
	dir.list_dir_begin()
	var file := dir.get_next()
	while file:
		saves.append(file)
		file = dir.get_next()
	dir.list_dir_end()
	saves.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) > 0)
	if saves.size() > 0:
		save_num = int(saves[0].replace(ENDING, "")) + 1
	var i := 0
	while i < saves.size():
		var config := ConfigFile.new()
		if config.load(PATH + saves[i]) == OK:
			var date = config.get_value("metadata", "time", {})
			if date is Dictionary and date.has_all(["year", "month", "day", "hour", "minute", "second"]):
				var s := SaveSlot.instantiate()
				%Slots.add_child(s)
				s.init(date)
				s.overwrite.connect(on_slot_overwrite)
				s.load_requested.connect(on_slot_load, CONNECT_DEFERRED)
				s.delete.connect(on_slot_delete)
				i += 1
			else:
				push_warning("Invalid date for save file %s!" % (PATH + saves[i]))
				saves.remove_at(i)
		else:
			saves.remove_at(i)
	
	
func show_save_load(can_save := false) -> void:
	for slot in %Slots.get_children():
		slot.toggle_overwrite(can_save)
	%New.disabled = not can_save
	popup_centered()


func _on_new_pressed() -> void:
	var s := SaveSlot.instantiate()
	%Slots.add_child(s)
	%Slots.move_child(s, 0)
	var date := Time.get_datetime_dict_from_system()
	s.init(date)
	s.overwrite.connect(on_slot_overwrite)
	s.load_requested.connect(on_slot_load, CONNECT_DEFERRED)
	s.delete.connect(on_slot_delete)
	saves.push_front(str(save_num) + ENDING)
	save(PATH + str(save_num) + ENDING, date)
	save_num += 1


func save(path: String, date: Dictionary) -> void:
	var config := ConfigFile.new()
	config.set_value("metadata", "time", date)
	config.set_value("data", "rooms_state", GameState.rooms_state)
	config.set_value("data", "current_scene", get_tree().current_scene.scene_file_path)
	var inventory: Array[String] = []
	for item in UI.items:
		inventory.append(item.resource_path)
	config.set_value("data", "inventory", inventory)
	config.set_value("data", "selected_item", UI.selected_item)
	config.save(path)


func _on_delete_all_pressed() -> void:
	for child in %Slots.get_children():
		child.queue_free()
	for s in saves:
		DirAccess.remove_absolute(PATH + s)
	saves = []
	save_num = 0


func on_slot_overwrite(i: int) -> void:
	var path: String = saves.pop_at(i)
	saves.push_front(path)
	%Slots.move_child(%Slots.get_child(i), 0)
	var date := Time.get_datetime_dict_from_system()
	%Slots.get_child(0).init(date)
	save(PATH + saves[0], date)


func on_slot_load(i: int) -> void:
	if not validate_save(PATH + saves[i]):
		saves.remove_at(i)
		%Slots.get_child(i).queue_free()
		$AcceptDialog.show()
		return
	hide()
	UI.clear()
	var config := ConfigFile.new()
	config.load(PATH + saves[i])
	GameState.rooms_state = config.get_value("data", "rooms_state")
	for item in config.get_value("data", "inventory"):
		UI.add_item(load(item))
	UI.select_item(config.get_value("data", "selected_item"))
	var current_scene: String = config.get_value("data", "current_scene")
	get_tree().change_scene_to_file(current_scene)


func on_slot_delete(i: int) -> void:
	DirAccess.remove_absolute(PATH + saves[i])
	saves.remove_at(i)
	%Slots.get_child(i).queue_free()


func validate_save(path: String) -> bool:
	var config := ConfigFile.new()
	if not config.load(path) == OK:
		push_warning("Could not load file at %s!" % path)
		return false
	var rooms_state = config.get_value("data", "rooms_state")
	if not rooms_state is Dictionary:
		push_warning('"rooms_state" is not a Dictionary for save at %s!' % path)
		return false
	var inventory = config.get_value("data", "inventory")
	if not inventory is Array[String]:
		push_warning('"inventory" is not an Array for save at %s!' % path)
		return false
	for p in inventory:
		if not ResourceLoader.exists(p, "Item"):
			push_warning('Path %s in "inventory" does not exist for save at %s!' % [p, path])
			return false
	var selected_item = config.get_value("data", "selected_item")
	if not selected_item is int or selected_item < -2 or selected_item > inventory.size() - 1:
		push_warning('"selected_item" has invalid data for save at %s!' % path)
	var current_scene = config.get_value("data", "current_scene")
	if not current_scene is String or not ResourceLoader.exists(current_scene, "PackedScene"):
		push_warning('"current_scene" has invalid data for save at %s!' % path)
	return true
