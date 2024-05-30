class_name UnitsGD
extends Node3D

var GameEffects: GameEffectsGD
var VFX: VFXGD
var Deck: DeckGD
var SpectateCamera: Node3D
var GameState: GameStateGD
var Vision: VisionGD
var Random: RandomGD
var Tiles: TilesGD
var LevelMap: Node3D
var LevelUI: LevelUIGD
var Combat: CombatGD


@onready var Postmortem: Node3D = $Postmortem
@onready var AIManager: AIManagerGD = $BotManager
@onready var PlayerManager: PlayerManagerGD = $PlayerManager
@onready var FieldedUnits: Node3D = $FieldedUnits

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")

const ARRIVE_EFFECT_DELAY_DURATION: float = 2
func on_unit_awakened(id: int, tool_id: int, effects: Array, team: int, rot: int, tile: TileGD) -> UnitGD:
	if !unit_by_tile_bool(tile):
		var Unit: UnitGD = UnitScene.instantiate()
		Unit.Units = self
		Unit.Vision = Vision
		Unit.SpectateCamera = SpectateCamera
		Unit.Tiles = Tiles
		FieldedUnits.add_child(Unit)
		
		Unit.on_create_unit(id, tool_id, effects, team, rot, tile) # Takes around 2.2 seconds
		Unit.Model.movement_finished.connect(on_movement_finished.bind(Unit))
		Unit.Model.drop_calculate_damage.connect(on_drop_calculate_damage.bind(Unit))
		Unit.Model.attack_finished.connect(on_attack_finished.bind(Unit))
		Unit.Model.death_finished.connect(on_death_finished.bind(Unit))
		Unit.Model.hurt_finished.connect(on_hurt_finished.bind(Unit))
		
		LevelUI.UnitStatusOverlord.onUnitAwakened(Unit)
		
		Unit.on_arrive(team == 0 or Unit.getVisibleEnemies().size() > 0)
		AIManager.onUnitAwakened(Unit)
		Unit.finished_awakening = true
		Combat.onArrive(Unit)
		PlayerManager.onSetupAllyPassedTurns(Unit)
		Combat.onRecalculateTargetAbilities()
		return Unit
	return null
		

func on_start_phase_start() -> void:
	AIManager.LevelMap = LevelMap
	AIManager.Units = self
	AIManager.Vision = Vision
	AIManager.Tiles = Tiles
	AIManager.SpectateCamera = SpectateCamera
	PlayerManager.Units = self
	PlayerManager.LevelUI = LevelUI
	PlayerManager.LevelMap = LevelMap
	PlayerManager.Tiles = Tiles
	PlayerManager.Vision = Vision
	PlayerManager.SpectateCamera = SpectateCamera
	
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	var allowed_spawns: Array = range(7, 25)
	for Tile in enemy_tiles:
		on_unit_awakened(allowed_spawns[randi() % allowed_spawns.size()], 0, [], 1, Tile.obj.rotation, Tile)
func on_player_phase_start() -> void:
	PlayerManager.on_player_phase_start()

func on_player_end_turn_phase_start() -> void:
	PlayerManager.on_player_end_turn_phase_start()

func unit_by_tile_team_bool(Tile: TileGD, team: int) -> bool:
	return FieldedUnits.get_children().any(func(x: UnitGD): return x.Tile == Tile and x.team == team)
func unit_by_tile_bool(Tile: TileGD) -> bool:
	return FieldedUnits.get_children().any(func(x: UnitGD): return x.Tile == Tile)

func unit_by_tile(Tile: TileGD) -> UnitGD:
	for Unit in FieldedUnits.get_children():
		if Tile == Unit.Tile: return Unit
	return null

func all_units(exclude: UnitGD = null) -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_queued_for_deletion() and x != exclude)

func on_units(team: int = 0, relation: String = "Ally") -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_queued_for_deletion()).filter(on_match_team_relation.bind(team, relation))

func on_unit_team_index(Unit: UnitGD) -> int:
	return on_units(Unit.team).find(Unit)

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy") or relation == "Any"

var active_action: Dictionary = {}
var unit_actions: Array = []
var unit_actions_after: Array = []

