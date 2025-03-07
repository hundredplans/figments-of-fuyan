class_name AnibilityDatastore extends Resource

@export var is_idle_ability: bool
@export var is_attack_ability: bool
@export var walk_modifier: String
@export var death_modifier: String

func setWalkModifier(_walk_modifier: String) -> void:
	walk_modifier = _walk_modifier
	
func setDeathModifier(_death_modifier: String) -> void:
	death_modifier = _death_modifier

func getWalkModifier() -> String:
	return walk_modifier
	
func getDeathModifier() -> String:
	return death_modifier
	
func onResetWalkModifier() -> void:
	setWalkModifier("")
