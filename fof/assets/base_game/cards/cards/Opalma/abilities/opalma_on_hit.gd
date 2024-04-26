extends OnHitGD

func onHit(is_visible: bool, DMGInfo: DMGInfoGD) -> void:
	var healable_allies: Array = DMGInfo.AppliedBy.Applier.getVisibleAllies().filter(func(x: UnitGD): return x.isHealable())
	var Healee: UnitGD = healable_allies[randi() % healable_allies.size()]
	var healInfo := HealInfoGD.new()
	healInfo.heal = DMGInfo.HealthDMG
	
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	AppliedBy.Applier = DMGInfo.AppliedBy.Applier
	healInfo.AppliedBy = AppliedBy
	
	healInfo.Healee = Healee
	Combat.onHeal(healInfo)
	
	if is_visible:
		DMGInfo.AppliedBy.Applier.Model.on_play_animation("Ability")
		if Healee.Tile in Vision.ally_vision:
			VFX.onCreateOneShot("Heal", Healee.Tile, Healee.height.top / 2)

func onHitCondition(DMGInfo: DMGInfoGD) -> bool:
	return DMGInfo.AppliedBy.Applier.getVisibleAllies().any(func(x: UnitGD): return x.isHealable())
