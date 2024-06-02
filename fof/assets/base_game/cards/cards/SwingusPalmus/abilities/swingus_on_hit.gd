extends OnHitGD

@export var DAMAGE: int = 2
@export var ATTACK: int = 1
@export var HEALTH: int = 1
@export var is_second_hit: bool = false
func onHit() -> void:
	if is_second_hit:
		onGainStats(Unit, "attack", ATTACK, DMGInfo.AppliedBy)
		onGainStats(Unit, "health", HEALTH, DMGInfo.AppliedBy)
		is_second_hit = false
		delay = 1
	else:
		var AttackTrigger := TriggerGD.new(null, Unit, Unit.setExtraDamage.bind(DAMAGE), TriggerGD.ON_ATTACK, TriggerGD.REMOVE_TRIGGER)
		var AfterAttackTrigger := TriggerGD.new(null, Unit, Unit.setExtraDamage, TriggerGD.ON_AFTER_ATTACK, TriggerGD.REMOVE_FX)
		GameEffects.onAddGameFX(Unit, GameFXGD.ABILITY_ACTIVE, {"ability": self}, [AttackTrigger, AfterAttackTrigger])
		
		is_second_hit = true
		delay = 2
		
func onHitCondition() -> bool: return true
