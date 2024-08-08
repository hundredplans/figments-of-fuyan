class_name NeutralManagerGD
extends Node

var LevelMap: LevelMapGD
var neutral_units: Array = []

func onNeutralPhaseStart() -> void:
	if neutral_units.is_empty(): LevelMap.onAdvanceGamePhase()
	else: print("neutral unit exists")

func onUnitAwakened(Unit: UnitGD) -> void:
	if Unit.team == 2: neutral_units.append(Unit)
