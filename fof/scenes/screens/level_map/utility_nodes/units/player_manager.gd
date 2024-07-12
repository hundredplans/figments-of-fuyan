class_name PlayerManagerGD
extends Node

var Tiles: TilesGD
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD
var SpectateCamera: Node3D
var Units: UnitsGD
var Vision: VisionGD
var VFX: VFXGD
var StatusManager: StatusManagerGD
var ActionManager: ActionManagerGD
var TriggerManager: TriggerManagerGD

var graveyard_cards: Array = []

func onSetupAllyPassedTurns(Unit: UnitGD) -> void:
	if Unit.team == 0:
		if Unit.rarity == 7: unpassed_turns.append(Unit)
		else:
			passed_turns.append(Unit)
			Units.setUnitStatus(Unit, UnitGD.TURN_USED)
			
func on_card_placed(hand_card: HandCardGD, Tile: TileGD) -> void:
	var skip_result: bool = LevelMap.on_skip_hand_phase_result(Tile)
	if LevelMap.game_phase == "HandPhase": LevelUI.on_ally_unit_awakened(skip_result)
	
	LevelMap.setInputLock(LevelMapGD.UNIT_ACTION)
	var Unit: UnitGD = await Units.onUnitAwakened(hand_card.id, hand_card.tool_id, hand_card.effects, 0, Tile.obj.rotation, Tile)
	Unit.was_placed = true
	TriggerManager.onUnitTrigger(Unit, TriggerGD.CARD_PLACED, [hand_card])
	if skip_result: LevelMap.on_advance_game_phase()
	
	SpectateCamera.onSpectate(Unit)
	if Unit.rarity != 7:
		var callable: Callable = SpectateCamera.onSpectate.bind(Units.onFindClosestAdjacentUnit(Unit, TeamRelationGD.new(Unit.team, "Ally")))
		ActionManager.onAddAction(ArgDelayActionGD.new(Callable(), callable, true, DelayGD.new(Units.ARRIVE_EFFECT_DELAY_DURATION)), ActionManagerGD.PUSH)
	else:
		ActionManager.onAddAction(ArgDelayActionGD.new(Callable(), onAfterChampionPlaced, true, DelayGD.new(Units.ARRIVE_EFFECT_DELAY_DURATION)), ActionManagerGD.PUSH)
	
func onAfterChampionPlaced() -> void:
	if LevelMap.game_phase == "StartPhase":
		LevelMap.on_change_game_phase("AfterStartPhase")
	
func on_enemy_unit_enters_vision(Unit: UnitGD, _Unit: UnitGD) -> void:
	StatusManager.onUpdateEnemyVision(Unit, true)
	ActionManager.onEnemyDiscovered()
	VFX.onUpdateVFXVision(Unit, true)
		
	if LevelMap.game_phase == "PlayerPhase":
		LevelUI.onEnemySpotted(Unit, _Unit)

func on_enemy_unit_exits_vision(Unit: UnitGD) -> void:
	StatusManager.onUpdateEnemyVision(Unit, false)
	VFX.onUpdateVFXVision(Unit, false)

var ActiveUnit: UnitGD
var unpassed_turns: Array
var passed_turns: Array

func onSelectActiveUnit(Unit: UnitGD) -> void:
	if Unit != ActiveUnit:
		if ActiveUnit != null: on_pass_unit_turn()
		ActiveUnit = Unit
		Units.setUnitStatus(Unit, UnitGD.TURN_ACTIVE)
		LevelUI.on_pass_unit_turn_button_state(false)

func on_pass_unit_turn_pressed() -> void:
	if ActiveUnit == null:
		var SpectateUnit: UnitGD = SpectateCamera.SpectateUnit
		if SpectateUnit in unpassed_turns:
			onSelectActiveUnit(SpectateUnit)
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
			SpectateCamera.onSpectate(Units.onFindClosestUnitFromUnits(ActiveUnit, unpassed_turns))
			ActiveUnit = null
func onPlayerPhaseStart() -> void:
	passed_turns = []
	unpassed_turns = []
	var AppliedBy := AppliedByGD.new("StartPlayerPhase")
	
	for Unit in Units.on_units():
		if Unit.turn_status == UnitGD.TURN_UNUSED: unpassed_turns.append(Unit)
		else: passed_turns.append(Unit)
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
		Unit.attack_amount = 1
	
	LevelMap.setInputLock()
	
func onPlayerEndTurnPhaseStart() -> void:
	for Unit in unpassed_turns:
		onSelectActiveUnit(Unit)
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

	onUnitMode()
	LevelMap.setInputLock(LevelMap.AI_PHASE)

func on_spectate_unit(Unit: UnitGD) -> void:
	LevelUI.on_pass_unit_turn_button_state(Unit in passed_turns or Unit != ActiveUnit)

