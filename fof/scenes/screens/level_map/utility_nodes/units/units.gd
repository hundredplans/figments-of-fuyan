class_name UnitsGD
extends Node3D

var Deck: DeckGD
var SpectateCamera: Node3D
var GameState: GameStateGD
var Vision: VisionGD
var Random: RandomGD
var Tiles: TilesGD
var LevelMap: Node3D
var LevelUI: LevelUIGD

@onready var AIManager: AIManagerGD = $BotManager
@onready var PlayerManager: PlayerManagerGD = $PlayerManager
@onready var FieldedUnits: Node3D = $FieldedUnits

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")
func _ready() -> void:
	onCreateUnitFieldStatusMaterials()
	
const DARK_RED: Color = Color("ff0000")
const BRIGHT_GREEN: Color = Color("00ff00")
const MEDIUM_GRAY: Color = Color("8c8c8c")
const BASE: Color = Color("ffffff")
	
var unit_field_status_materials: Dictionary = {
	"BASE": [], # [bot, top_level]
	"BRIGHT_GREEN": [],
	"DARK_RED": [],
	"MEDIUM_GRAY": [],
}
func onCreateUnitFieldStatusMaterials():
	for key in unit_field_status_materials:
		var color: Color = get(key)
		var bot_material: ShaderMaterial = preload("res://scenes/screens/level_map/floating_stats/color_materials/floating_number_material.tres").duplicate() 
		bot_material.set_shader_parameter("albedo", color)
		unit_field_status_materials[key].append(bot_material)
		
		var top_material: ShaderMaterial = preload("res://scenes/screens/level_map/floating_stats/color_materials/floating_number_material_no_depth.tres").duplicate() 
		top_material.set_shader_parameter("albedo", color)
		unit_field_status_materials[key].append(top_material)
	
func on_unit_awakened(id: int, tool_id: int, effects: Array, team: int, rot: int, tile: TileGD) -> UnitGD:
	var Unit: UnitGD = UnitScene.instantiate()
	Unit.Units = self
	Unit.Vision = Vision
	Unit.SpectateCamera = SpectateCamera
	Unit.Tiles = Tiles
	FieldedUnits.add_child(Unit)
	
	Unit.on_create_unit(id, tool_id, effects, team, rot, tile) # Takes around 2.2 seconds
	Vision.onUnitAwakened(Unit)
	Unit.Model.movement_finished.connect(on_movement_finished.bind(Unit))
	Unit.Model.drop_calculate_damage.connect(on_drop_calculate_damage.bind(Unit))
	Unit.Model.attack_finished.connect(on_attack_finished.bind(Unit))
	Unit.Model.death_finished.connect(on_death_finished.bind(Unit))
	Unit.Model.hurt_finished.connect(on_hurt_finished.bind(Unit))
	
	LevelUI.on_add_unit_status_box(Unit)
	SpectateCamera.onUnitAwakened(Unit)
	
	Unit.on_arrive(team == 0 or Unit.getVisibleEnemies().size() > 0)
	AIManager.onUnitAwakened(Unit)
	Unit.finished_awakening = true
	return Unit

var allowed_spawns: Array = range(7, 15) + range(16, 19)
func on_start_phase_start() -> void:
	AIManager.LevelMap = LevelMap
	AIManager.Units = self
	AIManager.Vision = Vision
	AIManager.Tiles = Tiles
	PlayerManager.Units = self
	PlayerManager.LevelUI = LevelUI
	PlayerManager.LevelMap = LevelMap
	PlayerManager.Tiles = Tiles
	PlayerManager.Vision = Vision
	PlayerManager.SpectateCamera = SpectateCamera
	
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
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

func all_units() -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_queued_for_deletion())

func on_units(team: int = 0, relation: String = "Ally") -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_queued_for_deletion()).filter(on_match_team_relation.bind(team, relation))

func on_unit_team_index(Unit: UnitGD) -> int:
	return on_units(Unit.team).find(Unit)

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy")

var active_action: Array = []
var unit_actions: Array = []

func onMoveToTileAI(Unit: UnitGD, Tile: TileGD, type: Variant, visibility_path: Array) -> void:
	unit_actions.append(["MoveUnitAI", Unit, Tile, type, visibility_path])

func move_to_tile(Unit: UnitGD, Tile: TileGD, type: Variant, delay: float = -1) -> void:
	unit_actions.append(["MoveUnit", Unit, Tile, type, delay])
	
func _process(_delta: float) -> void:
	if active_action.is_empty() and !unit_actions.is_empty():
		Vision.on_vision_mode_set(0)
		active_action = unit_actions.pop_front()
		LevelMap.setActionLock("UnitActionRegular")
		match active_action[0]:
			"MoveUnitAI": onMoveUnitAI()
			"MoveUnit": onMoveUnit()
			"AttackTarget": on_attack_enemy()
			"DeathUnit": on_death()
			"HurtUnit": on_hurt()
			"Delay": onDelay()

