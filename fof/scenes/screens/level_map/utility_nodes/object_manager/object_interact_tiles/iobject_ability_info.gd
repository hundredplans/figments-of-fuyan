class_name IObjectAbilityInfoGD
extends Resource

@export var name: String
@export_multiline var description: String
@export var max_charges: int
@export var ability_type: ABILITY_TYPES
@export var delay: float
@export var tiles: Array[Vector4]
var charges: int
var used: bool

enum ABILITY_TYPES {
	NULL,
	ABILITY,
	ABILITY_SELECT,
}
