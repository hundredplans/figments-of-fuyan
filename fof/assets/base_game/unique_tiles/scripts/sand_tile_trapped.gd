extends UniqueTileGD

var delay: float = 2
var model: Node3D
var SprungUnit: UnitGD
var has_debuffed: bool = false

func onReady() -> void:
	model = Tile.types[0].model.get_node("CrabArmArmature")
	model.visible = false
	model.position.y -= 0.2
	
func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.MOVE and Unit.Tile == Tile and SprungUnit == null:
		SprungUnit = Unit
		ActionManager.onAddAction(DelayActionGD.new(onDelay, Unit.isVis(), DelayGD.new(delay)), ActionManager.PUSH)
		
	if trigger == TriggerGD.START_TURN_GLOBAL and SprungUnit != null and args.team_relation.onTeam() == SprungUnit.team and !has_debuffed:
		has_debuffed = true
		Units.changeStats(StatInfoGD.new(SprungUnit, AppliedByGD.new(), StatsGD.BOTH_SPEED, -1, 1))

func onDelay() -> void:
	model.visible = true
	GameEffects.onDefaultStun(SprungUnit)
	model.get_parent().playAnimation("Ability")
	SprungUnit.Model.onVFXAnimation(preload("res://assets/base_game/unique_tiles/extras/vfx_yeouch.tres"))
	

