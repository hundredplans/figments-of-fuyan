class_name GameEffectsGD
extends Node

var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var VFX: VFXGD
var Combat: CombatGD
var StatusManager: StatusManagerGD
var Tiles: TilesGD

var gfx: Array = []

const GAME_FX_INFO: Dictionary = {
	GameFXGD.DAZE: "daze",
	GameFXGD.STAGGER: "stagger",
	GameFXGD.HEAL_NEXT_TURN: "heal_next_turn",
	GameFXGD.BUFF_NEXT_TURN: "buff_next_turn",
	GameFXGD.ABILITY_ACTIVE: "ability_active",
	GameFXGD.HELPFUL_HELMET: "helpful_helmet",
	GameFXGD.CHARMING_STANCE: "charming_stance",
	GameFXGD.DEEP_WATER: "deep_water",
	GameFXGD.ENERGIZED_BOON: "energized_boon",
}

var GAME_FX_OVERRIDE: Array = [GameFXGD.DAZE, GameFXGD.STAGGER]
var GAME_FX_COMBINE: Array = [GameFXGD.HEAL_NEXT_TURN, GameFXGD.BUFF_NEXT_TURN]

func getUnitGFX(Unit: UnitGD) -> Array:
	return gfx.filter(func(x: GameFXGD): return x.Unit == Unit)

func onOverrideGFX(Unit: UnitGD, type: int) -> void:
	if type in GAME_FX_OVERRIDE and onGameFXExists(Unit, type):
		for GameFX in getUnitGFX(Unit).filter(func(x: GameFXGD): return x.type == type):
			onRemoveFX(GameFX)

func onCombineGFX(Unit: UnitGD, type: int, a: Dictionary) -> GameFXGD:
	if type in GAME_FX_COMBINE and onGameFXExists(Unit, type):
		var GameFX := onFindFirstGameFX(Unit, type)
		return GameFX.onCombine(a)
	return null

func addGFX(Unit: UnitGD, type: int, a: Dictionary = {}, custom_triggers: Array = []) -> void:
	onOverrideGFX(Unit, type)
	if !onCombineGFX(Unit, type, a):
		var GameFX := Node.new()
		GameFX.script = load("res://scenes/screens/level_map/utility_nodes/game_effects/game_effects/" + GAME_FX_INFO[type] + "_gfx.gd")
		add_child(GameFX)
		
		GameFX.setInfo(Unit, type, custom_triggers, a)
		GameFX.onCreateGFX()
		GameFX.onAfterCreateGFX()
		gfx.append(GameFX)

func onDeathFinished(Unit: UnitGD) -> void:
	var erase: Array = []
	for GameFX in getUnitGFX(Unit): erase.append(GameFX)
	for GameFX in erase: gfx.erase(GameFX)
		
func onTriggerGameFX(GameFX: GameFXGD, type: int, Unit: UnitGD = null, bound_args: Array = []) -> void:
	if GameFX != null:
		var remove_triggers: Array = []
		for Trigger in GameFX.triggers:
			if Trigger.type == type and (Unit == null or Trigger.Unit == Unit):
				if !Trigger.callable.is_null():
					Trigger.callable.callv(bound_args if Trigger.use_bound else [])
				remove_triggers.append(onRemoveTrigger.bind(GameFX, Trigger))
		for remove_callable in remove_triggers: remove_callable.call()
	
func onRemoveTrigger(GameFX: GameFXGD, Trigger: TriggerGD) -> void:
	match Trigger.remove_type:
		TriggerGD.REMOVE_FX: onRemoveFX(GameFX)
		TriggerGD.REMOVE_TRIGGER:
			GameFX.triggers.erase(Trigger)
				
func onFindRemoveFX(Unit: UnitGD, type: int) -> void:
	var GameFX: GameFXGD = onFindFirstGameFX(Unit, type)
	onRemoveFX(GameFX)
				
func onRemoveFX(GameFX: GameFXGD) -> void:
	if GameFX in gfx:
		onTriggerGameFX(GameFX, TriggerGD.REMOVE)
		gfx.erase(GameFX)
		
func onAppendTrigger(Trigger: TriggerGD) -> void:
	Trigger.GameFX.triggers.append(Trigger)

func onGameFXExists(Unit: UnitGD, type: int) -> bool:
	for GameFX in getUnitGFX(Unit):
		if GameFX.type == type: return true
	return false

func onTriggerUnitGameFX(Unit: UnitGD, type: int, bound_args: Array = []) -> void:
	for GameFX in gfx.filter(func(x: GameFXGD): return x.Unit == Unit):
		onTriggerGameFX(GameFX, type, Unit, bound_args)

func onFindFirstGameFX(Unit: UnitGD, type: int) -> GameFXGD:
	for GameFX in gfx.filter(func(x: GameFXGD): return x.Unit == Unit):
		if GameFX.type == type: return GameFX
	return null

func onFindAllGameFX(Unit: UnitGD, type: int) -> Array:
	return getUnitGFX(Unit).filter(func(x: GameFXGD): return x.type == type)