func onDelay() -> void:
	await get_tree().create_timer(active_action[1]).timeout
	active_action = []
	onUnitActionsFinished()

func onMoveUnit() -> void:
	var Unit: UnitGD = active_action[1]
	SpectateCamera.onStartTrackUnit(Unit)
	Unit.Model.onMoveToTile(active_action[2], active_action[3], "Regular")
		
func onMoveUnitAI() -> void:
	var Unit: UnitGD = active_action[1]
	var DestinationTile: TileGD = active_action[2]
	var visibility_path: Array = active_action[4].duplicate()
	var movement_type: String = onFindVisibilityPathMovementType(DestinationTile, visibility_path)
	if movement_type != "Invisible":
		SpectateCamera.onStartTrackUnit(Unit)
		Unit.Model.onMoveToTile(DestinationTile, active_action[3], movement_type)
		
		if movement_type == "Regular" and Unit.Tile not in Vision.ally_vision:
			Unit.Model.setVisible(true)
			for info in visibility_path:
				if DestinationTile == info[0]:
					Tiles.on_remove_tile_material(Unit.Tile, "Greyscale")
		return
		
	if onFindVisibilityPathReentersVision(DestinationTile, visibility_path): 
		await get_tree().create_timer(AFTER_MOVEMENT_DELAY).timeout
	
	SpectateCamera.onEndTrackUnit()
	Unit.global_position = Unit.Model.onCalculateEndPosition(DestinationTile, active_action[3].x)
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
	var Tile: TileGD = active_action[2]
	var action_type: String = active_action[0]
	var visibility_path: Array = [] if action_type != "MoveUnitAI" else active_action[4]
	Unit.stats("speed", -1, "MovementFinished")
	Unit.occupy_tile(Tile)
	
	if action_type != "MoveUnitAI" or onFindVisibilityPathMovementType(Tile, visibility_path) != "Invisible":
		if unit_actions.is_empty() or !unit_actions[0][0].begins_with("MoveUnit") or unit_actions[0][1] != Unit:
			on_unit_travel_finished()
		else: Unit.Model.on_play_walk_sfx()
		
	if action_type == "MoveUnitAI" and unit_actions.is_empty():
		if isVisibilityPathLastPosition(Tile, visibility_path): onPushFrontDelay(AFTER_MOVEMENT_DELAY)
			
	active_action = []
	if Unit.team == 0 and unit_actions.is_empty() and Unit.speed > 0:
		PlayerManager._on_unit_selected(Unit)
	onUnitActionsFinished()

func onPushFrontDelay(delay: float) -> void:
	unit_actions.push_front(["Delay", delay])
	onUnitActionsFinished()

func isVisibilityPathLastPosition(Tile: TileGD, visibility_path: Array) -> bool:
	var flip: bool = false
	for info in visibility_path:
		if flip and info[1] != "Invisible": return false
		if info[0] == Tile: flip = true
	return true

func onUnitActionsFinished() -> void:
	if unit_actions.is_empty():
		var SpectateUnit: UnitGD = SpectateCamera.getSpectateUnit()
		if SpectateUnit != null: Tiles.on_set_tile_material(SpectateUnit.Tile, "SpectatingUnit")
		
		if LevelMap.game_phase == "AIPhase": AIManager.onMoveNextAIUnit()
		else: LevelMap.setActionLock("UnitActionDisabled")

func onUnitMovementEntersVision(Unit: UnitGD, _Unit: UnitGD) -> void:
	if Unit.team == 0 and _Unit.team == 1 and _Unit.getVisibleEnemies().size() == 1 and Unit.finished_awakening:
		AudioMaster.play_sfx("TrumpetKuba")
	on_unit_enters_vision(Unit, _Unit)

func on_unit_enters_vision(Unit: UnitGD, _Unit: UnitGD) -> void:
	if Unit.team == 0 and _Unit.team == 1: 
		PlayerManager.on_enemy_unit_enters_vision(_Unit)
		
func onUnitExitsAllyVision(Unit: UnitGD, _Unit: UnitGD) -> void:
	if Unit.team == 0 and _Unit.team == 1: PlayerManager.on_enemy_unit_exits_vision(_Unit)

func onClearUnitActions() -> void:
	on_unit_travel_finished()
	active_action = []
	unit_actions = []
	onUnitActionsFinished()
	
func on_unit_travel_finished(override: bool = false) -> void:
	if !active_action.is_empty() and active_action[0].begins_with("MoveUnit"):
		on_force_resume_idle_animation_from_walk()
		var Unit: UnitGD = active_action[1]
		if Unit.team == 0: PlayerManager.on_check_autopass(Unit)
		SpectateCamera.onEndTrackUnit()
		Tiles.on_set_tile_material(Unit.Tile, "AllyOccupy" if Unit.team == 0 else "EnemyOccupy")
		if !override: active_action = []
	
