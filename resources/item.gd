extends Resource
class_name Item


@export var id: int
@export var name: String
@export_multiline var description: String
@export var icon: Texture
@export var combinations: Array[Combination]
@export var default_combination: Array[Action]


func get_combination_from_id(other_id: int, target_inventory := false) -> Array[Action]:
	for combination in combinations:
		if combination.target_id == other_id and combination.target_inventory == target_inventory:
			return combination.actions
	return default_combination
