class_name CombatGD
extends Node

var VFX: VFXGD
var Vision: VisionGD
var Units: UnitsGD
var SpectateCamera: Node3D
var LevelUI: LevelUIGD

func onDeathAbilities(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	onLastWill(Deather, AppliedBy)
	if AppliedBy.type != "Height": onRampage(AppliedBy.Applier, AppliedBy)
	onTrauma(Deather, AppliedBy)
	onBloodthirst(Deather, AppliedBy)
	
func onLastWill(_Deather: UnitGD, _AppliedBy: AppliedByGD) -> void:
	pass
	
func onArrive(Unit: UnitGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Arrive")
	for ability in abilities:
		onTriggerAbilitySpectateDelay(Unit, ability, ability.onArrive.bind({"Unit": Unit}), ability.ARRIVE_DELAY)
	
func onTargetAbility(Unit: UnitGD, ability: TargetAbilityGD, Tile: TileGD, tiles: Dictionary) -> void:
	onTriggerAbilitySpectateDelay(Unit, ability, ability.onTargetAbility.bind({"Unit": Unit, "Tile": Tile, "tiles": tiles}), ability.TARGET_ABILITY_DELAY)
	Units.PlayerManager._on_unit_deselected(Units.PlayerManager.UnitSelected)
	
func onRevenge(Damagee: UnitGD, AppliedBy: AppliedByGD, DMGInfo: DMGInfoGD, damage: int):
	var abilities: Array = onFindAbilities(Damagee, "Revenge")
	for ability in abilities:
		if ability.onRevengeCondition({"Unit": Damagee}):
			onTriggerAbilitySpectateDelay(Damagee, ability, ability.onRevenge.bind({"DMGInfo": DMGInfo, "Unit": Damagee, "damage": damage, "AppliedBy": AppliedBy}), ability.REVENGE_DELAY)
	
func onHit(DMGInfo: DMGInfoGD) -> void:
	var abilities: Array = onFindAbilities(DMGInfo.AppliedBy.Applier, "OnHit")
	for ability in abilities:
		if ability.onHitCondition({"DMGInfo": DMGInfo}):
			onTriggerAbilitySpectateDelay(DMGInfo.AppliedBy.Applier, ability, ability.onHit.bind({"DMGInfo": DMGInfo}), ability.ON_HIT_DELAY)
	
func onBloodthirst(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	for _Unit in Unit.getVisibleEnemies():
		var abilities: Array = onFindAbilities(_Unit, "Bloodthirst")
		for ability in abilities:
			if ability.onBloodthirstCondition({"Unit": Unit, "AppliedBy": AppliedBy}):
				onTriggerAbilitySpectateDelay(_Unit, ability, ability.onBloodthirst.bind({"Unit": _Unit, "AppliedBy": AppliedBy}), ability.BLOODTHIRST_DELAY)
	
func onTrauma(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	for _Unit in Unit.getVisibleAllies():
		var abilities: Array = onFindAbilities(_Unit, "Trauma")
		for ability in abilities:
			if ability.onTraumaCondition():
				onTriggerAbilitySpectateDelay(_Unit, ability, ability.onTrauma.bind({"Unit": _Unit, "AppliedBy": AppliedBy}), ability.TRAUMA_DELAY)
	
func onRampage(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Rampage")
	for ability in abilities:
		onTriggerAbilitySpectateDelay(Unit, ability, ability.onRampage.bind({"Unit": Unit, "AppliedBy": AppliedBy}), ability.RAMPAGE_DELAY)
		
func onTriggerAbilitySpectateDelay(Triggerer: UnitGD, ability: AbilityGD, callable: Callable, delay: float) -> void:
	var vis: bool = Triggerer.team == 0 or Triggerer.Tile in Vision.ally_vision
	if vis:
		var SpectateUnit: UnitGD = SpectateCamera.getSpectateUnit(["Ally", "Enemy"])
		if SpectateUnit != Triggerer:
			SpectateCamera.onSpectate(Triggerer)
			SpectateCamera.onEndTrackUnit()
		
		var begin_arguments: Dictionary = {"Triggerer": Triggerer, "callable": callable, "ability": ability, "vis": vis}
		var end_arguments: Dictionary = {"Triggerer": Triggerer, "SpectateUnit": SpectateUnit}
		
		Units.onPushArgDelay(delay, onBeforeAbilityFrontDelay, onAfterAbilityFrontDelay, begin_arguments, end_arguments)
	else: onUseAbility(Triggerer, callable, ability, vis)
		
func onUseAbility(Unit: UnitGD, callable: Callable, ability: AbilityGD, vis: bool) -> void:
	callable.get_bound_arguments()[0]["is_visible"] = vis
	callable.call()
	LevelUI.onUpdateTargetAbilityCharges(Unit, ability)
		
func onBeforeAbilityFrontDelay(args: Dictionary) -> void:
	onUseAbility(args.Triggerer, args.callable, args.ability, args.vis)
		
func onAfterAbilityFrontDelay(args: Dictionary) -> void:
	var Triggerer: UnitGD = args.Triggerer
	var Unit: UnitGD = args.SpectateUnit
	if !Units.isUnitActionsEmpty() and Triggerer != Unit and Unit != null and SpectateCamera.getSpectateUnit(["Ally", "Enemy"]) == Triggerer:
		SpectateCamera.onSpectate(Unit)
		
func onFindAbilities(Unit: UnitGD, type: String) -> Array:
	var abilities: Array = []
	for ability in Unit.abilities:
		if ability.type == type: abilities.append(ability)
	return abilities

func onDMG(Damagee: UnitGD, AppliedBy: AppliedByGD, damage: int) -> DMGInfoGD:
	var DMGInfo := DMGInfoGD.new()
	var original_health: int = Damagee.health
	DMGInfo.AppliedBy = AppliedBy
	DMGInfo.BaseDMG = damage
	DMGInfo.Defender = Damagee
	
	match AppliedBy.type:
		"Attack":
			damage = onArmor(Damagee, damage)
			Damagee.stats("damage", damage, AppliedBy)
			DMGInfo.HealthDMG = original_health - Damagee.health
		"Height":
			Damagee.stats("damage", damage, AppliedBy) # Fix this to not be absolute
		"Ability":
			damage = onArmor(Damagee, damage)
			Damagee.stats("damage", damage, AppliedBy)
			DMGInfo.HealthDMG = original_health - Damagee.health
			
	if DMGInfo.HealthDMG > 0: onRevenge(Damagee, AppliedBy, DMGInfo, damage)
	return DMGInfo

func onArmor(Unit: UnitGD, damage: int) -> int:
	var abilities: Array = onFindAbilities(Unit, "Armor")
	for ability in abilities:
		damage = max(damage - ability.armor, 0)
	return damage

func onHealAbility(Healee: UnitGD, Healer: UnitGD, heal: int) -> void:
	var healInfo := HealInfoGD.new()
	healInfo.heal = heal
	
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	AppliedBy.Applier = Healer
	healInfo.AppliedBy = AppliedBy
	
	healInfo.Healee = Healee
	onHeal(healInfo)

func onHeal(healInfo: HealInfoGD) -> void:
	if healInfo.heal > 0:
		var heal_amount: int = min(healInfo.Healee.health + healInfo.heal, healInfo.Healee.max_health) - healInfo.Healee.health
		healInfo.Healee.stats("heal", heal_amount, healInfo.AppliedBy)
