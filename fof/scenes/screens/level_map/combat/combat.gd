class_name CombatGD
extends Node

var GameEffects: GameEffectsGD
var VFX: VFXGD
var Vision: VisionGD
var Units: UnitsGD
var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var Tiles: TilesGD
var PlayerManager: PlayerManagerGD
var StatusManager: StatusManagerGD
var ActionManager: ActionManagerGD
var TriggerManager: TriggerManagerGD

var OriginalSpectateUnit: UnitGD
var ability_chain: Array = []
func onDeathAbilities(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	var units: Array = Deather.getVisibleUnits().filter(func(x: UnitGD): return x != Deather and x != AppliedBy.Applier)
	onLastWill(Deather, AppliedBy)
	if AppliedBy.Applier != null and AppliedBy.Applier is UnitGD: onRampage(AppliedBy.Applier, AppliedBy)
	onOtherUnitDeathAbilities(Deather, AppliedBy, units)
	
func onOtherUnitDeathAbilities(Deather: UnitGD, AppliedBy: AppliedByGD, units: Array) -> void:
	units.sort_custom(Units.sortUnitsByDistance.bind(Deather))
	units.sort_custom(func(x: UnitGD, _y: UnitGD): return x.team == Deather.team)
	for Unit in units:
		if Unit.team != Deather.team: # Trigger bloodthirst
			var abilities: Array = onFindAbilities(Unit, "Bloodthirst")
			for ability in abilities:
				ability.setInfo(Unit, AppliedBy, Deather)
				if ability.onBloodthirstCondition():
					onTriggerAbilitySpectateDelay(Unit, ability, ability.onBloodthirst)
		else: # Trigger trauma
			var abilities: Array = onFindAbilities(Unit, "Trauma")
			for ability in abilities:
				ability.setInfo(Unit, Deather, AppliedBy)
				if ability.onTraumaCondition():
					onTriggerAbilitySpectateDelay(Unit, ability, ability.onTrauma)
			

func onLastWill(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	var abilities: Array = onFindAbilities(Deather, "LastWill")
	for ability in abilities:
		ability.setInfo(Deather, AppliedBy)
		if ability.onLastWillCondition():
			onTriggerAbilitySpectateDelay(Deather, ability, ability.onLastWill)
	
	for ability in Deather.abilities.duplicate():
		Deather.onRemoveAbility(ability)
	TriggerManager.onUnitTrigger(Deather, TriggerGD.LAST_WILL)
	Deather.finished_last_will = true
	
func onWhenHealed(Healee: UnitGD, healInfo: HealInfoGD, heal_amount: int):
	var abilities: Array = onFindAbilities(Healee, "WhenHealed")
	for ability in abilities:
		ability.setInfo(Healee, healInfo, heal_amount)
		onTriggerAbilitySpectateDelay(Healee, ability, ability.onWhenHealed)
	TriggerManager.onUnitTrigger(Healee, TriggerGD.HEAL)
	
func onArrive(Unit: UnitGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Arrive")
	for ability in abilities:
		ability.setInfo(Unit)
		onTriggerAbilitySpectateDelay(Unit, ability, ability.onArrive)
	
func onTargetAbility(Unit: UnitGD, ability: TargetAbilityGD, Tile: TileGD) -> void:
	ability.setInfo(Unit, Tile)
	onTriggerAbilitySpectateDelay(Unit, ability, ability.onTargetAbility)
	
func onRevenge(Damagee: UnitGD, AppliedBy: AppliedByGD, DMGInfo: DMGInfoGD, damage: int):
	var abilities: Array = onFindAbilities(Damagee, "Revenge")
	for ability in abilities:
		ability.setInfo(Damagee, DMGInfo, AppliedBy, damage)
		if !(!ability.trigger_on_death and Damagee.health <= 0) and ability.onRevengeCondition():
			onTriggerAbilitySpectateDelay(Damagee, ability, ability.onRevenge)
	
func onHit(DMGInfo: DMGInfoGD) -> void:
	var Unit: UnitGD = DMGInfo.AppliedBy.Applier
	var abilities: Array = onFindAbilities(Unit, "OnHit")
	for ability in abilities:
		ability.setInfo(Unit, DMGInfo)
		if ability.onHitCondition():
			onTriggerAbilitySpectateDelay(Unit, ability, ability.onHit)
	
	TriggerManager.onUnitTrigger(Unit, TriggerGD.ON_HIT, OnHitTriggerInfoGD.new(DMGInfo.Defender, DMGInfo.AppliedBy))
	
func onRampage(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Rampage")
	for ability in abilities:
		ability.setInfo(Unit, AppliedBy)
		if ability.onRampageCondition():
			onTriggerAbilitySpectateDelay(Unit, ability, ability.onRampage)
	TriggerManager.onUnitTrigger(Unit, TriggerGD.RAMPAGE, RampageTriggerInfoGD.new(AppliedBy))
		
func onTriggerAbilitySpectateDelay(Triggerer: UnitGD, ability: AbilityGD, callable: Callable) -> void:
	var vis: bool = Triggerer.team == 0 or Triggerer.Tile in Vision.getTeamVision()
	if vis and ability.delay > 0:
		var begin_arguments: Dictionary = {"Triggerer": Triggerer, "callable": callable, "ability": ability, "vis": vis}
		var end_arguments: Dictionary = {"Triggerer": Triggerer, "ability": ability, "vis": vis}
		
		if Triggerer.team == 0:
			if ability_chain.is_empty(): OriginalSpectateUnit = SpectateCamera.SpectateUnit
			ability_chain.append(ability)
		
		ActionManager.onAddAction(ArgDelayActionGD.new(onBeforeAbilityFrontDelay.bind(begin_arguments), onAfterAbilityFrontDelay.bind(end_arguments), vis, DelayGD.new(ability.delay)), ActionManagerGD.PUSH)
	else: onUseAbility(Triggerer, callable, ability, vis)
		
func onUseAbility(Unit: UnitGD, callable: Callable, ability: AbilityGD, vis: bool) -> void:
	ability.is_visible = vis
	callable.call()
	LevelUI.onUpdateAbilityCharges(Unit)
		
func onBeforeAbilityFrontDelay(args: Dictionary) -> void:
	onUseAbility(args.Triggerer, args.callable, args.ability, args.vis)
	if args.vis: SpectateCamera.onSpectate(args.Triggerer)
	
func onAfterAbilityFrontDelay(args: Dictionary) -> void:
	ability_chain.erase(args.ability)
	
	if args.vis and ability_chain.is_empty() and ActionManager.unit_actions.is_empty():
		ActionManager.onAddAction(DelayActionGD.new(SpectateCamera.onSpectate.bind(OriginalSpectateUnit), true))
		OriginalSpectateUnit = null
		
func onFindTrait(Unit: UnitGD, type: int) -> TraitGD:
	for Trait in Unit.traits:
		if Trait.type == type: return Trait
	return null
		
func onFindAbilities(Unit: UnitGD, type: String) -> Array:
	var abilities: Array = []
	for ability in Unit.abilities:
		if ability.type == type: abilities.append(ability)
	return abilities

func onFindAbility(Unit: UnitGD, ability_name: String) -> AbilityGD:
	for ability in Unit.abilities:
		if ability.ability_name == ability_name:
			return ability
	return null

func onDMG(UnitA: Variant, AppliedBy: AppliedByGD, damage: int) -> Dictionary:
	var units: Array = UnitA if UnitA is Array else [UnitA]
	var damage_infos: Dictionary = {}
	for Unit in units.filter(func(x: UnitGD): return !x.is_dead and x.health > 0):
		var DMGInfo := DMGInfoGD.new(Unit, AppliedBy, damage)
		var original_health: int = Unit.health
		match AppliedBy.type:
			AppliedByGD.ATTACK:
				var Attacker: UnitGD = AppliedBy.Applier
				TriggerManager.onUnitTrigger(Attacker, TriggerGD.ON_ATTACK, OnAttackTriggerInfoGD.new(Unit))
				damage = onArmor(Unit, damage + Attacker.extra_damage)
				Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.HEALTH, -damage))
				DMGInfo.HealthDMG = original_health - Unit.health
				TriggerManager.onUnitTrigger(Attacker, TriggerGD.ON_AFTER_ATTACK)
				if DMGInfo.HealthDMG > 0:
					TriggerManager.onUnitTrigger(Unit, TriggerGD.WHEN_STRUCK, WhenStruckTriggerInfoGD.new(Attacker, AppliedBy))
			AppliedByGD.HEIGHT:
				Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.HEALTH, -damage))
				DMGInfo.HealthDMG = original_health - Unit.health
			_:
				damage = onArmor(Unit, damage)
				Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.HEALTH, -damage))
				DMGInfo.HealthDMG = original_health - Unit.health
		damage_infos[Unit] = DMGInfo
	
	ActionManager.onAddAction(HurtActionGD.new(damage_infos.keys().filter(func(x: UnitGD): return x.health != 0), AppliedBy))
	for Unit in damage_infos:
		if Unit.health == 0:
			var vis: bool = Unit.isVis()
			ActionManager.onAddAction(DeathActionGD.new(Unit, AppliedBy, vis))
			
		elif damage_infos[Unit].HealthDMG > 0:
			onRevenge(Unit, AppliedBy, damage_infos[Unit], damage)
			TriggerManager.onUnitTrigger(Unit, TriggerGD.REVENGE, RevengeTriggerInfoGD.new(AppliedBy))
			
	PlayerManager.onRefreshAbilitySelect()
	return damage_infos

