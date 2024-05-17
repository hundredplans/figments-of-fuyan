class_name GameEffectsGD
extends Node

var LevelUI: LevelUIGD
var VFX: VFXGD
var Combat: CombatGD
var effects: Array = []

func onDeathFinished(Unit: UnitGD) -> void:
	var _effects: Array = effects.duplicate()
	for GameFX in _effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		effects.erase(Unit)

func onAddGameFX(Unit: UnitGD, type: String, a: Dictionary, triggers: Array = []) -> void:
	var GameFX: GameFXGD
	match type:
		"HealNextTurn": GameFX = onAddHealNextTurn(Unit, a, triggers)
		"BuffNextTurn": GameFX = onAddBuffNextTurn(Unit, a, triggers)
		"Daze": GameFX = onAddDazeFX(Unit, a)
		"Stagger": GameFX = onAddStaggerFX(Unit, a)
		"AbilityActive": GameFX = onAddAbilityActive(Unit, a, triggers)
		"IdleAbility": GameFX = onAddIdleAbility(Unit, a, triggers)
		"HelpfulHelmet": GameFX = onAddHelpfulHelmet(Unit, a)
		"CharmingStance": GameFX = onAddCharmingStance(Unit, a)
	
	if GameFX != null:
		GameFX.type = type
		onTriggerGameFX(GameFX, "Instant")
		
