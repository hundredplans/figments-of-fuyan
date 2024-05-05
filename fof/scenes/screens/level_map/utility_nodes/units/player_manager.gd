class_name PlayerManagerGD
extends Node

var Tiles: TilesGD
var LevelMap: Node3D
var LevelUI: LevelUIGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Vision: VisionGD

func on_card_placed(hand_card: HandCardGD, Tile: TileGD) -> void:
	var skip_result: bool = LevelMap.on_skip_hand_phase_result(Tile)
	if LevelMap.game_phase == "HandPhase": LevelUI.on_ally_unit_awakened(skip_result)
	var Unit: UnitGD = Units.on_unit_awakened(hand_card.id, hand_card.tool_id, hand_card.effects, 0, Tile.obj.rotation, Tile)
	if skip_result: LevelMap.on_advance_game_phase()
	SpectateCamera.onSpectate(Unit)

func on_enemy_unit_enters_vision(Unit: UnitGD) -> void:
	LevelUI.UnitStatusOverlord.onUpdateEnemyVision(Unit, true)
	Units.onClearUnitActions()

func on_enemy_unit_exits_vision(Unit: UnitGD) -> void:
	LevelUI.UnitStatusOverlord.onUpdateEnemyVision(Unit, false)

var ActiveUnit: UnitGD
var unpassed_turns: Array
var passed_turns: Array

func on_select_active_unit(Unit: UnitGD) -> void:
	if Unit.team == 0 and ActiveUnit != Unit:
		if ActiveUnit != null: on_pass_unit_turn()
		ActiveUnit = Unit
		setUnitStatus(Unit, "TurnActive")
		LevelUI.on_pass_unit_turn_button_state(false)

func on_pass_unit_turn_pressed() -> void:
	if ActiveUnit == null:
		var SpectateUnit: UnitGD = SpectateCamera.getSpectateUnit()
		if SpectateUnit in unpassed_turns:
			on_select_active_unit(SpectateUnit)
			on_pass_unit_turn()
	else:
		on_pass_unit_turn()

func setUnitStatus(Unit: UnitGD, status: String) -> void:
	LevelUI.UnitStatusOverlord.setUnitStatusTurnStatus(Unit, status)

func on_pass_unit_turn() -> void:
	if ActiveUnit != null:
		unpassed_turns.erase(ActiveUnit)
		passed_turns.append(ActiveUnit)
		setUnitStatus(ActiveUnit, "TurnUsed")
		ActiveUnit = null
		
		if unpassed_turns.is_empty():
			LevelUI.on_pass_unit_turn_button_state(true)
			if Settings.autopass_turn: LevelMap.on_advance_game_phase()
		else: SpectateCamera.onSpectate(unpassed_turns[0])

func on_player_phase_start() -> void:
	LevelUI.PassUnitTurn.visible = true
	unpassed_turns = Units.on_units()
	passed_turns = []
		
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "StartPlayerPhase"
	for Unit in Units.on_units():
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
		Unit.attack_amount = 1
		
	onUpdateTargetAbilities(false)
	
func on_player_end_turn_phase_start() -> void:
	if UnitSelected != null: _on_unit_deselected(UnitSelected, true)
	LevelUI.PassUnitTurn.visible = false
	for Unit in passed_turns + unpassed_turns:
		Tiles.on_remove_tile_material(Unit.Tile, "")
		setUnitStatus(Unit, "TurnUsed")
	
	unpassed_turns = []
	passed_turns = []
	ActiveUnit = null
	
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "PlayerEndTurnPhase"
	for Unit in Units.on_units():
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
	onUpdateTargetAbilities(true)

func on_hurt_finished(Unit: UnitGD) -> void:
	on_check_autopass(Unit)

func on_check_autopass(Unit: UnitGD) -> void:
	if Unit.team == 0:
		if !Units.unit_actions.is_empty(): return
		if ActiveUnit != Unit: return
		
		if Unit.attack_amount == 0: on_pass_unit_turn(); return
		else:
			Tiles.onCreateMovementPaths(Unit)
			if Tiles.movement_paths.tiles.is_empty() and Tiles.movement_paths.tiles.filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, 0)).is_empty(): 
				on_pass_unit_turn()
				return
	_on_unit_selected(Unit)

func on_spectate_unit(Unit: UnitGD) -> void:
	LevelUI.on_pass_unit_turn_button_state(Unit in passed_turns or Unit != ActiveUnit)

