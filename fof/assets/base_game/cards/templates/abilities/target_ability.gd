class_name TargetAbilityGD
extends AbilityGD

@export_multiline var ability_description: String
@export var teleport_to_target: bool = false
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
