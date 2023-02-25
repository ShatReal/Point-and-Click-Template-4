extends PopupPanel


const PATH := "user://options.ini"
const MAX_VSYNC := 4
const KEYBINDS := [
	"inventory",
]

@export var Keybind: PackedScene

var config_file: ConfigFile
var current_event: InputEvent
var current_keybind: VBoxContainer
var default_keybinds := {}


func _ready() -> void:
	hide()
	$Press.hide()
	
	for keybind in KEYBINDS:
		default_keybinds[keybind] = InputMap.action_get_events(keybind)

	config_file = ConfigFile.new()
	if config_file.load(PATH) == OK:
		var fullscreen_value = config_file.get_value("visual", "fullscreen", false)
		if fullscreen_value is bool:
			if fullscreen_value:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			%Fullscreen.button_pressed = fullscreen_value
		var vsync_value = config_file.get_value("visual", "vsync", 1)
		if vsync_value is int and vsync_value in range(MAX_VSYNC):
			DisplayServer.window_set_vsync_mode(vsync_value)
			%Vsync.selected = vsync_value
		var music_value = config_file.get_value("audio", "music", 1.0)
		if music_value is float and music_value >= 0.0 and music_value <= 1.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_value))
			%Music.value = music_value
		var sound_value = config_file.get_value("audio", "sound", 1.0)
		if sound_value is float and sound_value >= 0.0 and sound_value <= 1.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(sound_value))
			%Sound.value = sound_value
		var keybinds = config_file.get_value("keybinds", "keybinds", {})
		if keybinds is Dictionary and keybinds.has_all(KEYBINDS):
			for keybind in KEYBINDS:
				InputMap.action_erase_events(keybind)
				for event in keybinds[keybind]:
					InputMap.action_add_event(keybind, event)
	
	for keybind in KEYBINDS:
		var k := Keybind.instantiate()
		k.init(keybind)
		$ScrollContainer/VBoxContainer.add_child(k)
		k.event_requested.connect(on_action_event_requested)
		k.event_deleted.connect(write_keybinds)
	

func show_settings(show_title := false) -> void:
	$ScrollContainer/VBoxContainer/Title.visible = show_title
	popup_centered()


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	config_file.set_value("visual", "fullscreen", button_pressed)
	config_file.save(PATH)
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)


func _on_vsync_item_selected(index: int) -> void:
	config_file.set_value("visual", "vsync", index)
	config_file.save(PATH)
	DisplayServer.window_set_vsync_mode(index)


func _on_music_value_changed(value: float) -> void:
	config_file.set_value("audio", "music", value)
	config_file.save(PATH)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_sound_value_changed(value: float) -> void:
	config_file.set_value("audio", "sound", value)
	config_file.save(PATH)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(value))


func _on_reset_pressed() -> void:
	config_file.set_value("visual", "fullscreen", false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	%Fullscreen.button_pressed = false
	
	config_file.set_value("visual", "vsync", 1)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	%Vsync.selected = 1
	
	config_file.set_value("audio", "music", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(1.0))
	%Music.value = 1.0

	config_file.set_value("audio", "sound", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(1.0))
	%Sound.value = 1.0
	
	config_file.set_value("keybinds", "keybinds", default_keybinds)
	for keybind in KEYBINDS:
		InputMap.action_erase_events(keybind)
		for event in default_keybinds[keybind]:
			InputMap.action_add_event(keybind, event)
	for keybind_node in get_tree().get_nodes_in_group("keybinds"):
		keybind_node.queue_free()
	for keybind in KEYBINDS:
		var k := Keybind.instantiate()
		k.init(keybind)
		$ScrollContainer/VBoxContainer.add_child(k)
		k.event_requested.connect(on_action_event_requested)
		k.event_deleted.connect(write_keybinds)
	
	config_file.save(PATH)


func on_action_event_requested(k: VBoxContainer) -> void:
	current_event = null
	$Press.dialog_text = "[Press any button!]"
	$Press.popup_centered()
	current_keybind = k
	

func _on_press_confirmed() -> void:
	$Press.hide()
	if current_event == null:
		return
	current_keybind.add_event(current_event)
	write_keybinds()


func write_keybinds() -> void:
	var dict := {}
	for keybind in KEYBINDS:
		dict[keybind] = InputMap.action_get_events(keybind)
	config_file.set_value("keybinds", "keybinds", dict)
	config_file.save(PATH)


func _on_press_event_selected(event) -> void:
	$Press.dialog_text = event.as_text()
	current_event = event


func _on_title_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/meta/title.tscn")
