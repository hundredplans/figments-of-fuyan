class_name TriggerManagerGD
extends Node

var GameEffects: GameEffectsGD
var Boons: BoonsGD
var Units: UnitsGD
var Tools: ToolsGD
var ObjectManager: ObjectManagerGD
var UniqueTiles: UniqueTilesGD

func onUnitTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD = null) -> void:
	if trigger == TriggerGD.LAST_WILL:
		print()
	GameEffects.onTriggerUnitGameFX(Unit, trigger, args)
	Boons.onTrigger(Unit, trigger, args)
	Tools.onTrigger(Unit, trigger, args)
	ObjectManager.onTrigger(Unit, trigger, args)
	UniqueTiles.onTrigger(Unit, trigger, args)

func onGlobalTrigger(trigger: int, args: TriggerInfoGD) -> void:
	Boons.onTrigger(null, trigger, args)
	Tools.onTrigger(null, trigger, args)
	ObjectManager.onTrigger(null, trigger, args)
	UniqueTiles.onTrigger(null, trigger, args)

func onHandPhaseStart() -> void:
	for Unit in Units.on_units(TeamRelationGD.new(0)).filter(func(x: UnitGD): return !(x.was_placed and x.turns_alive == 0)):
		onUnitTrigger(Unit, TriggerGD.NEXT_TURN)
	onGlobalTrigger(TriggerGD.START_TURN_GLOBAL, TurnTriggerInfoGD.new(TeamRelationGD.new(0)))
	
func onPlayerEndTurnPhaseStart() -> void:
	for Unit in Units.on_units(TeamRelationGD.new(0)):
		onUnitTrigger(Unit, TriggerGD.END_TURN)
	onGlobalTrigger(TriggerGD.END_TURN_GLOBAL, TurnTriggerInfoGD.new(TeamRelationGD.new(0)))
	
func onAIPhaseStart() -> void:
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		onUnitTrigger(Unit, TriggerGD.NEXT_TURN)
	onGlobalTrigger(TriggerGD.START_TURN_GLOBAL, TurnTriggerInfoGD.new(TeamRelationGD.new(1)))
	
func onAIEndTurnPhaseStart() -> void:
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		onUnitTrigger(Unit, TriggerGD.END_TURN)
	onGlobalTrigger(TriggerGD.END_TURN_GLOBAL, TurnTriggerInfoGD.new(TeamRelationGD.new(1)))
	

	