func onCalculateDamage(Damagee: UnitGD, Attacker: UnitGD) -> int:
	return onArmor(Damagee, Attacker.attack + Attacker.extra_damage)

func onArmor(Unit: UnitGD, damage: int) -> int:
	var armor: TraitGD = onFindTrait(Unit, TraitGD.ARMOR)
	if armor != null: damage = max(damage - armor.armor, 0)
	return damage

func onHealAbility(Healee: UnitGD, Healer: UnitGD, heal: int) -> bool:
	return onHeal(HealInfoGD.new(Healee, heal, AppliedByGD.new(AppliedByGD.ABILITY, Healer)))

func onHeal(HealInfo: HealInfoGD) -> bool:
	if HealInfo.heal > 0 and HealInfo.Healee.isHealable():
		var health: int = HealInfo.Healee.health
		Units.changeStats(StatInfoGD.new(HealInfo.Healee, HealInfo.AppliedBy, StatsGD.HEALTH, HealInfo.heal))
		var diff: int = HealInfo.Healee.health - health
		onWhenHealed(HealInfo.Healee, HealInfo, diff)
		return true
	return false

func onAIPhaseStart() -> void:
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		var abilities: Array = onFindAbilities(Unit, "TargetAbility")
		for ability in abilities:
			ability.used = false

