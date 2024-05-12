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
	var buff_info := BuffInfoGD.new()
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	AppliedBy.Applier = a.Unit
	
	var Unit: UnitGD = Units.unit_by_tile(a.Tile)
	buff_info.Unit = Unit
	buff_info.value = ATTACK
	buff_info.stat = "attack"
	buff_info.AppliedBy = AppliedBy
	
	var heal_info := HealInfoGD.new()
	heal_info.heal = HEAL
	heal_info.Healee = Unit
	heal_info.AppliedBy = AppliedBy
	
	Combat.onApplyBuffNextTurn(buff_info)
	Combat.onApplyHealNextTurn(heal_info)
	
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
	a.Unit.Model._look_at(a.Tile)
	charges -= 1