func onMoveToTileAI(Unit: UnitGD, Tile: TileGD, type: Variant, visibility_path: Array) -> void:
	unit_actions.append({
		"action_type": "MoveUnitAI",
		"Unit": Unit,
		"Tile": Tile,
		"type": type,
		"vis_path": visibility_path,
		})

func move_to_tile(Unit: UnitGD, Tile: TileGD, type: Variant) -> void:
	unit_actions.append({
		"action_type": "MoveUnit",
		"Unit": Unit,
		"Tile": Tile,
		"type": type,
	})
	
func _process(_delta: float) -> void:
	if active_action.is_empty() and !unit_actions.is_empty():
		Vision.on_vision_mode_set(0)
		LevelMap.setActionLock("UnitActionRegular")
		if unit_actions[0].action_type != "ArgDelay":
			active_action = unit_actions.pop_front()
			match active_action.action_type:
				"AIMoveFinish": onAIMoveFinish()
				"MoveUnitAI": onMoveUnitAI()
				"MoveUnit": onMoveUnit()
				"AttackTarget": on_attack_enemy()
				"DeathUnit": on_death()
				"HurtUnit": on_hurt()
				"Delay": onDelay()
				"ArgQueue": onArgQueue()
		else: onArgDelay()

func onAIMoveFinish() -> void:
	setUnitStatus(active_action.Unit, "TurnUsed")
	if unit_actions.is_empty():
		if !(active_action.vis_path.all(func(x: Array): return x[1] == "Invisible")):
			await get_tree().create_timer(AFTER_MOVEMENT_DELAY).timeout
		active_action = {}
		onUnitActionsFinished()
		AIManager.onMoveNextAIUnit()
	else: unit_actions.append(active_action)
	active_action = {}

func isUnitActionsEmpty() -> bool:
	return unit_actions.is_empty() or (unit_actions.size() == 1 and unit_actions[0].action_type == "AIMoveFinish")

func onArgQueue() -> void:
	active_action.callable.call()
	active_action = {}
	onUnitActionsFinished()

func onAppendArgQueue(callable: Callable) -> void:
	unit_actions.append({
		"action_type": "ArgQueue",
		"callable": callable,
	})

func onArgDelay() -> void:
	var _active_action: Dictionary = unit_actions[0]
	SpectateCamera.onSpectate(_active_action.InitialTeleport)
	if !_active_action.triggered:
		if _active_action.begin_callable.is_valid():
			_active_action.begin_callable.call()
		_active_action.triggered = true
		
	if unit_actions[0] == _active_action:
		active_action = unit_actions.pop_front()
		await get_tree().create_timer(active_action.delay).timeout
		if _active_action.end_callable.is_valid() and !_active_action.end_callable.is_null():
			active_action.end_callable.call()
		active_action = {}
		onUnitActionsFinished()
	
func onDelay() -> void:
	await get_tree().create_timer(active_action.delay).timeout
	active_action = {}
	onUnitActionsFinished()

func onMoveUnit() -> void:
	var Unit: UnitGD = active_action.Unit
	SpectateCamera.onSpectate(Unit)
	Unit.Model.onMoveToTile(active_action.Tile, active_action.type, "Regular")
	
func onMoveUnitAI() -> void:
	var Unit: UnitGD = active_action.Unit
	var movement_type: String = onFindVisibilityPathMovementType(active_action.Tile, active_action.vis_path)
	if movement_type != "Invisible":
		Unit.Model.onMoveToTile(active_action.Tile, active_action.type, movement_type)
		
		if movement_type == "Regular" and Unit.Tile not in Vision.ally_vision:
			Unit.Model.setVisible(true)
			for info in active_action.vis_path:
				if active_action.Tile == info[0]:
					Tiles.on_remove_tile_material(Unit.Tile, "Greyscale")
		return
	
	if onFindVisibilityPathReentersVision(active_action.Tile, active_action.vis_path): 
		await get_tree().create_timer(AFTER_MOVEMENT_DELAY).timeout
	
	Unit.global_position = Unit.Model.onCalculateEndPosition(active_action.Tile, active_action.type.x)
	on_movement_finished(Unit)
				
