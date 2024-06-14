class_name PlayerManagerGD
extends Node

var Tiles: TilesGD
var LevelMap: Node3D
var LevelUI: LevelUIGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Vision: VisionGD
var VFX: VFXGD
var StatusManager: StatusManagerGD

func onSetupAllyPassedTurns(Unit: UnitGD) -> void:
	if Unit.team == 0:
		if Unit.rarity == 7: unpassed_turns.append(Unit)
		else:
			passed_turns.append(Unit)
			Units.setUnitStatus(Unit, UnitGD.TURN_USED)
			
func on_card_placed(hand_card: HandCardGD, Tile: TileGD) -> void:
	var skip_result: bool = LevelMap.on_skip_hand_phase_result(Tile)
	if LevelMap.game_phase == "HandPhase": LevelUI.on_ally_unit_awakened(skip_result)
	
	var Unit: UnitGD = await Units.onUnitAwakened(hand_card.id, hand_card.tool_id, hand_card.effects, 0, Tile.obj.rotation, Tile)
	if skip_result: LevelMap.on_advance_game_phase()
	
	SpectateCamera.onSpectate(Unit)
	if Unit.rarity != 7:
		Units.onPushArgDelay(Unit, Units.ARRIVE_EFFECT_DELAY_DURATION, 
		SpectateCamera.onSpectate.bind(Units.onFindClosestAdjacentUnit(Unit, TeamRelationGD.new(Unit.team, "Ally"))))
	else:
		Units.onPushFrontDelay(Units.ARRIVE_EFFECT_DELAY_DURATION)
	
func on_enemy_unit_enters_vision(Unit: UnitGD, _Unit: UnitGD) -> void:
	StatusManager.onUpdateEnemyVision(Unit, true)
	Units.onEnemyDiscoveredClearUnitActions()
	LevelUI.onEnemySpotted(Unit, _Unit)
	VFX.onUpdateVFXVision(Unit, true)

func on_enemy_unit_exits_vision(Unit: UnitGD) -> void:
	StatusManager.onUpdateEnemyVision(Unit, false)
	VFX.onUpdateVFXVision(Unit, false)

var ActiveUnit: UnitGD
var unpassed_turns: Array
var passed_turns: Array

func on_select_active_unit(Unit: UnitGD) -> void:
	if Unit.team == 0 and ActiveUnit != Unit:
		if ActiveUnit != null: on_pass_unit_turn()
		ActiveUnit = Unit
		Units.setUnitStatus(Unit, UnitGD.TURN_ACTIVE)
		LevelUI.on_pass_unit_turn_button_state(false)

func on_pass_unit_turn_pressed() -> void:
	if ActiveUnit == null:
		var SpectateUnit: UnitGD = SpectateCamera.SpectateUnit
		if SpectateUnit in unpassed_turns:
			on_select_active_unit(SpectateUnit)
			on_pass_unit_turn()
	else:
		on_pass_unit_turn()

func on_pass_unit_turn() -> void:
	if ActiveUnit != null:
		unpassed_turns.erase(ActiveUnit)
		passed_turns.append(ActiveUnit)
		
		if !ActiveUnit.is_dead: Units.setUnitStatus(ActiveUnit, UnitGD.TURN_USED)
		if unpassed_turns.is_empty():
			ActiveUnit = null
			LevelUI.on_pass_unit_turn_button_state(true)
			LevelMap.on_advance_game_phase()
		elif LevelMap.game_phase == "PlayerPhase":
			if ActiveUnit == UnitSelected: _on_unit_deselected(ActiveUnit)
			SpectateCamera.onSpectate(Units.onFindClosestUnitFromUnits(ActiveUnit, unpassed_turns))
			ActiveUnit = null
func on_player_phase_start() -> void:
	passed_turns = []
	unpassed_turns = []
	var AppliedBy := AppliedByGD.new("StartPlayerPhase")
	for Unit in Units.on_units():
		if Unit.turn_status == UnitGD.TURN_UNUSED: unpassed_turns.append(Unit)
		else: passed_turns.append(Unit)
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
		Unit.attack_amount = 1
	
func on_player_end_turn_phase_start() -> void:
	if UnitSelected != null: _on_unit_deselected(UnitSelected, true)
	for Unit in unpassed_turns:
		on_select_active_unit(Unit)
	on_pass_unit_turn()
	
	for Unit in passed_turns.filter(func(x: UnitGD): return !x.is_dead):
		Tiles.on_remove_tile_material(Unit.Tile, "")
		Units.setUnitStatus(Unit, UnitGD.TURN_USED)
	
	unpassed_turns = []
	passed_turns = []
	ActiveUnit = null
	
	var AppliedBy := AppliedByGD.new("PlayerEndTurnPhase")
	for Unit in Units.on_units():
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
		if Unit.past_path_set:
			Units.setPastPath(Unit, false)
		Unit.past_path_info = {}
		Unit.past_path_counter = 0

func on_spectate_unit(Unit: UnitGD) -> void:
	LevelUI.on_pass_unit_turn_button_state(Unit in passed_turns or Unit != ActiveUnit)

