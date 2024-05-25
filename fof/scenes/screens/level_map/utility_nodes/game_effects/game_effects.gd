class_name GameEffectsGD
extends Node

var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var VFX: VFXGD
var Combat: CombatGD
var effects: Array = []

func onDeathFinished(Unit: UnitGD) -> void:
	var _effects: Array = effects.duplicate()
	for GameFX in _effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		effects.erase(Unit)

func onAddGameFX(Unit: UnitGD, type: int, a: Dictionary, triggers: Array = []) -> void:
	var GameFX: GameFXGD 
	match type:
		GameFXGD.HEAL_NEXT_TURN: GameFX = onAddHealNextTurn(Unit, a, triggers)
		GameFXGD.BUFF_NEXT_TURN: GameFX = onAddBuffNextTurn(Unit, a, triggers)
		GameFXGD.DAZE: GameFX = onAddDazeFX(Unit, a)
		GameFXGD.STAGGER: GameFX = onAddStaggerFX(Unit, a)
		GameFXGD.ABILITY_ACTIVE: GameFX = onAddAbilityActive(Unit, a, triggers)
		GameFXGD.HELPFUL_HELMET: GameFX = onAddHelpfulHelmet(Unit, a)
		GameFXGD.CHARMING_STANCE: GameFX = onAddCharmingStance(Unit, a)
	if GameFX != null: GameFX.type = type
		
