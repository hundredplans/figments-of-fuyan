extends OnHitGD

func onHit() -> void:
	var healable_allies: Array = DMGInfo.AppliedBy.Applier.getVisibleAllies().filter(func(x: UnitGD): return x.isHealable())
	var Healee: UnitGD = healable_allies[randi() % healable_allies.size()]
	
	if is_visible:
		DMGInfo.AppliedBy.Applier.Model.on_play_animation("Ability")
		DMGInfo.AppliedBy.Applier.Model.AniPlayer.animation_finished.connect(onHealDelayed.bind(Combat.onHealAbility.bind(Healee, DMGInfo.AppliedBy.Applier, DMGInfo.HealthDMG)))
	else: Combat.onHealAbility(Healee, DMGInfo.AppliedBy.Applier, DMGInfo.HealthDMG)
	
func onHitCondition() -> bool:
	return DMGInfo.AppliedBy.Applier.getVisibleAllies().any(func(x: UnitGD): return x.isHealable())

func onHealDelayed(ani_name: String, callable: Callable) -> void:
	if ani_name == "Ability": callable.call()
