extends OnHitGD

@export var DAMAGE: int = 2
@export var ATTACK: int = 1
@export var HEALTH: int = 1
@export var is_second_hit: bool = false
func onHit(a: Dictionary) -> void:
	if is_second_hit:
		onGainStats(a.Unit, "attack", ATTACK, a.DMGInfo.AppliedBy)
		onGainStats(a.Unit, "health", HEALTH, a.DMGInfo.AppliedBy)
		is_second_hit = false
		delay = 1
	else:
		var attack_trigger: Dictionary = GameEffects.onCreateTrigger("OnAttack", a.Unit.setExtraDamage.bind(DAMAGE))
		var after_attack_trigger: Dictionary = GameEffects.onCreateTrigger("OnAfterAttack", a.Unit.setExtraDamage, "RemoveFX")
		var trigger: Dictionary = GameEffects.onCreateTrigger("OnHit", null, "RemoveFX")
		GameEffects.onAddGameFX(a.Unit, "AbilityActive", a, [trigger])
		GameEffects.onAddGameFX(a.Unit, "IdleAbility", a, [attack_trigger, after_attack_trigger])
		is_second_hit = true
		delay = 2
		
func onHitCondition(_a: Dictionary) -> bool: return true
