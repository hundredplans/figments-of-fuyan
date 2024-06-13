extends OnHitGD

func onHit() -> void:
	var healable_allies: Array = DMGInfo.AppliedBy.Applier.getVisibleAllies().filter(func(x: UnitGD): return x.isHealable())
	var Healee: UnitGD = healable_allies[randi() % healable_allies.size()]
	
	if is_visible:
		DMGInfo.AppliedBy.Applier.Model.on_play_animation("Ability")
		onAbilityDelay(onAbilityDelayFinished.bind(Healee))
	else: onAbilityDelayFinished(Healee)
	
func onHitCondition() -> bool:
	return DMGInfo.AppliedBy.Applier.getVisibleAllies().any(func(x: UnitGD): return x.isHealable())

func onAbilityDelayFinished(Healee: UnitGD) -> void:
	Combat.onHealAbility(Healee, DMGInfo.AppliedBy.Applier, DMGInfo.HealthDMG)
