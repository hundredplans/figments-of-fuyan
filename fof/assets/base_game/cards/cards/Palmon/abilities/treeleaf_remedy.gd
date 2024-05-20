extends TargetAbilityGD

@export var ATTACK: int = 1
@export var HEAL: int = 1
func onTargetAbilityCondition(a: Dictionary) -> Dictionary:
	var tiles: Dictionary = {"range": [], "affect": []}
	if charges > 0:
		tiles["range"] = a.Unit.getVisibleTiles()
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, a.Unit.team)) 
	return tiles

func onTargetAbility(a: Dictionary) -> void:
	var Unit: UnitGD = Units.unit_by_tile(a.Tile)
	var AppliedBy := AppliedByGD.new("Ability", a.Unit)
	Combat.onApplyBuffNextTurn(BuffInfoGD.new(Unit, AppliedBy, "attack", ATTACK))
	Combat.onApplyHealNextTurn(HealInfoGD.new(Unit, AppliedBy, HEAL))
	
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
	a.Unit.Model._look_at(a.Tile)
	charges -= 1
