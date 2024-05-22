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

var OriginalSpectateUnit: UnitGD
var ability_chain: Array = []
func onDeathAbilities(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	onLastWill(Deather, AppliedBy)
	if AppliedBy.Applier != null and AppliedBy.Applier is UnitGD: onRampage(AppliedBy.Applier, AppliedBy)
	onOtherUnitDeathAbilities(Deather, AppliedBy)
	
func onOtherUnitDeathAbilities(Deather: UnitGD, AppliedBy: AppliedByGD) -> void:
	var units: Array = Deather.getVisibleUnits().filter(func(x: UnitGD): return x != Deather and x != AppliedBy.Applier)
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
	GameEffects.onTriggerUnitGameFX(Deather, "RemoveAbility") # Works for mute aswell
	
func onWhenHealed(Healee: UnitGD, healInfo: HealInfoGD, heal_amount: int):
	var abilities: Array = onFindAbilities(Healee, "WhenHealed")
	for ability in abilities:
		ability.setInfo(Healee, healInfo, heal_amount)
		onTriggerAbilitySpectateDelay(Healee, ability, ability.onWhenHealed)
	GameEffects.onTriggerUnitGameFX(Healee, "Heal")
	
func onArrive(Unit: UnitGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Arrive")
	for ability in abilities:
		ability.setInfo(Unit)
		onTriggerAbilitySpectateDelay(Unit, ability, ability.onArrive)
	
func onTargetAbility(Unit: UnitGD, ability: TargetAbilityGD, Tile: TileGD) -> void:
	ability.setInfo(Unit, Tile)
	onTriggerAbilitySpectateDelay(Unit, ability, ability.onTargetAbility)
	Units.PlayerManager._on_unit_deselected(Units.PlayerManager.UnitSelected)
	ability.used = true
	LevelUI.onUpdateTargetAbility(Unit, ability)
	
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
	
	GameEffects.onTriggerUnitGameFX(Unit, "OnHit", [DMGInfo.Defender, DMGInfo.AppliedBy])
	
func onRampage(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	var abilities: Array = onFindAbilities(Unit, "Rampage")
	for ability in abilities:
		ability.setInfo(Unit, AppliedBy)
		if ability.onRampageCondition():
			onTriggerAbilitySpectateDelay(Unit, ability, ability.onRampage)
	GameEffects.onTriggerUnitGameFX(Unit, "Rampage", [Unit, AppliedBy])
		
func onTriggerAbilitySpectateDelay(Triggerer: UnitGD, ability: AbilityGD, callable: Callable) -> void:
	var vis: bool = Triggerer.team == 0 or Triggerer.Tile in Vision.ally_vision
	if vis and ability.delay > 0:
		var begin_arguments: Dictionary = {"Triggerer": Triggerer, "callable": callable, "ability": ability, "vis": vis}
		var end_arguments: Dictionary = {"Triggerer": Triggerer, "ability": ability}
		
		if ability_chain.is_empty():
			OriginalSpectateUnit = SpectateCamera.getSpectateUnit(["Ally", "Enemy"])
		ability_chain.append(ability)
		Units.onPushArgDelay(Triggerer, ability.delay, onAfterAbilityFrontDelay.bind(end_arguments), onBeforeAbilityFrontDelay.bind(begin_arguments))
	else: onUseAbility(Triggerer, callable, ability, vis)
		
func onUseAbility(Unit: UnitGD, callable: Callable, ability: AbilityGD, vis: bool) -> void:
	ability.is_visible = vis
	callable.call()
	LevelUI.onUpdateAbilityCharges(Unit)
		
func onBeforeAbilityFrontDelay(args: Dictionary) -> void:
	onUseAbility(args.Triggerer, args.callable, args.ability, args.vis)
		
func onAfterAbilityFrontDelay(args: Dictionary) -> void:
	ability_chain.erase(args.ability)
	if ability_chain.is_empty() and Units.isUnitActionsEmpty():
		Units.onAppendArgQueue(SpectateCamera.onSpectate.bind(OriginalSpectateUnit))
		OriginalSpectateUnit = null
		
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

func onDMG(Damagee: UnitGD, AppliedBy: AppliedByGD, damage: int) -> DMGInfoGD:
	if !Damagee.is_dead and Damagee.health > 0:
		var DMGInfo := DMGInfoGD.new(Damagee, AppliedBy, damage)
		var original_health: int = Damagee.health
		match AppliedBy.type:
			"Attack":
				var Attacker: UnitGD = AppliedBy.Applier
				GameEffects.onTriggerUnitGameFX(Attacker, "OnAttack")
				damage = onArmor(Damagee, damage + Attacker.extra_damage)
				Damagee.stats("damage", damage, AppliedBy)
				DMGInfo.HealthDMG = original_health - Damagee.health
				GameEffects.onTriggerUnitGameFX(Attacker, "OnAfterAttack")
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

func onHealAbility(Healee: UnitGD, Healer: UnitGD, heal: int) -> bool:
	return onHeal(HealInfoGD.new(Healee, AppliedByGD.new("Ability", Healer), heal))

func onHeal(healInfo: HealInfoGD) -> bool:
	if healInfo.heal > 0 and healInfo.Healee.isHealable():
		var heal_amount: int = min(healInfo.Healee.health + (healInfo.heal * healInfo.Healee.heal_multiplier), healInfo.Healee.max_health) - healInfo.Healee.health
		healInfo.Healee.stats("heal", heal_amount, healInfo.AppliedBy)
		onWhenHealed(healInfo.Healee, healInfo, heal_amount)
		return true
	return false

func onPlayerPhaseStart() -> void:
	for Unit in Units.on_units():
		var abilities: Array = onFindAbilities(Unit, "TargetAbility")
		for ability in abilities:
			ability.setInfo(Unit)
			ability.used = false
			ability.onTargetAbilityCondition()
			ability.can_affect = !ability.tiles["affect"].is_empty()
			LevelUI.onUpdateTargetAbility(Unit, ability)

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
	for buff_info in a.buff_info_array.array: onBuffInfo(buff_info)
	LevelUI.UnitStatusOverlord.onRemoveBuffNextTurn(a.buff_info_array)

func onApplyBuffNextTurn(buff_info: BuffInfoGD, triggers: Array = []) -> void:
	onBuffInfo(buff_info)
	buff_info.value *= -1
	GameEffects.onAddGameFX(buff_info.Unit, "BuffNextTurn", {"buff_info": buff_info}, triggers)

func onApplyHealNextTurn(heal_info: HealInfoGD, triggers: Array = []) -> void:
	GameEffects.onAddGameFX(heal_info.Healee, "HealNextTurn", {"heal_info": heal_info}, triggers)

func onRemoveHealNextTurn(heal_info_array: HealInfoArrayGD) -> void:
	LevelUI.UnitStatusOverlord.onRemoveHealNextTurn(heal_info_array)
	for heal_info in heal_info_array.array: onHeal(heal_info)
	
func onCreateBuffInfoArray(array: Array) -> BuffInfoArrayGD:
	var total: int = 0
	for buff_info in array: total += buff_info.value
	return BuffInfoArrayGD.new(array[0].Unit, array[0].stat, total, array)

func onAddToBuffInfoArray(buff_info_array: BuffInfoArrayGD, buff_info: BuffInfoGD) -> void:
	buff_info_array.array.append(buff_info)
	buff_info_array.value += buff_info.value

func onCreateHealInfoArray(array: Array) -> HealInfoArrayGD:
	var total: int = 0
	for heal_info in array: total += heal_info.heal
	return HealInfoArrayGD.new(array[0].Healee, total, array)

func onAddToHealInfoArray(heal_info_array: HealInfoArrayGD, heal_info: HealInfoGD) -> void:
	heal_info_array.array.append(heal_info)
	heal_info_array.heal += heal_info.heal
