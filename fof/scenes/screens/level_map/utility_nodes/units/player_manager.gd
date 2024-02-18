class_name PlayerManagerGD
extends Node

var Tiles: TilesGD
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD
var SpectateCamera: Camera3D
var Units: UnitsGD

func on_card_placed(hand_card: HandCardGD, Tile: TileGD) -> void:
	if LevelMap.game_phase == "HandPhase": LevelUI.on_ally_unit_awakened()
	Units.on_unit_awakened(hand_card.id, hand_card.tool_id, hand_card.effects, 0, Tile.info.obj.rotation, Tile)
	SpectateCamera.on_spectate("Unit", Units.on_units().size() - 1)

func on_enemy_unit_enters_vision(Unit: UnitGD) -> void:
	Unit.UnitStatus.visible = true
	Units.on_empty_move_queue()

func on_enemy_unit_exits_vision(Unit: UnitGD) -> void:
	Unit.UnitStatus.visible = false

var ActiveUnit: UnitGD
var unpassed_turns: Array
var passed_turns: Array

func on_select_active_unit(Unit: UnitGD) -> void:
	ActiveUnit = Unit
	ActiveUnit.UnitStatus.on_set_status_box_modulate("TurnActive")
	Tiles.on_set_tile_material(ActiveUnit.Tile, "TurnActive")

func on_pass_unit_turn() -> void:
	unpassed_turns.erase(ActiveUnit)
	passed_turns.append(ActiveUnit)
	ActiveUnit.UnitStatus.on_set_status_box_modulate("TurnUsed")
	ActiveUnit.Tile.tile_state.erase("TurnActive")
	Tiles.on_set_tile_material(ActiveUnit.Tile, "TurnUsed")
	
	ActiveUnit = null
	
	if !unpassed_turns.is_empty():
		on_select_active_unit(unpassed_turns[0])
	else: # do whatever happens when no units have turns here
		pass

func on_player_phase_start() -> void:
	LevelUI.PassUnitTurn.visible = true
	unpassed_turns = Units.on_units()
	passed_turns = []
	
	var units: Array = Units.on_units()
	for i in range(units.size()):
		units[i].UnitStatus.on_set_status_box_modulate("Ally")
		if i == 0: on_select_active_unit(units[0])
	
func on_player_end_turn_phase_start() -> void:
	LevelUI.PassUnitTurn.visible = false
	unpassed_turns = []
	passed_turns = []
	
	for Unit in Units.on_units():
		Unit.UnitStatus.on_set_status_box_modulate("TurnUsed")
