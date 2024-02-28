class_name PlayerManagerGD
extends Node

var Tiles: TilesGD
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD
var SpectateCamera: Camera3D
var Units: UnitsGD

func on_card_placed(hand_card: HandCardGD, Tile: TileGD) -> void:
	var skip_result: bool = LevelMap.on_skip_hand_phase_result()
	if LevelMap.game_phase == "HandPhase": LevelUI.on_ally_unit_awakened(skip_result)
	Units.on_unit_awakened(hand_card.id, hand_card.tool_id, hand_card.effects, 0, Tile.info.obj.rotation, Tile)
	SpectateCamera.on_spectate("Unit", Units.on_units().size() - 1)
	if skip_result: LevelMap.on_advance_game_phase()

func on_enemy_unit_enters_vision(Unit: UnitGD) -> void:
	Unit.UnitStatus.visible = true
	Units.on_clear_event_queue()

func on_enemy_unit_exits_vision(Unit: UnitGD) -> void:
	Unit.UnitStatus.visible = false

var ActiveUnit: UnitGD
var unpassed_turns: Array
var passed_turns: Array

func on_select_active_unit(Unit: UnitGD) -> void:
	if ActiveUnit != Unit:
		if ActiveUnit != null: on_pass_unit_turn()
		ActiveUnit = Unit
		ActiveUnit.UnitStatus.on_set_status_box_modulate("TurnActive")
		LevelUI.on_pass_unit_turn_button_state(false)

func on_pass_unit_turn() -> void:
	if ActiveUnit != null:
		unpassed_turns.erase(ActiveUnit)
		passed_turns.append(ActiveUnit)
		ActiveUnit.UnitStatus.on_set_status_box_modulate("TurnUsed")
		Tiles.on_remove_tile_material(ActiveUnit.Tile, "TurnActive")
		Tiles.on_set_tile_material(ActiveUnit.Tile, "TurnUsed")
		
		ActiveUnit = null
		
		if unpassed_turns.is_empty():
			LevelUI.on_pass_unit_turn_button_state(true)
			if Settings.autopass_turn: LevelMap.on_advance_game_phase()
		else: SpectateCamera.on_spectate("Unit", Units.on_unit_team_index(unpassed_turns[0]))
		

func on_player_phase_start() -> void:
	LevelUI.PassUnitTurn.visible = true
	unpassed_turns = Units.on_units()
	passed_turns = []
	
	var units: Array = Units.on_units()
	for i in range(units.size()):
		units[i].UnitStatus.on_set_status_box_modulate("Ally")
	
func on_player_end_turn_phase_start() -> void:
	if UnitSelected != null: _on_unit_deselected(UnitSelected, true)
	LevelUI.PassUnitTurn.visible = false
	for Unit in passed_turns + unpassed_turns:
		Tiles.on_remove_tile_material(Unit.Tile, "")
	
	unpassed_turns = []
	passed_turns = []
	ActiveUnit = null
	
	for Unit in Units.on_units():
		Unit.UnitStatus.on_set_status_box_modulate("TurnUsed")

func on_attack_finished(Unit: UnitGD) -> void:
	on_check_autopass(Unit)

func on_check_autopass(Unit: UnitGD) -> void:
	if !Units.event_queue.is_empty(): return
	if ActiveUnit != Unit: return
	
	if Settings.autopass_unit_turn:
		if Unit.attack_amount == 0: on_pass_unit_turn(); return
		else: 
			Tiles.on_create_movement_paths(Unit)
			if Tiles.movement_paths.tiles.is_empty() and Tiles.movement_paths.tiles.filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, 0)).is_empty(): 
				on_pass_unit_turn()
				return
	
	Tiles.on_set_tile_material(Unit.Tile, "TurnActive")
	_on_unit_selected(Unit)

func on_spectate_unit(Unit: UnitGD) -> void:
	LevelUI.on_pass_unit_turn_button_state(Unit in passed_turns or Unit != ActiveUnit)

func on_occupied_tile_inspected(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	if Unit.team == 0:
		match LevelMap.game_phase:
			"PlayerPhase":
				on_unit_selected(Unit)
	else:
		pass

var UnitSelected: UnitGD
func on_unit_selected(Unit: UnitGD) -> void:
	if UnitSelected == Unit:
		_on_unit_deselected(Unit)
	elif UnitSelected != null:
		_on_unit_deselected(UnitSelected)
		_on_unit_selected(Unit)
	else: _on_unit_selected(Unit)

func _on_unit_deselected(Unit: UnitGD, absolute: bool = false) -> void:
	Tiles.on_remove_tile_material(Unit.Tile)
	for Tile in Tiles.movement_paths.tiles:
		Tiles.on_remove_tile_material(Tile)
	Tiles.movement_paths = {"tiles": []}
	if Unit == UnitSelected: UnitSelected = null
	if !absolute:
		Tiles.on_force_mouse_entered()
		
	LevelUI.get_node("SkipReminder").visible = false
	
func _on_unit_selected(Unit: UnitGD) -> void:
	if Unit.Tile.unit_state() in ["TurnActive", "SpectatingUnit"]:
		Tiles.on_set_tile_material(Unit.Tile, "UnitSelected")
		Tiles.on_create_movement_paths(Unit)
		var enemy_tiles: Array = Units.on_units(1).map(func(x: UnitGD): return x.Tile)
		for Tile in Tiles.movement_paths.tiles:
			if Unit.attack_amount > 0 and Tile in enemy_tiles:
				Tiles.on_set_tile_material(Tile, "EnemyInRange")
			else: Tiles.on_set_tile_material(Tile, "MovementRange")
			
		UnitSelected = Unit
		LevelUI.get_node("SkipReminder").visible = ActiveUnit != null and ActiveUnit != Unit

func on_death_finished(Killer: String, Deathee: UnitGD) -> void:
	if Killer == "Unit" and Deathee.Killer.team == 0: on_check_autopass(Deathee.Killer)
	on_remove_unit_turn(Deathee)
	if Deathee.team == 0:
		SpectateCamera.unit_positions.remove_at(Deathee.get_index())
		if !unpassed_turns.is_empty() and SpectateCamera.unit_spectate_id == Deathee.get_index():
			SpectateCamera.on_spectate("Unit", unpassed_turns[0].get_index())
			
	if Units.on_units().is_empty(): print("DIE")
		
func on_unit_awakened(_Unit: UnitGD) -> void:
	SpectateCamera.unit_positions.append(SpectateCamera.total_progress)
	
func on_remove_unit_turn(Unit: UnitGD) -> void:
	if Unit.team == 0:
		if ActiveUnit == Unit:
			on_pass_unit_turn()
			Tiles.on_remove_tile_material(Unit.Tile, "TurnUsed")
			passed_turns.erase(Unit)
		else: unpassed_turns.erase(Unit); passed_turns.erase(Unit)
