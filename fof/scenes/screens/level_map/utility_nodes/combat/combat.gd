class_name CombatGD
extends Node

var Vision: VisionGD
var Units: UnitsGD
var SpectateCamera: Node3D

func onDeathAbilities(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	onLastWill(Deather, AppliedBy)
	if AppliedBy.type != "Height": onRampage(AppliedBy.Applier, AppliedBy)
	onTrauma(Deather, AppliedBy)
	
func onLastWill(_Deather: UnitGD, _AppliedBy: AppliedByGD) -> void:
	pass
	
func onHit(DMGInfo: DMGInfoGD) -> void:
	var abilities: Array = onFindAbilities(DMGInfo.AppliedBy.Applier, "OnHit")
	for ability in abilities:
		if ability.onHitCondition(DMGInfo):
			onTriggerAbilitySpectateDelay(DMGInfo.AppliedBy.Applier, ability.onHit.bind(DMGInfo), ability.ON_HIT_DELAY)
	
func onTrauma(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	for _Unit in Unit.getVisibleAllies():
		var abilities: Array = onFindAbilities(_Unit, "Trauma")
		for ability in abilities:
			if ability.onTraumaCondition():
				onTriggerAbilitySpectateDelay(_Unit, ability.onTrauma.bind(_Unit, AppliedBy), ability.TRAUMA_DELAY)
	
func onRampage(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Rampage")
	for ability in abilities:
		onTriggerAbilitySpectateDelay(Unit, ability.onRampage.bind(Unit, AppliedBy), ability.RAMPAGE_DELAY)
		
func onTriggerAbilitySpectateDelay(Triggerer: UnitGD, ability: Callable, delay: float) -> void:
	var vis: bool = Triggerer.team == 0 or Triggerer.Tile in Vision.ally_vision
	if vis:
		var SpectateUnit: UnitGD = SpectateCamera.getSpectateUnit(["Ally", "Enemy"])
		if SpectateUnit != Triggerer:
			SpectateCamera.onSpectate(Triggerer)
			SpectateCamera.onEndTrackUnit()
		
		var begin_arguments: Dictionary = {"ability": ability, "vis": vis}
		var end_arguments: Dictionary = {"Triggerer": Triggerer, "SpectateUnit": SpectateUnit}
		
		Units.onPushArgDelay(delay, onBeforeAbilityFrontDelay, onAfterAbilityFrontDelay, begin_arguments, end_arguments)
	else: ability.call(vis)
		
func onBeforeAbilityFrontDelay(args: Dictionary) -> void:
	var ability: Callable = args.ability
	var vis: bool = args.vis
	ability.call(vis)
		
func onAfterAbilityFrontDelay(args: Dictionary) -> void:
	var Triggerer: UnitGD = args.Triggerer
	var Unit: UnitGD = args.SpectateUnit
	if Triggerer != Unit and Unit != null and SpectateCamera.getSpectateUnit(["Ally", "Enemy"]) == Triggerer:
		SpectateCamera.onSpectate(Unit)
		
func onFindAbilities(Unit: UnitGD, type: String) -> Array:
	var abilities: Array = []
	for ability in Unit.abilities:
		if ability.type == type: abilities.append(ability)
	return abilities

func onDMG(Damagee: UnitGD, AppliedBy: AppliedByGD, damage: int) -> DMGInfoGD:
	var DMGInfo := DMGInfoGD.new()
	DMGInfo.AppliedBy = AppliedBy
	DMGInfo.BaseDMG = damage
	DMGInfo.Defender = Damagee
	
	match AppliedBy.type:
		"Attack":
			var original_health: int = Damagee.health
			Damagee.stats("damage", damage, AppliedBy)
			DMGInfo.HealthDMG = original_health - Damagee.health
		"Height":
			Damagee.stats("damage", damage, AppliedBy, true) # Fix this to not be absolute
	return DMGInfo

func onHeal(healInfo: HealInfoGD) -> void:
	var heal_amount: int = min(healInfo.Healee.max_health - healInfo.Healee.health, healInfo.Healee.health + healInfo.heal)
	healInfo.Healee.stats("heal", heal_amount, healInfo.AppliedBy)
