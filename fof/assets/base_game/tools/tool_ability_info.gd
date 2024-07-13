class_name ToolAbilityInfoGD
extends Resource

@export var ability_type: ABILITY_TYPES
@export var ascended_ability_type: ABILITY_TYPES
@export var delay: float = 1
@export var max_charges: int
@export_multiline var description: String
@export_multiline var ascended_description: String
var charges: int
var used: bool

enum ABILITY_TYPES {
	NULL,
	ABILITY,
	ABILITY_SELECT,
}
