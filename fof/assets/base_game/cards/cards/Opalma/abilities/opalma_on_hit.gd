extends OnHitGD

func onHit(a: Dictionary) -> void:
	var healable_allies: Array = a.DMGInfo.AppliedBy.Applier.getVisibleAllies().filter(func(x: UnitGD): return x.isHealable())
	var Healee: UnitGD = healable_allies[randi() % healable_allies.size()]
	Combat.onHealAbility(Healee, a.DMGInfo.AppliedBy.Applier, a.DMGInfo.HealthDMG)
	
	if a.is_visible:
		a.DMGInfo.AppliedBy.Applier.Model.on_play_animation("Ability")

func onHitCondition(a: Dictionary) -> bool:
	return a.DMGInfo.AppliedBy.Applier.getVisibleAllies().any(func(x: UnitGD): return x.isHealable())