func on_occupied_tile_inspected(Tile: TileGD) -> void:
	var Unit: UnitGD = Units.unit_by_tile(Tile)
	var SpectateUnit: UnitGD = SpectateCamera.SpectateUnit
	
	if Unit != SpectateUnit and LevelMap.verifyLock(LevelMap.SPECTATE_TILE) and Unit.Tile in Vision.getTeamVision():
		SpectateCamera.onSpectate(Unit)
	
var PreviousUnitSelected: UnitGD
var unit_movement_paths: Array = []
func onSetMovementRange(Unit: UnitGD) -> void:
	unit_movement_paths = Tiles.onCreateMovementPaths(Unit)
	var can_attack: bool = Unit.onCanAttack()
	for movement_path in unit_movement_paths:
		if "MovementPath" not in movement_path.DestinationTile.tile_outlines:
			if movement_path.is_attack:
				if can_attack: movement_path.DestinationTile.Unit.on_enemy_in_range(true)
			else: Tiles.setTileOutline(movement_path.DestinationTile, "MovementRange")
	
func onRemoveMovementRange() -> void:
	for movement_path in unit_movement_paths:
		if movement_path.DestinationTile.Unit != null:
			movement_path.DestinationTile.Unit.on_enemy_in_range(false)
		Tiles.setTileOutline(movement_path.DestinationTile, "MovementRange", true)

func onDeathFinished(Deathee: UnitGD, AppliedBy: AppliedByGD) -> void:
	if LevelMap.game_phase == "PlayerPhase":
		if Deathee.team == 0 and SpectateCamera.SpectateUnit != null and SpectateCamera.SpectateUnit.team == 0 and AppliedBy.type != "HelpfulHelmet":
			var unit_distances: Array = Units.on_awakened_units().map(func(x: UnitGD): return {"Unit": x, "distance": Tiles.tile_distance(x.Tile, Deathee.Tile)})
			unit_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance > y.distance)
			if unit_distances.size() > 0:
				SpectateCamera.onSpectate(unit_distances[0].Unit)
		on_remove_unit_turn(Deathee)
		if Deathee.team == 0 and unpassed_turns.is_empty():
			ActionManager.onAddAction(DelayActionGD.new(LevelMap.on_advance_game_phase, false))
			
	if Deathee.team == 0: graveyard_cards.append(Deathee.base_card)
	
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

enum {
	EXIT_TARGET_ABILITY_BUTTON,
	EXIT_TARGET_ABILITY_OTHER,
}

func onExitUnitBoxMode(exit_type: int = 0) -> void: # if unit selected null doesnt reupdate, otherwise creates tiles
	if TAbilityUnit != null:
		onRemoveAbilityRange(TAbilityUnit, TAbility)
		var UnitSelected := getUnitSelected()
		if UnitSelected != null and exit_type == EXIT_TARGET_ABILITY_BUTTON: onSetMovementRange(UnitSelected)
	
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
	onSelectActiveUnit(SpectateCamera.SpectateUnit)
	LevelUI.setWarningText(false)
	for fneighbour in movement_path.fneighbours:
		Units.movement_outline_tiles.append(fneighbour.Tile)
		if fneighbour.Tile.Unit == null:
			ActionManager.onAddAction(MoveActionGD.new(ActiveUnit, fneighbour, movement_path, true))
			fneighbour.Tile.Effects.onRemoveDeathPathLabel()
		else: ActionManager.onAddAction(AttackActionGD.new(ActiveUnit, fneighbour.Tile, true, null))
	ActionManager.onAddAction(MoveFinishActionGD.new(ActiveUnit, movement_path, true), ActionManagerGD.APPEND_MF)

func onUnitMode(Unit: UnitGD = getUnitSelected(), enter: bool = false) -> void:
	if Unit != null and Unit.team == 0 and LevelMap.game_phase in ["PlayerPhase", "PlayerEndTurnPhase"] and LevelMap.verifyLock(LevelMapGD.NULL_VERIFY):
		if enter and PreviousUnitSelected != Unit:
			if Unit.turn_status != UnitGD.TURN_USED: onSetMovementRange(Unit)
			LevelUI.onEnterUnitMode(Unit)
			PreviousUnitSelected = Unit
			
		elif !enter and Unit == PreviousUnitSelected:
			onRemoveMovementRange()
			LevelUI.onExitUnitMode()
			PreviousUnitSelected = null

func onRefreshMovementRange() -> void:
	var Unit: UnitGD = getUnitSelected()
	if Unit != null:
		onRemoveMovementRange()
		onSetMovementRange(Unit)

func getUnitSelected() -> UnitGD:
	if LevelMap.game_phase in ["PlayerPhase", "PlayerEndTurnPhase"] and SpectateCamera.SpectateUnit != null and SpectateCamera.SpectateUnit.team == 0:
		return SpectateCamera.SpectateUnit
	return null