func on_occupied_tile_inspected(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var SpectateUnit: UnitGD = SpectateCamera.getSpectateUnit()
	if LevelMap.action_lock.is_empty() and Unit == SpectateUnit:
		on_unit_selected(Unit)
	elif LevelMap.action_lock in ["", "HandRegular"] and UnitSelected == null and Unit.Tile in Vision.ally_vision:
		SpectateCamera.onSpectate(Unit)
				
var UnitSelected: UnitGD
func on_unit_selected(Unit: UnitGD) -> void:
	if UnitSelected == Unit:
		_on_unit_deselected(Unit)
	elif UnitSelected != null:
		_on_unit_deselected(UnitSelected)
		_on_unit_selected(Unit)
	else: _on_unit_selected(Unit)

func _on_unit_deselected(Unit: UnitGD, absolute: bool = false) -> void:
	if Unit != null:
		onRemoveMovementRange()
		if Unit == UnitSelected: UnitSelected = null
		if !absolute:
			Tiles.on_mouse_entered(Tiles.on_find_tile_by_raycast())
		LevelUI.setWarningText(false)
		LevelUI.onExitUnitMode()
			
func onSetMovementRange(Unit: UnitGD) -> void:
	Tiles.onCreateMovementPaths(Unit)
	var enemy_units: Array = Units.on_units(1)
	for Tile in Tiles.movement_paths.tiles:
		if Unit.attack_amount > 0:
			for _Unit in enemy_units:
				if _Unit.Tile == Tile:
					_Unit.on_enemy_in_range(true)
					continue
					
		var index: int = Tiles.movement_paths[Tile].tiles.find(Tile)
		if Tiles.movement_paths[Tile].types[index].x != 1:
			Tiles.on_set_tile_material(Tile, "MovementRange")
	
func onRemoveMovementRange() -> void:
	for Tile in Tiles.movement_paths.tiles:
		if "EnemyInRange" in Tile.tile_outlines:
			var Unit: UnitGD = Units.unit_by_tile(Tile)
			Unit.on_enemy_in_range(false)
		Tiles.on_remove_tile_material(Tile)
	Tiles.movement_paths = {"tiles": []}
	
func _on_unit_selected(Unit: UnitGD) -> void:
	if Unit.turn_status in ["TurnUnused", "TurnActive"] and Unit.team == 0 and Unit != UnitSelected:
		SpectateCamera.onSpectate(Unit)
		onSetMovementRange(Unit)
		UnitSelected = Unit
		LevelUI.onEnterUnitMode(Unit)
		LevelUI.setWarningText(ActiveUnit != null and ActiveUnit != Unit, "SkipAction")

func onDeathFinished(Deathee: UnitGD) -> void:
	if LevelMap.game_phase == "PlayerPhase":
		if Deathee.team == 0 and Deathee.Killer.team == 1 and SpectateCamera.spectate_type == "Ally":
			SpectateCamera.onSpectate("Ally")
		on_remove_unit_turn(Deathee)
		Units.Vision.on_recalculate_vision()
	
func on_remove_unit_turn(Unit: UnitGD) -> void:
	if Unit.team == 0:
		if ActiveUnit == Unit:
			on_pass_unit_turn()
			passed_turns.erase(Unit)
		else: unpassed_turns.erase(Unit); passed_turns.erase(Unit)

var tability_tiles: Dictionary
var TAbility: TargetAbilityGD
var TAbilityUnit: UnitGD
func onEnterTargetAbilityMode(Unit: UnitGD, ability: TargetAbilityGD) -> void:
	onRemoveMovementRange()
	onCreateAbilityRange(Unit, ability)
	TAbilityUnit = Unit
	TAbility = ability

func onExitTargetAbilityMode() -> void: # if unit selected null doesnt reupdate, otherwise creates tiles
	if TAbilityUnit != null:
		onRemoveAbilityRange(TAbilityUnit, TAbility)
		if UnitSelected != null:
			onSetMovementRange(UnitSelected)
			
	TAbilityUnit = null
	TAbility = null
	tability_tiles = {}
	
func onCreateAbilityRange(Unit: UnitGD, ability: TargetAbilityGD) -> void:
	tability_tiles = ability.onTargetAbilityCondition({"Unit": Unit})
	for Tile in tability_tiles["range"]:
		Tiles.on_set_tile_material(Tile, "TargetRange")
		
	for Tile in tability_tiles["affect"]:
		Tiles.on_set_tile_material(Tile, "TargetAffect")

func onRemoveAbilityRange(Unit: UnitGD, ability: TargetAbilityGD) -> void:
	tability_tiles = ability.onTargetAbilityCondition({"Unit": Unit})
	for Tile in tability_tiles["range"]:
		Tiles.on_remove_tile_material(Tile, "TargetRange")
		
	for Tile in tability_tiles["affect"]:
		Tiles.on_remove_tile_material(Tile, "TargetAffect")

var target_abilities_used: bool = true
func onPathHoveredTileSelected() -> void:
	onUpdateTargetAbilities(true)

func onUpdateTargetAbilities(state: bool) -> void:
	if state != target_abilities_used:
		target_abilities_used = state
		LevelUI.onUpdateTargetAbilities(state)
