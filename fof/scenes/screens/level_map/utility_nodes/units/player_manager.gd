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
	if ActiveUnit != Unit:
		ActiveUnit = Unit
		ActiveUnit.UnitStatus.on_set_status_box_modulate("TurnActive")
		LevelUI.on_pass_unit_turn_button_state(false)

func on_pass_unit_turn() -> void:
	unpassed_turns.erase(ActiveUnit)
	passed_turns.append(ActiveUnit)
	ActiveUnit.UnitStatus.on_set_status_box_modulate("TurnUsed")
	Tiles.on_remove_tile_material(ActiveUnit.Tile, "TurnActive")
	Tiles.on_set_tile_material(ActiveUnit.Tile, "TurnUsed")
	
	ActiveUnit = null
	
	if unpassed_turns.is_empty(): 
		LevelUI.on_pass_unit_turn_button_state(true)
		# check with settings here if to autopass the full turn
		

func on_player_phase_start() -> void:
	LevelUI.PassUnitTurn.visible = true
	unpassed_turns = Units.on_units()
	passed_turns = []
	
	var units: Array = Units.on_units()
	for i in range(units.size()):
		units[i].UnitStatus.on_set_status_box_modulate("Ally")
	
func on_player_end_turn_phase_start() -> void:
	LevelUI.PassUnitTurn.visible = false
	for Unit in passed_turns + unpassed_turns:
		Tiles.on_remove_tile_material(Unit.Tile, "")
	
	unpassed_turns = []
	passed_turns = []
	
	for Unit in Units.on_units():
		Unit.UnitStatus.on_set_status_box_modulate("TurnUsed")

func on_attack_finished(Unit: UnitGD) -> void:
	if ActiveUnit == Unit: on_pass_unit_turn()

func on_unit_travel_finished(Unit: UnitGD) -> void:
	if ActiveUnit == Unit:
		var tiles: Dictionary = Tiles.tiles_in_speed(Unit, false)
		if tiles.in_speed.is_empty() and !tiles.in_range.any(func(x: TileGD): return Units.unit_by_tile_bool(x)):
			on_pass_unit_turn()
		else: Tiles.on_set_tile_material(Unit.Tile, "TurnActive")