func on_occupied_tile_inspected(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var SpectateUnit: UnitGD = SpectateCamera.SpectateUnit
	if LevelMap.action_lock.is_empty() and Unit.team == 0 and (Unit == SpectateUnit or Unit == UnitSelected):
		on_unit_selected(Unit)
	elif LevelMap.action_lock in ["", "HandRegular"] and UnitSelected == null and Unit.Tile in Vision.getTeamVision():
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
	if Unit != null and Unit.team == 0:
		onRemoveMovementRange()
		if Unit == UnitSelected: UnitSelected = null
		if !absolute:
			Tiles.on_mouse_entered(Tiles.on_find_tile_by_raycast())
		LevelUI.setWarningText(false)
		LevelUI.onExitUnitMode()
	
var unit_movement_paths: Array = []
func onSetMovementRange(Unit: UnitGD) -> void:
	unit_movement_paths = Tiles.onCreateMovementPaths(Unit)
	var can_attack: bool = Unit.onCanAttack()
	for movement_path in unit_movement_paths:
		if movement_path.is_attack:
			if can_attack: movement_path.DestinationTile.Unit.on_enemy_in_range(true)
		Tiles.setTileOutline(movement_path.DestinationTile, "MovementRange")
	
func onRemoveMovementRange() -> void:
	for movement_path in unit_movement_paths:
		if movement_path.DestinationTile.Unit != null:
			movement_path.DestinationTile.Unit.on_enemy_in_range(false)
		Tiles.setTileOutline(movement_path.DestinationTile, "MovementRange", true)
	
func _on_unit_selected(Unit: UnitGD) -> void:
	if Unit.turn_status in [UnitGD.TURN_UNUSED, UnitGD.TURN_ACTIVE] and Unit.team == 0 and Unit != UnitSelected:
		SpectateCamera.onSpectate(Unit)
		onSetMovementRange(Unit)
		UnitSelected = Unit
		LevelUI.onEnterUnitMode(Unit)
		LevelUI.setWarningText(ActiveUnit != null and ActiveUnit != Unit, "SkipAction")

func onDeathFinished(Deathee: UnitGD, AppliedBy: AppliedByGD) -> void:
	if LevelMap.game_phase == "PlayerPhase":
		if Deathee.team == 0 and SpectateCamera.SpectateUnit != null and SpectateCamera.SpectateUnit.team == 0 and AppliedBy.type != "HelpfulHelmet":
			var unit_distances: Array = Units.on_awakened_units().map(func(x: UnitGD): return {"Unit": x, "distance": Tiles.tile_distance(x.Tile, Deathee.Tile)})
			unit_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance > y.distance)
			if unit_distances.size() > 0:
				SpectateCamera.onSpectate(unit_distances[0].Unit)
		on_remove_unit_turn(Deathee)
		if Deathee.team == 0 and unpassed_turns.is_empty():
			Units.unit_actions_after.append(LevelMap.on_advance_game_phase)
	
func on_remove_unit_turn(Unit: UnitGD) -> void:
	if Unit.team == 0:
		if ActiveUnit == Unit:
			on_pass_unit_turn()
			passed_turns.erase(Unit)
		else: unpassed_turns.erase(Unit); passed_turns.erase(Unit)

var TAbility: TargetAbilityGD
var TAbilityUnit: UnitGD
func onEnterTargetAbilityMode(Unit: UnitGD, ability: TargetAbilityGD) -> void:
	onRemoveMovementRange()
	onCreateAbilityRange(Unit, ability)
	TAbilityUnit = Unit
	TAbility = ability
	
	if ability.change_camera:
		SpectateCamera.onSpectate(Units.unit_by_tile(ability.tiles["affect"][0]))

func onExitTargetAbilityMode() -> void: # if unit selected null doesnt reupdate, otherwise creates tiles
	if TAbilityUnit != null:
		onRemoveAbilityRange(TAbilityUnit, TAbility)
		if UnitSelected != null:
			onSetMovementRange(UnitSelected)
	
	if TAbility.change_camera: SpectateCamera.onSpectate(TAbilityUnit)
	TAbilityUnit = null
	TAbility = null
	
func onCreateAbilityRange(_Unit: UnitGD, ability: TargetAbilityGD) -> void:
	ability.onTargetAbilityCondition()
	for Tile in ability.tiles["range"]:
		Tiles.on_set_tile_material(Tile, "TargetRange")
		
	for Tile in ability.tiles["affect"]:
		Tiles.on_set_tile_material(Tile, "TargetAffect")

func onRemoveAbilityRange(_Unit: UnitGD, ability: TargetAbilityGD) -> void:
	for Tile in ability.tiles["range"]:
		Tiles.on_remove_tile_material(Tile, "TargetRange")
		
	for Tile in ability.tiles["affect"]:
		Tiles.on_remove_tile_material(Tile, "TargetAffect")

func onBeginUnitMovement(DestinationTile: TileGD) -> void:
	var movement_path := MovementPathGD.onFindTile(DestinationTile, unit_movement_paths)
	on_select_active_unit(UnitSelected)
	for fneighbour in movement_path.fneighbours:
		Units.movement_outline_tiles.append(fneighbour.Tile)
		if fneighbour.Tile.Unit == null:
			Units.onMoveToTile(UnitSelected, fneighbour, movement_path)
			fneighbour.Tile.Effects.onRemoveHeightDropLabel()
		else: Units.onAttackEnemy(UnitSelected, fneighbour.Tile)
	_on_unit_deselected(UnitSelected, true)
		