func onFindVisibilityPathReentersVision(Tile: TileGD, visibility_path: Array) -> bool:
	var index: int = visibility_path.map(func(x: Array): return x[0]).find(Tile)
	if index > 0 and index < visibility_path.size() - 1 and visibility_path[index - 1][1] == "OutOfVision":
		for i in range(index + 1, visibility_path.size()):
			if visibility_path[i][1] == "IntoVision": return true
	return false
		
func onFindVisibilityPathMovementType(Tile: TileGD, visibility_path: Array) -> String:
	for info in visibility_path:
		if Tile == info[0]:
			return info[1]
	return ""
	
const AFTER_MOVEMENT_DELAY: float = 0.8
func on_movement_finished(Unit: UnitGD) -> void:
	var Tile: TileGD = active_action.Tile
	var action_type: String = active_action.action_type
	
	if Unit.team == 0:
		Unit.onAddToPastPath(Tile)
	
	Unit.stats("active_speed", -1, AppliedByGD.new("MovementFinished"))
	Unit.occupy_tile(Tile)
	await Unit.tile_occupied
	if unit_actions.is_empty() or !(unit_actions[0].action_type.begins_with("MoveUnit")):
		on_unit_travel_finished()
	else: Unit.Model.on_play_walk_sfx()
	
	if Unit.team == 0:
		if unit_actions.is_empty() and Unit.speed > 0:
			PlayerManager._on_unit_selected(Unit)
	
	active_action = {}
	onUnitActionsFinished()

func onPushFrontDelay(delay: float) -> void:
	unit_actions.push_front({
			"action_type": "Delay",
			"delay": delay,
		})

func onPushArgDelay(Triggerer: UnitGD, delay: float, end_callable: Callable = Callable(), begin_callable: Callable = Callable(), InitialTeleport: UnitGD = null) -> void:
	unit_actions.append({
		"action_type": "ArgDelay",
		"begin_callable": begin_callable,
		"end_callable": end_callable,
		"delay": delay,
		"triggered": false,
		"Triggerer": Triggerer,
		"InitialTeleport": Triggerer if InitialTeleport == null else InitialTeleport
	})
	
	if unit_actions.size() == 1:
		onArgDelay()

func isVisibilityPathLastPosition(Tile: TileGD, visibility_path: Array) -> bool:
	var flip: bool = false
	for info in visibility_path:
		if flip and info[1] != "Invisible": return false
		if info[0] == Tile: flip = true
	return true

func onUnitActionsFinished() -> void:
	if unit_actions.is_empty() and active_action.is_empty():
		if LevelMap.game_phase != "AIPhase": LevelMap.setActionLock("UnitActionDisabled")
		for callable in unit_actions_after: callable.call()
		unit_actions_after = []
		Combat.onRecalculateTargetAbilities()

func onUnitEntersVision(Unit: UnitGD, _Unit: UnitGD) -> void:
	if Unit.team == 0 and _Unit.team == 1:
		if Unit.finished_awakening:
			AudioMaster.play_sfx("TrumpetKuba")
		PlayerManager.on_enemy_unit_enters_vision(_Unit, Unit)
	Combat.onOngoingAbilityUnit(Unit, _Unit, "EnterVision")
	Combat.onOngoingAbilityUnit(_Unit, Unit, "EnterVision")
	
func onUnitExitsVision(Unit: UnitGD, _Unit: UnitGD) -> void:
	if Unit.team == 0 and _Unit.team == 1:
		PlayerManager.on_enemy_unit_exits_vision(_Unit)
	Combat.onOngoingAbilityUnit(Unit, _Unit, "ExitVision")
	Combat.onOngoingAbilityUnit(_Unit, Unit, "ExitVision")
	
func onEnemyDiscoveredClearUnitActions() -> void:
	on_unit_travel_finished()
	active_action = {}
	unit_actions = unit_actions.filter(func(x: Dictionary): return x.action_type == "DeathUnit")
	onUnitActionsFinished()
	
