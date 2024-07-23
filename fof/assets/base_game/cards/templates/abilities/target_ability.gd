class_name TargetAbilityGD
extends AbilityGD

@export_multiline var ability_description: String
@export_multiline var ability_description_big: String

const type: String = "TargetAbility"
var used: bool = false
var can_affect: bool = false
var Unit: UnitGD
var Tile: TileGD
var AbilityTiles: AbilityTilesGD

func setInfo(_Unit: UnitGD = null, _Tile: TileGD = null) -> void:
	Unit = _Unit
	Tile = _Tile
	AbilityTiles = AbilityTilesGD.new()

func onAffectedUnits() -> Array:
	return AbilityTiles.can_affect.map(func(x: TileGD): return Units.unit_by_tile(x))
	
