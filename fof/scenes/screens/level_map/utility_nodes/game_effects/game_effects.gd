class_name GameEffectsGD
extends Node

var LevelUI: LevelUIGD
var VFX: VFXGD
var Combat: CombatGD
var effects: Array = []

func onAddGameFX(Unit: UnitGD, type: String, a: Dictionary, triggers: Array = []) -> void:
	var GameFX: GameFXGD
	match type:
		"Stagger": GameFX = onAddStaggerFX(Unit, a)
		"AbilityActive": GameFX = onAddAbilityActive(Unit, a, triggers)
		"IdleAbility": GameFX = onAddIdleAbility(Unit, a, triggers)
		"HelpfulHelmet": GameFX = onAddHelpfulHelmet(Unit, a)
	
	GameFX.type = type
	onTriggerGameFX(GameFX, "Instant")
		
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
	if !trigger.remove_type.is_empty():
		trigger.charges -= 1
		if trigger.charges <= 0:
			match trigger.remove_type:
				"RemoveFX":
					onTriggerGameFX(GameFX, "Remove")
					effects.erase(GameFX)
				"RemoveTrigger":
					GameFX.triggers.erase(trigger)
		
func onAddIdleAbility(Unit: UnitGD, a: Dictionary, triggers: Array) -> GameFXGD:
	triggers[0] = onCreateTrigger(triggers[0], onAddGameFX.bind(Unit, "AbilityActive", a, a.AbilityActive), "RemoveFX")
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
	
func onCreateTrigger(trigger: String, callable: Variant, remove_type: String = "", charges: int = 1, use_bound: bool = true) -> Dictionary:
	return {
		"trigger": trigger,
		"callable": callable,
		"remove_type": remove_type,
		"charges": charges,
		"use_bound": use_bound,
	}
		
func onAddHelpfulHelmet(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, a)
	onAppendTrigger(GameFX, "Rampage", Unit.stats.bind("health", 1), "", -1, a.use_bound)
	LevelUI.UnitStatusOverlord.onAddUnitFX(Unit, "HelpfulHelmet")
	VFX.onCreateHelpfulHelmet(Unit)
	return GameFX
	
func onAddStaggerFX(Unit: UnitGD, a: Dictionary) -> GameFXGD:
	var GameFX := onCreateGameFX(Unit, a)
	onAppendTrigger(GameFX, "NextTurn", Combat.onRemoveStagger.bind(GameFX), "RemoveFX")
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
		onTriggerGameFX(GameFX, "NextTurn")

func onPlayerPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 0):
		onTriggerGameFX(GameFX, "NextTurn")

func onPlayerEndTurnPhaseStart() -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit.team == 0):
		onTriggerGameFX(GameFX, "EndTurn")

func onTriggerUnitGameFX(Unit: UnitGD, type: String, bound_args: Array = []) -> void:
	for GameFX in effects.filter(func(x: GameFXGD): return x.Unit == Unit):
		onTriggerGameFX(GameFX, type, bound_args)
