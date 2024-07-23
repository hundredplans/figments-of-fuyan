class_name AttackActionGD
extends ActionGD

const type: int = ActionManagerGD.ATTACK
var TargetTile: TileGD

func _init(_Unit: UnitGD = null, _TargetTile: TileGD = null, _is_visible: bool = true, _delay: DelayGD = null) -> void:
	Unit = _Unit
	TargetTile = _TargetTile
	delay = _delay
	is_visible = _is_visible
	if delay == null: delay = DelayGD.new(1.5)
	super()
	
func onCondition() -> bool:
	if Unit.onCanAttack() and Unit.turn_status == UnitGD.TURN_ACTIVE:
		if TargetTile.Unit != null: return true
	return false
	
func onTrigger() -> void:
	if is_visible:
		SpectateCamera.onSpectate(Unit)
		Unit.Model.attack_tile(TargetTile)
		
	if TargetTile.Unit != null:
		TargetTile.Unit.Model._look_at(Unit.Tile)
	
func onAfterTrigger() -> void:
	var AppliedBy := AppliedByGD.new(AppliedByGD.ATTACK, Unit)
	if TargetTile.Unit != null:
		var DMGInfos: Dictionary = Combat.onDMG(TargetTile.Unit, AppliedBy, Unit.attack)
		Unit.attack_amount -= 1
		if Unit.attack_amount == 0: Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.CURRENT_SPEED, 0, -1, true, false))
		ActionManager.onAddAction(DelayActionGD.new(Combat.onHit.bind(DMGInfos[TargetTile.Unit]), is_visible), ActionManagerGD.AFTER_HURT)
