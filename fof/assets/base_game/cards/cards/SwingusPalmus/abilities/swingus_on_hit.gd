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
		var attack_trigger: Dictionary = GameEffects.onCreateTrigger("OnAttack", Unit.setExtraDamage.bind(DAMAGE))
		var after_attack_trigger: Dictionary = GameEffects.onCreateTrigger("OnAfterAttack", Unit.setExtraDamage, "RemoveFX")
		var trigger: Dictionary = GameEffects.onCreateTrigger("OnHit", null, "RemoveFX")
		
		GameEffects.onAddGameFX(Unit, "AbilityActive", {"ability": self}, [trigger])
		GameEffects.onAddGameFX(Unit, "IdleAbility", {"ability": self}, [attack_trigger, after_attack_trigger])
		is_second_hit = true
		delay = 2
		
func onHitCondition() -> bool: return true