func onPlayerPhaseStart() -> void:
	for Unit in Units.on_units():
		var abilities: Array = onFindAbilities(Unit, "TargetAbility")
		for ability in abilities:
			ability.used = false
	PlayerManager.onRefreshAbilitySelect()

func onDestroyUnit(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	var vis: bool = Unit.team == 0 or Unit.Tile in Vision.getTeamVision()
	ActionManager.onAddAction(DeathActionGD.new(Unit, AppliedBy, vis))
	
func onHelpfulHelmetDelayed(a: Dictionary) -> void:
	var Unit: UnitGD = Units.unit_by_tile(a.Tile)
	GameEffects.addGFX(Unit, GameFXGD.HELPFUL_HELMET, {"AppliedBy": a.AppliedBy})

func isStaggered(Unit: UnitGD) -> bool:
	return GameEffects.onGameFXExists(Unit, GameFXGD.STAGGER)
	
func isDazed(Unit: UnitGD) -> bool:
	return GameEffects.onGameFXExists(Unit, GameFXGD.DAZE)

func isIObjectAbilityEnabled(Unit: UnitGD, _iobject: IObjectGD, ability: IObjectAbilityInfoGD) -> bool:
	return !ability.used and ability.charges != 0 and Unit.turn_status in [UnitGD.TURN_UNUSED, UnitGD.TURN_ACTIVE] and \
	((LevelMap.game_phase == "PlayerPhase" and Unit.team == 0) or (LevelMap.game_phase == "AIPhase" and Unit.team == 1))

func isToolAbilityEnabled(Unit: UnitGD, tool_ability: ToolAbilityInfoGD) ->  bool:
	return Unit.Tool.getCanAffect(tool_ability) and !tool_ability.used and tool_ability.charges != 0 and !isStaggered(Unit) and Unit.Tool.onCondition(tool_ability) and\
	Unit.turn_status == UnitGD.TURN_UNUSED and ((LevelMap.game_phase == "PlayerPhase" and Unit.team == 0) or (LevelMap.game_phase == "AIPhase" and Unit.team == 1))

func isAbilityEnabled(Unit: UnitGD, ability: AbilityGD) -> bool:
	return ability.can_affect and !ability.used and ability.charges != 0 and\
	!isStaggered(Unit) and Unit.turn_status == UnitGD.TURN_UNUSED\
	and (LevelMap.game_phase == "PlayerPhase" and Unit.team == 0 or (LevelMap.game_phase == "AIPhase" and Unit.team == 1))

func onTeleport(Unit: UnitGD, Tile: TileGD) -> void:
	Unit.position = Unit.Model.onCalculateEndPosition(Tile)
	await get_tree().process_frame
	Unit.occupy_tile(Tile)
	if Unit.team == 1 and !(Unit.Tile in Vision.getTeamVision()):
		SpectateCamera.onStopTrack(true)

func onCanKillAtFullSpeed(Unit: UnitGD, movement_paths: Array = Tiles.onCreateMovementPaths(Unit, Unit.speed)) -> bool:
	for _Unit in Unit.getVisibleEnemies():
		if onFindTotalDamageFromMovement(_Unit, Unit, movement_paths) >= _Unit.health:
			return true
	return false

func onCanBeKilledAtFullSpeed(Unit: UnitGD) -> bool:
	var total_damage: int = 0
	for _Unit in Unit.getVisibleEnemies():
		var movement_paths: Array = Tiles.onCreateMovementPaths(_Unit)
		total_damage += onFindTotalDamageFromMovement(Unit, _Unit, movement_paths)
	return total_damage >= Unit.health
	
func onFindTotalDamageFromMovement(Unit: UnitGD, _Unit: UnitGD, movement_paths: Array) -> int: 
	if MovementPathGD.onFindTile(Unit.Tile, movement_paths) != null:
		return onCalculateDamage(Unit, _Unit)
	return 0
	
func onFindEnemiesInMovementPaths(Unit: UnitGD, speed: int = -1) -> Array:
	var movement_paths: Array = Tiles.onCreateMovementPaths(Unit, speed)
	
	return Vision.onUnitsTiles(TeamRelationGD.new(Unit.team, "Enemy"))\
	.filter(func(x: TileGD): return MovementPathGD.onFindTile(x, movement_paths) != null)

func isFallDamageLethal(Unit: UnitGD, fall_damage: int) -> bool:
	return fall_damage >= Unit.health

func onAura(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	for Unit in Units.getAliveDyingUnits():
		var abilities: Array = onFindAbilities(Unit, "Aura")
		for ability in abilities:
			ability.onTrigger(_Unit, trigger, args)

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD = null) -> void:
	onAura(Unit, trigger, args)