func onAddBuffNextTurn(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	var _GameFX := onFindFirstGameFX(Unit, GameFXGD.BUFF_NEXT_TURN)
	if _GameFX == null or _GameFX.info.buff_info_array.stat != a.buff_info.stat:
		a.buff_info_array = Combat.onCreateBuffInfoArray([a.buff_info])
		a.erase("buff_info")
		
		var GameFX := onCreateGameFX(Unit, GameFXGD.BUFF_NEXT_TURN, a, triggers)
		onAppendTrigger(TriggerGD.new(GameFX, Unit, Combat.onRemoveBuffNextTurn.bind(a), TriggerGD.NEXT_TURN, TriggerGD.REMOVE_FX))
		
		LevelUI.UnitStatusOverlord.onCreateBuffNextTurn(a.buff_info_array)
		return GameFX
	Combat.onAddToBuffInfoArray(_GameFX.info.buff_info_array, a.buff_info)
	LevelUI.UnitStatusOverlord.onCreateBuffNextTurn(_GameFX.info.buff_info_array)
	return null
func onAddHealNextTurn(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	var _GameFX := onFindFirstGameFX(Unit, GameFXGD.HEAL_NEXT_TURN)
	if _GameFX == null:
		a.heal_info_array = Combat.onCreateHealInfoArray([a.heal_info])
		a.erase("heal_info")
		
		var GameFX := onCreateGameFX(Unit, GameFXGD.HEAL_NEXT_TURN, a, triggers)
		onAppendTrigger(TriggerGD.new(GameFX, Unit, Combat.onRemoveHealNextTurn.bind(a.heal_info_array), TriggerGD.NEXT_TURN, TriggerGD.REMOVE_FX))
		LevelUI.UnitStatusOverlord.onCreateHealNextTurn(a.heal_info_array)
		return GameFX
	Combat.onAddToHealInfoArray(_GameFX.info.heal_info_array, a.heal_info)
	LevelUI.UnitStatusOverlord.onCreateHealNextTurn(_GameFX.info.heal_info_array)
	return null
		
func onTriggerGameFX(GameFX: GameFXGD, type: int, Unit: UnitGD = null, bound_args: Array = []) -> void:
	if GameFX != null:
		var remove_triggers: Array = []
		for Trigger in GameFX.triggers:
			if Trigger.type == type and (Unit == null or Trigger.Unit == Unit):
				if !Trigger.callable.is_null():
					Trigger.callable.callv(bound_args if Trigger.use_bound else [])
				remove_triggers.append(onRemoveTrigger.bind(GameFX, Trigger))
		for remove_callable in remove_triggers: remove_callable.call()
		
func onActiveAbilityTriggered(Unit: UnitGD) -> void:
	Unit.Model.onActivateIdleAbility()
	
func onRemoveTrigger(GameFX: GameFXGD, Trigger: TriggerGD) -> void:
	match Trigger.remove_type:
		TriggerGD.REMOVE_FX:
			if GameFX in effects:
				onTriggerGameFX(GameFX, TriggerGD.REMOVE)
				effects.erase(GameFX)
		TriggerGD.REMOVE_TRIGGER:
			GameFX.triggers.erase(Trigger)
				
		
func onAddAbilityActive(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, GameFXGD.ABILITY_ACTIVE, a, triggers)
	onAppendTrigger(TriggerGD.new(GameFX, Unit, onRemoveAbilityActive.bind(GameFX), TriggerGD.REMOVE, TriggerGD.NULL))
	onAppendTrigger(TriggerGD.new(GameFX, Unit, Unit.Model.onRemoveIdleAbility, TriggerGD.REMOVE, TriggerGD.NULL))
	Unit.Model.onActivateIdleAbility()
	VFX.onCreateAbilityActiveParticle(Unit)
	LevelUI.UnitStatusOverlord.onAddAbilityActiveFX(Unit, a.ability.ability_name)
	return GameFX
		
func onRemoveAbilityActive(GameFX: GameFXGD) -> void:
	VFX.onRemoveAbilityActiveParticle(GameFX.Unit)
	LevelUI.UnitStatusOverlord.onRemoveAbilityActiveFX(GameFX.Unit, GameFX.info.ability.ability_name)
		
func onAppendTrigger(Trigger: TriggerGD) -> void:
	Trigger.GameFX.triggers.append(Trigger)
	
func onAddHelpfulHelmet(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, GameFXGD.HELPFUL_HELMET, a)
	onAppendTrigger(TriggerGD.new(GameFX, Unit, Unit.stats.bind("health", 1), TriggerGD.RAMPAGE, a.use_bound))
	LevelUI.UnitStatusOverlord.onAddUnitFX(Unit, "HelpfulHelmet")
	if Unit.team == 0: SpectateCamera.onSpectate(Unit)
	VFX.onCreateHelpfulHelmet(Unit)
	return GameFX
	
func onAddCharmingStance(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, GameFXGD.CHARMING_STANCE, a)
	onAppendTrigger(TriggerGD.new(GameFX, a.Unit, LevelUI.UnitStatusOverlord.onRemoveUnitFX.bind(Unit, "CharmingStance"), TriggerGD.REMOVE_ABILITY, TriggerGD.REMOVE_FX))
	LevelUI.UnitStatusOverlord.onAddUnitFX(Unit, "CharmingStance", AppliedByGD.new("Ability", a.Unit))
	return GameFX
		
func onOverrideGameFX(Unit: UnitGD, type: int) -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		if GameFX.type == type:
			effects.erase(GameFX)
			match type:
				"Daze": Combat.onRemoveDaze(GameFX)
				"Stagger": Combat.onRemoveStagger(GameFX)
			return

func onAddDazeFX(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	onOverrideGameFX(Unit, GameFXGD.DAZE)
	var GameFX := onCreateGameFX(Unit, GameFXGD.DAZE, a)
	onAppendTrigger(TriggerGD.new(GameFX, Unit, Combat.onRemoveDaze.bind(GameFX), TriggerGD.TURN_PASSED, TriggerGD.REMOVE_FX))
	return GameFX
	
func onAddStaggerFX(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	onOverrideGameFX(Unit, GameFXGD.STAGGER)
	var GameFX := onCreateGameFX(Unit, GameFXGD.STAGGER, a)
	onAppendTrigger(TriggerGD.new(GameFX, Unit, Combat.onRemoveStagger.bind(GameFX), TriggerGD.TURN_PASSED, TriggerGD.REMOVE_FX))
	return GameFX
	
func onCreateGameFX(Unit: UnitGD, type: int, a: Dictionary, triggers: Array = []) -> GameFXGD:
	var GameFX := GameFXGD.new(Unit, type, a, triggers)
	effects.append(GameFX)
	for trigger in triggers: trigger.GameFX = GameFX
	return GameFX

func onGameFXExists(Unit: UnitGD, type: int) -> bool:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		if GameFX.type == type:
			return true
	return false

func onAIPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 1):
		onTriggerGameFX(GameFX, TriggerGD.NEXT_TURN)
	
func onAIEndTurnPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 1):
		onTriggerGameFX(GameFX, TriggerGD.END_TURN)

func onPlayerPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 0):
		onTriggerGameFX(GameFX, TriggerGD.NEXT_TURN)

func onPlayerEndTurnPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 0):
		onTriggerGameFX(GameFX, TriggerGD.END_TURN)

func onTriggerUnitGameFX(Unit: UnitGD, type: int, bound_args: Array = []) -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		onTriggerGameFX(GameFX, type, Unit, bound_args)

func onFindFirstGameFX(Unit: UnitGD, type: int) -> GameFXGD:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		if GameFX.type == type: return GameFX
	return null

func onFindAllGameFX(Unit: UnitGD, type: int) -> Array:
	return effects.filter(func(x: GameFXGD): return x.Unit == Unit and x.type == type)