func on_force_resume_idle_animation_from_walk() -> void:
	if !active_action.is_empty() and active_action[0].begins_with("MoveUnit"):
		active_action[1].Model.on_play_animation("Idle")
		if active_action[1].Model.current_walk_stream_player != null:
			AudioMaster.on_cutoff_sfx(active_action[1].Model.current_walk_stream_player)

func attack_enemy_or_target(Unit: UnitGD, Tile: TileGD) -> void:
	if Unit.attack_amount > 0:
		var enemies: Array = on_units(Unit.team, "Enemy")
		for _Unit in enemies:
			if Tile == _Unit.Tile:
				PlayerManager.on_select_active_unit(Unit)
				_attack_enemy(Unit, _Unit, Tile)
				SpectateCamera.onStartTrackUnit(Unit)
				break
		# if this check fails can check for attacks on objects and such here

func _attack_enemy(Unit: UnitGD, _Unit: UnitGD, Tile: TileGD) -> void:
	unit_actions.append(["AttackTarget", Unit, _Unit, Tile])
	
func on_attack_enemy() -> void:
	active_action[1].Model.attack_tile(active_action[3])
	active_action[2].Model._look_at(active_action[1].Tile)
	LevelMap.setActionLock("UnitActionRegular")
	# can do all the ui stuff here for attacking
	
func on_attack_finished(Unit: UnitGD) -> void:
	active_action[2].stats("health", -Unit.attack, Unit)
	
	Unit.attack_amount -= 1
	active_action = []
	onUnitActionsFinished()
	
func _attack_target(_Unit: UnitGD, _Tile: TileGD) -> void:
	pass

func kill_unit(Unit: UnitGD, Killer: String) -> void:
	unit_actions.append(["DeathUnit", Unit, Killer])

func hurt_unit(Unit: UnitGD, Attacker: Variant) -> void:
	unit_actions.push_front(["HurtUnit", Unit, Attacker])

func on_death() -> void:
	active_action[1].Model.on_death()
	active_action[1].UnitStatus.onBeginUnitStatusDeath(DEATH_AFTER_DELAY)
	LevelMap.setActionLock("UnitActionRegular")
	
func on_hurt() -> void:
	active_action[1].Model.on_hurt()
	
@export var DEATH_AFTER_DELAY: float = 1.0
func on_death_finished(Unit: UnitGD) -> void:
	await get_tree().create_timer(DEATH_AFTER_DELAY).timeout
	for _Unit in all_units():
		_Unit.visible_units.erase(Unit)
		
	Unit.UnitStatus._queue_free()
	Unit.on_death()
	
	SpectateCamera.onDeathFinished(Unit)
	var win_state: int = 1 if on_units(1).is_empty() else (2 if on_units().is_empty() else 0)
	PlayerManager.onDeathFinished(active_action[2], Unit, win_state)
	AIManager.onDeathFinished(Unit)
	Deck.on_draw_card()
	active_action = []
	
	if Unit.Model.current_walk_stream_player != null:
		AudioMaster.on_cutoff_sfx(Unit.Model.current_walk_stream_player)

	match win_state:
		0: onUnitActionsFinished()
		1: LevelUI.onWinGame()
		2: LevelUI.onLoseGame()
		
func on_hurt_finished(_Unit: UnitGD) -> void:
	if typeof(active_action[2]) == TYPE_STRING:
		if active_action[2] == "Height":
			PlayerManager.on_hurt_finished(active_action[1])
	elif active_action[2].team == 0: PlayerManager.on_hurt_finished(active_action[2])
	active_action = []
	onUnitActionsFinished()

func on_drop_calculate_damage(new_health: int, scale_time: float, Unit: UnitGD) -> void:
	if new_health >= 0:
		if new_health == 0:
			active_action = []
			unit_actions = []
		else: on_descale_unit(Unit, scale_time)
		Unit.stats("health", new_health, "Height", true)

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

func onUpdateVisibleUnits(Unit: UnitGD, _Unit: UnitGD) -> void:
	if Unit != _Unit:
		var was_visible: bool = _Unit in Unit.visible_units
		var currently_visible: bool = Unit.visible_tiles.any(func(x: TileGD): return x == _Unit.Tile)
		if was_visible and !currently_visible:
			onRemoveVisibleUnit(Unit, _Unit)
		elif currently_visible and !was_visible:
			onAddVisibleUnit(Unit, _Unit)
			
func onAddVisibleUnit(Unit: UnitGD, _Unit: UnitGD) -> void:
	Unit.visible_units.append(_Unit)
	_Unit.visible_units.append(Unit)
	onUnitMovementEntersVision(Unit, _Unit)
	if Unit.Tile not in _Unit.visible_tiles:
		_Unit.visible_tiles.append(Unit.Tile)
			
func onRemoveVisibleUnit(Unit: UnitGD, _Unit: UnitGD) -> void:
	Unit.visible_units.erase(_Unit)
	_Unit.visible_units.erase(Unit)
	
	if _Unit.getVisibleEnemies().is_empty():
		onUnitExitsAllyVision(Unit, _Unit)
		
