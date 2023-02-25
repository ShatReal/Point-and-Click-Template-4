extends Node


func play_music(path: String) -> void:
	if $Music.stream and $Music.stream.resource_path == path:
		return
	$Music.stream = load(path)
	$Music.play()


func stop_music() -> void:
	$Music.stream = null


func play_sound(path: String) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.bus = "Sound"
	p.autoplay = true
	add_child(p)
	p.finished.connect(p.queue_free)
