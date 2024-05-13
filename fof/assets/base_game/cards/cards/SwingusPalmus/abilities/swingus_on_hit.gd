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
	else:
		var _trigger: Dictionary = GameEffects.onCreateTrigger("OnAttack", Combat.onDMG.bind(a.DMGInfo.Defender, a.DMGInfo.AppliedBy, DAMAGE), "RemoveFX")
		GameEffects.onAddGameFX(a.Unit, "AbilityActive", a, [_trigger])
		
		var trigger: Dictionary = GameEffects.onCreateTrigger("OnHit", null, "RemoveFX")
		GameEffects.onAddGameFX(a.Unit, "IdleAbility", a, [trigger])
		is_second_hit = true
		
func onHitCondition(_a: Dictionary) -> bool: return true