var movement_outline_tiles: Array = []
func on_unit_travel_finished() -> void:
	if !active_action.is_empty() and active_action.action_type.begins_with("MoveUnit"):
		on_force_resume_idle_animation_from_walk()
		onCreateIncentiviseAction(active_action.Unit)
		active_action = {}
		onRemoveMovementOutlineTiles()
	
func onRemoveMovementOutlineTiles() -> void:
	for Tile in movement_outline_tiles:
		Tiles.setTileOutline(Tile, "PathHovered", true)
	movement_outline_tiles = []
	
func on_force_resume_idle_animation_from_walk() -> void:
	if !active_action.is_empty() and active_action.action_type.begins_with("MoveUnit"):
		active_action.Unit.Model.on_play_animation("Idle")
		if active_action.Unit.Model.current_walk_stream_player != null:
			AudioMaster.on_cutoff_sfx(active_action.Unit.Model.current_walk_stream_player)

func attack_enemy_or_target(Unit: UnitGD, Tile: TileGD) -> bool:
	if Unit.attack_amount > 0 and !Combat.isStaggered(Unit):
		var enemies: Array = on_units(Unit.team, "Enemy")
		for _Unit in enemies:
			if Tile == _Unit.Tile:
				PlayerManager.on_select_active_unit(Unit)
				_attack_enemy(Unit, _Unit, Tile)
				SpectateCamera.onSpectate(Unit)
				break
		return true
		# if this check fails can check for attacks on objects and such here
	return false
func _attack_enemy(Unit: UnitGD, _Unit: UnitGD, Tile: TileGD) -> void:
	unit_actions.append(
		{
		"action_type": "AttackTarget",
		"Attacker": Unit,
		"Defender": _Unit,
		"Tile": Tile,
		}
	)
	
func on_attack_enemy() -> void:
	active_action.Attacker.Model.attack_tile(active_action.Tile)
	active_action.Defender.Model._look_at(active_action.Attacker.Tile)
	LevelMap.setActionLock("UnitActionRegular")
	onRemoveMovementOutlineTiles()
	# can do all the ui stuff here for attacking
	
func onCreateIncentiviseAction(Unit: UnitGD) -> void:
	if Unit.team == 0 and LevelMap.game_phase == "PlayerPhase":
		unit_actions_after.append(LevelUI.onIncentivisePassTurn.bind(Unit))
	
