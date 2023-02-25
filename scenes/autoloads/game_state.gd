extends Node


const FALLBACK_COMBINATION := preload("res://resources/fallback_combination.tres")
const ROOMS_STATE_KEYS := ["times_interacted", "visible"]

var rooms_state := {}


func set_rooms_state(scene_path: String, id: int, key: String, value) -> void:
	if not rooms_state.has(scene_path):
		rooms_state[scene_path] = {}
	if not rooms_state[scene_path].has(id):
		rooms_state[scene_path][id] = {}
	rooms_state[scene_path][id][key] = value
