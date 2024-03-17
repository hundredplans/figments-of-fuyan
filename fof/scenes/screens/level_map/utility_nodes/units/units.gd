class_name UnitsGD
extends Node3D

var Heroes: HeroesGD
var Deck: DeckGD
var SpectateCamera: Node3D
var GameState: GameStateGD
var Vision: VisionGD
var Random: RandomGD
var Tiles: TilesGD
var LevelMap: Node3D
var LevelUI: LevelUIGD

@export var UNIT_ANIMATION_BLEND_TIME: float = 0.2
@export var WALK_TRAVEL_TIME: float = 1.0

@onready var BotManager: BotManagerGD = $BotManager
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
	FieldedUnits.add_child(Unit)
	Unit.on_create_unit(id, tool_id, effects, team, rot, tile)
	Unit.Model.movement_finished.connect(on_movement_finished.bind(Unit))
	Unit.Model.drop_calculate_damage.connect(on_drop_calculate_damage.bind(Unit))
	Unit.Model.attack_finished.connect(on_attack_finished.bind(Unit))
	Unit.Model.death_finished.connect(on_death_finished.bind(Unit))
	
	if team == 0: PlayerManager.on_unit_awakened(Unit)
	
	LevelUI.on_add_unit_status_box(Unit)
	
	var in_vision: bool = Vision.is_unit_in_vision(Unit)
	Unit.on_arrive(team == 0 or in_vision)
	
	if team == 1 and in_vision:
		on_unit_enters_vision(Unit)
		
	return Unit

func on_start_phase_start() -> void:
	BotManager.Units = self
	PlayerManager.Units = self
	PlayerManager.LevelUI = LevelUI
	PlayerManager.LevelMap = LevelMap
	PlayerManager.Tiles = Tiles
	PlayerManager.SpectateCamera = SpectateCamera
	
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	for Tile in enemy_tiles:
		on_unit_awakened(Tile.info.obj.obj_info[0], 0, [], 1, Tile.info.obj.rotation, Tile) # add Random.on_create_random_tool() here, maybe no args and it takes from GameState

func on_player_phase_start() -> void:
	PlayerManager.on_player_phase_start()
	for Unit in on_units():
		Unit.stats("speed", Unit.max_speed, "StartPlayerPhase", true)
		Unit.attack_amount = 1

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
	return FieldedUnits.get_children()

func on_units(team: int = 0, relation: String = "Ally") -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_queued_for_deletion()).filter(on_match_team_relation.bind(team, relation))

func on_unit_team_index(Unit: UnitGD) -> int:
	return on_units(Unit.team).find(Unit)

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy")

var active_event: Array
var event_queue: Array = []

func move_to_tile(Unit: UnitGD, Tile: TileGD, type: Variant) -> void:
	event_queue.append(["MoveUnit", Unit, Tile, type])
	
func _process(_delta: float) -> void:
	if active_event.is_empty():
		if !event_queue.is_empty():
			active_event = event_queue.pop_front()
			match active_event[0]:
				"MoveUnit": 
					active_event[1].Model.move_to_tile(active_event[2], active_event[3])
					SpectateCamera.on_start_track_unit(active_event[1])
				"AttackTarget": on_attack_enemy()
				"DeathUnit": on_death()
			LevelMap.on_set_lock_inputs_event_queue(true)
		
func on_movement_finished(Unit: UnitGD) -> void:
	Unit.stats("speed", -1, "MovementFinished")
	Unit.occupy_tile(active_event[2])
	if event_queue.is_empty() or event_queue[0][0] != "MoveUnit" or event_queue[0][1] != Unit:
		on_unit_travel_finished(Unit)
	else: Unit.Model.on_play_walk_sfx()
	active_event = []
	
	if event_queue.is_empty() and Unit.speed > 0:
		PlayerManager._on_unit_selected(Unit)

func on_unit_enters_vision(Unit: UnitGD) -> void:
	if Unit.team == 1: PlayerManager.on_enemy_unit_enters_vision(Unit)
		
func on_unit_exits_vision(Unit: UnitGD) -> void:
	if Unit.team == 1: PlayerManager.on_enemy_unit_exits_vision(Unit)

func on_clear_event_queue() -> void:
	if !active_event.is_empty() and active_event[0] == "MoveUnit": on_unit_travel_finished(active_event[1])
	active_event = []
	event_queue = []
	
