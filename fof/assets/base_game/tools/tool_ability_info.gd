class_name ToolAbilityInfoGD
extends Resource

@export var name: String
@export var ability_type: ABILITY_TYPES
@export var ascended_ability_type: ABILITY_TYPES
@export var delay: float
@export var max_charges: int
@export_multiline var description: String
@export_multiline var ascended_description: String
var charges: int
var used: bool
var can_affect: bool = false
var AbilityTiles: AbilityTilesGD
# Tile selected
var Tile: TileGD

enum ABILITY_TYPES {
	NULL,
	ABILITY,
	ABILITY_SELECT,
}

func _init() -> void:
	AbilityTiles = AbilityTilesGD.new()
