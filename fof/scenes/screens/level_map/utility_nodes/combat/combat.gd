class_name CombatGD
extends Node

var GameEffects: GameEffectsGD
var VFX: VFXGD
var Vision: VisionGD
var Units: UnitsGD
var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD

func onDeathAbilities(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	onLastWill(Deather, AppliedBy)
	if AppliedBy.type != "Height": onRampage(AppliedBy.Applier, AppliedBy)
	onTrauma(Deather, AppliedBy)
	onBloodthirst(Deather, AppliedBy)
	
func onLastWill(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	var abilities: Array = onFindAbilities(Deather, "LastWill")
	for ability in abilities:
		if ability.onLastWillCondition({}):
			onTriggerAbilitySpectateDelay(Deather, ability, ability.onLastWill.bind({"Deather": Deather, "AppliedBy": AppliedBy}), ability.LAST_WILL_DELAY)
	
func onWhenHealed(Healee: UnitGD, healInfo: HealInfoGD, heal_amount: int):
	var abilities: Array = onFindAbilities(Healee, "WhenHealed")
	for ability in abilities:
		onTriggerAbilitySpectateDelay(Healee, ability, ability.onWhenHealed.bind({"Unit": Healee, "healInfo": healInfo, "heal_amount": heal_amount}), ability.WHEN_HEALED_DELAY)
	
func onArrive(Unit: UnitGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Arrive")
	for ability in abilities:
		onTriggerAbilitySpectateDelay(Unit, ability, ability.onArrive.bind({"Unit": Unit}), ability.ARRIVE_DELAY)
	
func onTargetAbility(Unit: UnitGD, ability: TargetAbilityGD, Tile: TileGD, tiles: Dictionary) -> void:
	onTriggerAbilitySpectateDelay(Unit, ability, ability.onTargetAbility.bind({"Unit": Unit, "Tile": Tile, "tiles": tiles}), ability.TARGET_ABILITY_DELAY)
	Units.PlayerManager._on_unit_deselected(Units.PlayerManager.UnitSelected)
	ability.used = true
	LevelUI.onUpdateTargetAbility(Unit, ability)
	
func onRevenge(Damagee: UnitGD, AppliedBy: AppliedByGD, DMGInfo: DMGInfoGD, damage: int):
	var abilities: Array = onFindAbilities(Damagee, "Revenge")
	for ability in abilities:
		if !(!ability.trigger_on_death and Damagee.health <= 0) and ability.onRevengeCondition({"Unit": Damagee}):
			onTriggerAbilitySpectateDelay(Damagee, ability, ability.onRevenge.bind({"DMGInfo": DMGInfo, "Unit": Damagee, "damage": damage, "AppliedBy": AppliedBy}), ability.REVENGE_DELAY)
	
func onHit(DMGInfo: DMGInfoGD) -> void:
	var Unit: UnitGD = DMGInfo.AppliedBy.Applier
	var abilities: Array = onFindAbilities(Unit, "OnHit")
	for ability in abilities:
		if ability.onHitCondition({"DMGInfo": DMGInfo}):
			onTriggerAbilitySpectateDelay(Unit, ability, ability.onHit.bind({"DMGInfo": DMGInfo, "Unit": Unit}), ability.ON_HIT_DELAY)
	
	GameEffects.onTriggerUnitGameFX(DMGInfo.AppliedBy.Applier, "OnHit", [DMGInfo.Defender, DMGInfo.AppliedBy])
	
func onBloodthirst(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	for _Unit in Unit.getVisibleEnemies():
		if _Unit != AppliedBy.Applier:
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
		
	GameEffects.onTriggerUnitGameFX(Unit, "Rampage", [Unit, AppliedBy])
		
func onTriggerAbilitySpectateDelay(Triggerer: UnitGD, ability: AbilityGD, callable: Callable, delay: float) -> void:
	var vis: bool = Triggerer.team == 0 or Triggerer.Tile in Vision.ally_vision
	if vis and !ability.ignore_ability_delay:
		var SpectateUnit: UnitGD = SpectateCamera.getSpectateUnit(["Ally", "Enemy"])
		if SpectateUnit != Triggerer and !Triggerer.is_dead:
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
	if !Damagee.is_dead and Damagee.health > 0:
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
	return null

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
		onWhenHealed(healInfo.Healee, healInfo, heal_amount)

func onPlayerPhaseStart() -> void:
	for Unit in Units.on_units():
		var abilities: Array = onFindAbilities(Unit, "TargetAbility")
		for ability in abilities:
			var tiles: Dictionary = ability.onTargetAbilityCondition({"Unit": Unit})
			ability.can_affect = !tiles["affect"].is_empty()
			LevelUI.onUpdateTargetAbility(Unit, ability)
			
			if ability is TargetAbilityGD:
				ability.used = false

func onStagger(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	GameEffects.onAddGameFX(Unit, "Stagger", {"AppliedBy": AppliedBy})
	VFX.onCreateStaggerVFX(Unit)
	LevelUI.UnitStatusOverlord.onAddUnitFX(Unit, "Stagger")
	LevelUI.UnitStatusOverlord.onUpdateUnitTargetAbilities(Unit)

func onRemoveStagger(GameFX: GameFXGD) -> void:
	VFX.onRemoveStaggerVFX(GameFX.Unit)
	LevelUI.UnitStatusOverlord.onRemoveUnitFX(GameFX.Unit, "Stagger")

func onDaze(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	GameEffects.onAddGameFX(Unit, "Daze", {"AppliedBy": AppliedBy})
	VFX.onCreateDazeVFX(Unit)
	LevelUI.UnitStatusOverlord.onAddUnitFX(Unit, "Daze")
	
func onRemoveDaze(GameFX: GameFXGD) -> void:
	VFX.onRemoveDazeVFX(GameFX.Unit)
	LevelUI.UnitStatusOverlord.onRemoveUnitFX(GameFX.Unit, "Daze")
	
func onStun(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	onStagger(Unit, AppliedBy)
	onDaze(Unit, AppliedBy)

func onDestroyUnit(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	Units.kill_unit(Unit, AppliedBy)
	
func onHelpfulHelmetDelayed(a: Dictionary) -> void:
	var Unit: UnitGD = Units.unit_by_tile(a.Tile)
	GameEffects.onAddGameFX(Unit, "HelpfulHelmet", {"AppliedBy": a.AppliedBy, "use_bound": false})
	Unit.stats("health", a.HEALTH, a.AppliedBy)

func isStaggered(Unit: UnitGD) -> bool:
	return GameEffects.onGameFXExists(Unit, "Stagger")
	
func isDazed(Unit: UnitGD) -> bool:
	return GameEffects.onGameFXExists(Unit, "Daze")

func isAbilityEnabled(Unit: UnitGD, ability: TargetAbilityGD) -> bool:
	return ability.can_affect and !ability.used and ability.charges != 0 and\
	!isStaggered(Unit) and Unit.turn_status == "TurnUnused"\
	and (LevelMap.game_phase == "PlayerPhase" and Unit.team == 0 or (LevelMap.game_phase == "AIPhase" and Unit.team == 1))

func onBuffInfo(buff_info: BuffInfoGD) -> void:
	buff_info.Unit.stats(buff_info.stat, buff_info.value, buff_info.AppliedBy, buff_info.absolute)

func onRemoveBuffNextTurn(a: Dictionary) -> void:
	onBuffInfo(a.buff_info)
	LevelUI.UnitStatusOverlord.onRemoveBuffNextTurn(a.buff_info)

func onApplyBuffNextTurn(buff_info: BuffInfoGD, triggers: Array = []) -> void:
	onBuffInfo(buff_info)
	buff_info.value *= -1
	GameEffects.onAddGameFX(buff_info.Unit, "BuffNextTurn", {"buff_info": buff_info}, triggers)

func onApplyHealNextTurn(heal_info: HealInfoGD, triggers: Array = []) -> void:
	GameEffects.onAddGameFX(heal_info.Healee, "HealNextTurn", {"heal_info": heal_info}, triggers)

func onRemoveHealNextTurn(heal_info: HealInfoGD) -> void:
	LevelUI.UnitStatusOverlord.onRemoveHealNextTurn(heal_info)
	onHeal(heal_info)