func on_unit_travel_finished(Unit: UnitGD) -> void:
	on_force_resume_idle_animation_from_walk()
	
	if Unit.team == 0: PlayerManager.on_check_autopass(Unit)
	elif Unit.team == 1: Tiles.on_set_tile_material(Unit.Tile, "EnemyOccupy")
	
	LevelMap.on_set_lock_inputs_event_queue(false)
	SpectateCamera.on_end_track_unit()
	
func on_force_resume_idle_animation_from_walk() -> void:
	if !active_event.is_empty() and active_event[0] == "MoveUnit":
		active_event[1].Model.on_play_animation("Idle")
		if active_event[1].Model.current_walk_stream_player != null:
			AudioMaster.on_cutoff_sfx(active_event[1].Model.current_walk_stream_player)

func attack_enemy_or_target(Unit: UnitGD, Tile: TileGD) -> void:
	if Unit.attack_amount > 0:
		var enemies: Array = on_units(Unit.team, "Enemy")
		for _Unit in enemies:
			if Tile == _Unit.Tile:
				PlayerManager.on_select_active_unit(Unit)
				_attack_enemy(Unit, _Unit, Tile)
				break
		# if this check fails can check for attacks on objects and such here

func _attack_enemy(Unit: UnitGD, _Unit: UnitGD, Tile: TileGD) -> void:
	event_queue.append(["AttackTarget", Unit, _Unit, Tile])
	
func on_attack_enemy() -> void:
	active_event[1].Model.attack_tile(active_event[3])
	active_event[2].Model._look_at(active_event[1].Tile)
	LevelMap.on_set_lock_inputs_event_queue(true)
	# can do all the ui stuff here for attacking
	
@export var ATTACK_AFTER_DELAY: float = 0.5
func on_attack_finished(Unit: UnitGD) -> void:
	active_event[2].stats("health", -Unit.attack, Unit)
	
	if active_event[2].health > 0 and event_queue.is_empty():
		await get_tree().create_timer(ATTACK_AFTER_DELAY).timeout
	
	Unit.attack_amount -= 1
	active_event = []
	
	LevelMap.on_set_lock_inputs_event_queue(false)
	if Unit.team == 0: PlayerManager.on_attack_finished(Unit)
	
func _attack_target(_Unit: UnitGD, _Tile: TileGD) -> void:
	pass

func kill_unit(Unit: UnitGD, Killer: String) -> void:
	event_queue.append(["DeathUnit", Unit, Killer])

func on_death() -> void:
	active_event[1].Model.on_death()
	active_event[1].UnitStatus.onBeginUnitStatusDeath(DEATH_AFTER_DELAY)
	LevelMap.on_set_lock_inputs_event_queue(true)
	
@export var DEATH_AFTER_DELAY: float = 1.0
func on_death_finished(Unit: UnitGD) -> void:
	await get_tree().create_timer(DEATH_AFTER_DELAY).timeout
	var deathee_index: int = on_unit_team_index(Unit)
	Unit.UnitStatus._queue_free()
	Unit.on_death()
	LevelMap.on_set_lock_inputs_event_queue(false)
	PlayerManager.on_death_finished(active_event[2], Unit, deathee_index)
	Deck.on_draw_card()
	active_event = []
	
	if Unit.Model.current_walk_stream_player != null:
		AudioMaster.on_cutoff_sfx(Unit.Model.current_walk_stream_player)

func on_drop_calculate_damage(new_health: int, scale_time: float, Unit: UnitGD) -> void:
	if new_health >= 0:
		if new_health == 0:
			active_event = []
			event_queue = []
		else: on_descale_unit(Unit, scale_time)
		Unit.stats("health", new_health, "Height", true)

const DROP_HEIGHT_SCALE_DOWN := Vector3(1, 0.05, 1)
func on_descale_unit(Unit: UnitGD, scale_time: float) -> void:
	var ScaleTween := get_tree().create_tween()
	ScaleTween.tween_property(Unit, "scale", DROP_HEIGHT_SCALE_DOWN, scale_time)
	ScaleTween.finished.connect(on_unscale_unit.bind(Unit, scale_time))

func on_unscale_unit(Unit: UnitGD, scale_time: float) -> void:
	var ScaleTween := get_tree().create_tween()
	ScaleTween.tween_property(Unit, "scale", Vector3.ONE, scale_time)