func onAddBuffNextTurn(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	var _GameFX := onFindFirstGameFX(Unit, "BuffNextTurn")
	if _GameFX == null or _GameFX.info.buff_info_array.stat != a.buff_info.stat:
		a.buff_info_array = Combat.onCreateBuffInfoArray([a.buff_info])
		a.erase("buff_info")
		
		var GameFX := onCreateGameFX(Unit, a, triggers)
		onAppendTrigger(GameFX, "NextTurn", Combat.onRemoveBuffNextTurn.bind(a), "RemoveFX")
		LevelUI.UnitStatusOverlord.onCreateBuffNextTurn(a.buff_info_array)
		return GameFX
	Combat.onAddToBuffInfoArray(_GameFX.info.buff_info_array, a.buff_info)
	LevelUI.UnitStatusOverlord.onCreateBuffNextTurn(_GameFX.info.buff_info_array)
	return null
func onAddHealNextTurn(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	var _GameFX := onFindFirstGameFX(Unit, "HealNextTurn")
	if _GameFX == null:
		a.heal_info_array = Combat.onCreateHealInfoArray([a.heal_info])
		a.erase("heal_info")
		
		var GameFX := onCreateGameFX(Unit, a, triggers)
		onAppendTrigger(GameFX, "NextTurn", Combat.onRemoveHealNextTurn.bind(a.heal_info_array), "RemoveFX")
		LevelUI.UnitStatusOverlord.onCreateHealNextTurn(a.heal_info_array)
		return GameFX
	Combat.onAddToHealInfoArray(_GameFX.info.heal_info_array, a.heal_info)
	LevelUI.UnitStatusOverlord.onCreateHealNextTurn(_GameFX.info.heal_info_array)
	return null
		
func onTriggerGameFX(GameFX: GameFXGD, type: String, bound_args: Array = []) -> void:
	if GameFX != null:
		var remove_triggers: Array = []
		for trigger in GameFX.triggers:
			if trigger.trigger == type:
				if trigger.callable != null:
					if !bound_args.is_empty() and trigger.use_bound:
						trigger.callable = trigger.callable.bindv(bound_args)
					trigger.callable.call()
				remove_triggers.append(onRemoveTrigger.bind(GameFX, trigger))
		for trigger in remove_triggers: trigger.call()
		
func onActiveAbilityTriggered(Unit: UnitGD) -> void:
	Unit.Model.onActivateIdleAbility()
	
func onRemoveTrigger(GameFX: GameFXGD, trigger: Dictionary) -> void:
	if !trigger.remove_type.is_empty() and !(trigger.remove_type == "RemoveFX" and GameFX not in effects):
		trigger.charges -= 1
		if trigger.charges <= 0:
			match trigger.remove_type:
				"RemoveFX":
					onTriggerGameFX(GameFX, "Remove")
					effects.erase(GameFX)
				"RemoveTrigger":
					GameFX.triggers.erase(trigger)
		
func onAddIdleAbility(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, a, triggers)
	onAppendTrigger(GameFX, "Remove", Unit.Model.onRemoveIdleAbility)
	Unit.Model.onActivateIdleAbility()
	return GameFX
		
func onAddAbilityActive(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, a, triggers)
	onAppendTrigger(GameFX, "Remove", onRemoveAbilityActive.bind(GameFX))
	VFX.onCreateAbilityActiveParticle(Unit)
	return GameFX
		
func onRemoveAbilityActive(GameFX: GameFXGD) -> void:
	VFX.onRemoveAbilityActiveParticle(GameFX.Unit)
		
func onAppendTrigger(GameFX: GameFXGD, trigger: String, callable: Callable, remove_type: String = "", charges: int = 1, use_bound: bool = true) -> void:
	GameFX.triggers.append(onCreateTrigger(trigger, callable, remove_type, charges, use_bound))
	
func onAppendUnitTrigger(GameFX: GameFXGD, Unit: UnitGD, trigger: String, callable: Callable, remove_type: String = "", charges: int = 1, use_bound: bool = true):
	GameFX.triggers.append(onCreateUnitTrigger(Unit, trigger, callable, remove_type, charges, use_bound))
	
func onCreateUnitTrigger(Unit: UnitGD, trigger: String, callable: Variant, remove_type: String = "", charges: int = 1, use_bound: bool = true, take_camera: bool = false) -> Dictionary:
	return {
		"Unit": Unit,
		"type": "Unit",
		"trigger": trigger,
		"callable": callable,
		"remove_type": remove_type,
		"charges": charges,
		"use_bound": use_bound,
		"take_camera": take_camera,
	}
	
func onCreateTrigger(trigger: String, callable: Variant, remove_type: String = "", charges: int = 1, use_bound: bool = true, take_camera: bool = false) -> Dictionary:
	return {
		"type": "Regular",
		"trigger": trigger,
		"callable": callable,
		"remove_type": remove_type,
		"charges": charges,
		"use_bound": use_bound,
		"take_camera": take_camera,
	}
		
func onAddHelpfulHelmet(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, a)
	onAppendTrigger(GameFX, "Rampage", Unit.stats.bind("health", 1), "", -1, a.use_bound)
	LevelUI.UnitStatusOverlord.onAddUnitFX(Unit, "HelpfulHelmet")
	VFX.onCreateHelpfulHelmet(Unit)
	return GameFX
	
func onAddCharmingStance(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, a)
	onAppendUnitTrigger(GameFX, a.Unit, "RemoveAbility", LevelUI.UnitStatusOverlord.onRemoveUnitFX.bind(Unit, "CharmingStance"))
	LevelUI.UnitStatusOverlord.onAddUnitFX(Unit, "CharmingStance")
	return GameFX
	
func onOverrideGameFX(Unit: UnitGD, type: String) -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		if GameFX.type == type:
			effects.erase(GameFX)
			match type:
				"Daze": Combat.onRemoveDaze(GameFX)
				"Stagger": Combat.onRemoveStagger(GameFX)
			return

func onAddDazeFX(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	onOverrideGameFX(Unit, "Daze")
	var GameFX := onCreateGameFX(Unit, a)
	onAppendTrigger(GameFX, "TurnPassed", Combat.onRemoveDaze.bind(GameFX), "RemoveFX")
	return GameFX
	
func onAddStaggerFX(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	onOverrideGameFX(Unit, "Stagger")
	var GameFX := onCreateGameFX(Unit, a)
	onAppendTrigger(GameFX, "TurnPassed", Combat.onRemoveStagger.bind(GameFX), "RemoveFX")
	return GameFX
	
func onCreateGameFX(Unit: UnitGD, a: Dictionary, triggers: Array = []) -> GameFXGD:
	var GameFX := GameFXGD.new()
	effects.append(GameFX)
	GameFX.Unit = Unit
	GameFX.info = a
	GameFX.triggers = triggers
	return GameFX

func onGameFXExists(Unit: UnitGD, type: String) -> bool:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		if GameFX.type == type:
			return true
	return false

func onAIPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 1):
		onTriggerGameFX(GameFX, "NextTurn")
	
func onAIEndTurnPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 1):
		onTriggerGameFX(GameFX, "EndTurn")

func onPlayerPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 0):
		onTriggerGameFX(GameFX, "NextTurn")

func onPlayerEndTurnPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 0):
		onTriggerGameFX(GameFX, "EndTurn")

func onTriggerUnitGameFX(Unit: UnitGD, type: String, bound_args: Array = []) -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit\
	or x.triggers.any(func(y: Dictionary): return y.type == "Unit" and y.Unit == Unit)):
		onTriggerGameFX(GameFX, type, bound_args)

func onFindFirstGameFX(Unit: UnitGD, type: String) -> GameFXGD:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		if GameFX.type == type: return GameFX
	return null
