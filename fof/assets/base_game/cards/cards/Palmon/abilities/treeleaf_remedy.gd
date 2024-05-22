extends TargetAbilityGD

@export var ATTACK: int = 1
@export var HEAL: int = 1
func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	if charges > 0:
		tiles["range"] = Unit.getVisibleTiles()
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team)) 

func onTargetAbility() -> void:
	var _Unit: UnitGD = Units.unit_by_tile(Tile)
	var AppliedBy := AppliedByGD.new("Ability", Unit)
	Combat.onApplyBuffNextTurn(BuffInfoGD.new(_Unit, AppliedBy, "attack", ATTACK))
	Combat.onApplyHealNextTurn(HealInfoGD.new(_Unit, AppliedBy, HEAL))
	
	if is_visible: Unit.Model.on_play_animation("Ability")
	Unit.Model._look_at(Tile)
	charges -= 1