func on_attack_finished(Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new("Attack", Unit)
	var DMGInfo: DMGInfoGD = Combat.onDMG(active_action.Defender, AppliedBy, Unit.attack)
	Unit.attack_amount -= 1
	if Unit.attack_amount == 0: Unit.stats("active_speed", 0, AppliedBy, true)
	Combat.onHit(DMGInfo)
	onCreateIncentiviseAction(Unit)
	active_action = {}
	onUnitActionsFinished()
	
func _attack_target(_Unit: UnitGD, _Tile: TileGD) -> void:
	pass

func kill_unit(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	unit_actions.append(
		{
			"action_type": "DeathUnit",
			"Deather": Unit,
			"AppliedBy": AppliedBy
		}
	)

func hurt_unit(Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	unit_actions.push_front(
		{
			"action_type": "HurtUnit",
			"Hurter": Unit,
			"AppliedBy": AppliedBy
		}
	)
	
func on_death() -> void:
	active_action.Deather.Model.on_death()
	LevelUI.UnitStatusOverlord.onDeathBegin(active_action.Deather, DEATH_AFTER_DELAY)
	LevelMap.setActionLock("UnitActionRegular")
	
func on_hurt() -> void:
	active_action.Hurter.Model.on_hurt()
	
@export var DEATH_AFTER_DELAY: float = 1.0
func on_death_finished(Unit: UnitGD) -> void:
	await get_tree().create_timer(DEATH_AFTER_DELAY).timeout
	
	var Deather: UnitGD = active_action.Deather
	var AppliedBy: AppliedByGD = active_action.AppliedBy
	
	LevelUI.UnitStatusOverlord.onDeathFinished(Unit)
	await Unit.on_death()
	
	var win_state: int = 1 if on_units(1).is_empty() else (2 if on_units().is_empty() else 0)
	
	AIManager.onDeathFinished(Unit)
	
	if Unit.team == 1: Deck.on_draw_card()
	
	if Unit.Model.current_walk_stream_player != null:
		AudioMaster.on_cutoff_sfx(Unit.Model.current_walk_stream_player)

	for _Unit in Deather.getVisibleUnits():
		Vision.on_recalculate_vision(_Unit)

	active_action = {}
	var dev := preload("res://static/dev/dev.tres")
	if !dev.win_enabled: win_state = 0
	match win_state:
		0: 
			Combat.onDeathAbilities(Deather, AppliedBy)
			PlayerManager.onDeathFinished(Unit, AppliedBy)
			GameEffects.onDeathFinished(Unit)
			onUnitActionsFinished()
		1: LevelUI.onWinGame()
		2: LevelUI.onLoseGame()
		
func on_hurt_finished(_Unit: UnitGD) -> void:
	active_action = {}
	onUnitActionsFinished()

func on_drop_calculate_damage(DMG: int, scale_time: float, Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new("Height")
	var DMGInfo := Combat.onDMG(Unit, AppliedBy, DMG)
	if Unit.health > 0 and DMGInfo.HealthDMG > 0: on_descale_unit(Unit, scale_time)

const DROP_HEIGHT_SCALE_DOWN := Vector3(1, 0.05, 1)
func on_descale_unit(Unit: UnitGD, scale_time: float) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(Unit, "scale", DROP_HEIGHT_SCALE_DOWN, scale_time)
	ScaleTween.finished.connect(on_unscale_unit.bind(Unit, scale_time))

func on_unscale_unit(Unit: UnitGD, scale_time: float) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(Unit, "scale", Vector3.ONE, scale_time)

func onSpectatedInPlayerPhase(Unit: UnitGD) -> void:
	LevelUI.on_pass_unit_turn_button_state(Unit.team == 1 or Unit in PlayerManager.passed_turns)

func onAIPhaseStart() -> void:
	AIManager.onAIPhaseStart()

func onAIEndTurnPhaseStart() -> void:
	AIManager.onAIEndTurnPhaseStart()
	for Unit in all_units():
		Unit.turns_alive += 1
		
func getCommutativeUnitsVision(Unit: UnitGD) -> Array:
	var tiles: Array = []
	for _Unit in all_units():
		if Unit.Tile in _Unit.visible_tiles: tiles.append(_Unit.Tile)
	return tiles

func onAIMoveFinisher(Unit: UnitGD, vis_path: Array) -> void:
	unit_actions.append({
		"action_type": "AIMoveFinish",
		"Unit": Unit,
		"vis_path": vis_path,
	})

func setUnitStatus(Unit: UnitGD, status: String) -> void:
	LevelUI.UnitStatusOverlord.setUnitStatusTurnStatus(Unit, status)
	if status == "TurnUsed":
		GameEffects.onTriggerUnitGameFX(Unit, TriggerGD.TURN_PASSED)

func setPastPath(Unit: UnitGD, state: bool) -> void:
	for Tile in Unit.past_path_info:
		Tiles.setTileOutline(Tile, "PastPath", !state)
		
		if state: Tile.Effects.onPastPath(Unit.past_path_info[Tile][0], Unit.past_path_info[Tile][1])
		else: Tile.Effects.onRemovePastPath()
	Unit.past_path_set = state

func onFindClosestUnitFromUnits(Unit: UnitGD, units: Array) -> UnitGD:
	units.erase(Unit)
	units.sort_custom(sortUnitsByDistance.bind(Unit))
	if units.size() > 0: return units[0]
	return null

func onFindClosestAdjacentUnit(Unit: UnitGD, relation: String = "Ally") -> UnitGD:
	return onFindClosestUnitFromUnits(Unit, on_units(Unit.team, relation))

func sortUnitsByDistance(Unit: UnitGD, _Unit: UnitGD, __Unit: UnitGD) -> bool:
	return Tiles.tile_distance(Unit.Tile, __Unit.Tile) < Tiles.tile_distance(_Unit.Tile, __Unit.Tile)

func onHoverUnitPressed(Unit: UnitGD) -> void:
	if !Unit.is_dead and Unit.Tile in Vision.ally_vision:
		pass
