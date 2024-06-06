class_name TargetAbilityGD
extends AbilityGD

@export_multiline var ability_description: String
@export_multiline var ability_description_big: String
# Spectate the affected target when ability is triggered
@export var teleport_to_target: bool = false
# Spectate the first affected unit when ability mode is triggered
@export var change_camera: bool = false

const type: String = "TargetAbility"
var used: bool = false
var can_affect: bool = false
var Unit: UnitGD
var Tile: TileGD
var tiles: Dictionary

func setInfo(_Unit: UnitGD = null, _Tile: TileGD = null) -> void:
	Unit = _Unit
	Tile = _Tile

func onAffectedUnits() -> Array:
	return tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x))
	
