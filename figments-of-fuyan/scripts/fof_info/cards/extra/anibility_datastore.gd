class_name AnibilityDatastore extends Resource

@export var is_idle_ability: bool
@export var is_attack_ability: bool
@export var is_death_ability: bool
@export var walk_modifier: String

func setWalkModifier(_walk_modifier: String) -> void:
	walk_modifier = _walk_modifier

func getWalkModifier() -> String:
	return walk_modifier
	
func onResetWalkModifier() -> void:
	setWalkModifier("")
