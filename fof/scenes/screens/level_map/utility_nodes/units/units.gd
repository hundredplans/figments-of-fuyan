class_name UnitsGD
extends Node3D

var Deck: DeckGD
var SpectateCamera: Camera3D
var GameState: GameStateGD
var Vision: VisionGD
var Random: RandomGD
var Tiles: TilesGD
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD

@export var UNIT_ANIMATION_BLEND_TIME: float = 0.2
@export var WALK_TRAVEL_TIME: float = 1.2

@onready var BotManager: BotManagerGD = $BotManager
@onready var PlayerManager: PlayerManagerGD = $PlayerManager
@onready var FieldedUnits: Node3D = $FieldedUnits

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")
	
func on_unit_awakened(id: int, tool_id: int, effects: Array, team: int, rot: int, tile: TileGD) -> UnitGD:
	var Unit: UnitGD = UnitScene.instantiate()
	Unit.Units = self
	Unit.Vision = Vision
	FieldedUnits.add_child(Unit)
	Unit.on_create_unit(id, tool_id, effects, team, rot, tile)
	Unit.Model.movement_finished.connect(on_movement_finished.bind(Unit))
	Unit.Model.attack_finished.connect(on_attack_finished.bind(Unit))
	Unit.Model.death_finished.connect(on_death_finished.bind(Unit))
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
		Unit.stats("speed", Unit.max_speed, null, true)
		Unit.attack_amount = 1

func on_player_end_turn_phase_start() -> void:
	PlayerManager.on_player_end_turn_phase_start()
	if UnitSelected != null: _on_unit_deselected(UnitSelected, true)

func unit_by_tile_bool(Tile: TileGD) -> bool:
	return FieldedUnits.get_children().any(func(x: UnitGD): return x.Tile == Tile)

func unit_by_tile(Tile: TileGD) -> UnitGD:
	for Unit in FieldedUnits.get_children():
		if Tile == Unit.Tile: return Unit
	return null

func all_units() -> Array:
	return FieldedUnits.get_children()

func on_units(team: int = 0, relation: String = "Ally") -> Array:
	return FieldedUnits.get_children().filter(on_match_team_relation.bind(team, relation))

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy")

var UnitSelected: UnitGD
func on_occupied_tile_inspected(Tile: TileGD) -> void:
	var Unit: UnitGD = unit_by_tile(Tile)
	if Unit.team == 0:
		match LevelMap.game_phase:
			"PlayerPhase":
				on_unit_selected(Unit)
	else:
		pass

var active_event: Array

var move_queue: Array
var attack_queue: Array
var death_queue: Array

func move_to_tile(Unit: UnitGD, Tile: TileGD) -> void:
	move_queue.append([Unit, Tile])
	
func _process(_delta: float) -> void:
	if !move_queue.is_empty() and active_event.is_empty():
		active_event = ["MoveUnit"] + move_queue.pop_front()
		active_event[1].Model.move_to_tile(active_event[2])
		LevelMap.set_lock_inputs(true)
		
	if !active_event.is_empty() and active_event[0] == "MoveUnit":
		SpectateCamera.position.x += active_event[1].position.x - SpectateCamera.central_point.x
		SpectateCamera.position.z += active_event[1].position.z - SpectateCamera.central_point.z
		SpectateCamera.central_point = Vector3(active_event[1].position.x, SpectateCamera.central_point.y, active_event[1].position.z)
		
	if active_event.is_empty() and move_queue.is_empty():
		if !attack_queue.is_empty():
			active_event = ["AttackUnit"] + attack_queue.pop_front() if attack_queue[0].size() == 3 else []
			on_attack_enemy()
			
		elif !death_queue.is_empty():
			active_event = ["DeathUnit"] + death_queue.pop_front()
			on_death()
		
func on_movement_finished(Unit: UnitGD) -> void:
	Unit.stats("speed", -1)
	Unit.occupy_tile(active_event[2])
	if move_queue.is_empty(): on_empty_move_queue()
	else:
		Unit.Model.on_play_walk_sfx()
		active_event = []
	
func on_unit_selected(Unit: UnitGD) -> void:
	if UnitSelected == Unit:
		_on_unit_deselected(Unit)
	elif UnitSelected != null:
		_on_unit_deselected(UnitSelected)
		_on_unit_selected(Unit)
	else: _on_unit_selected(Unit)

func _on_unit_deselected(Unit: UnitGD, absolute: bool = false) -> void:
	Tiles.on_remove_tile_material(Unit.Tile)
	var tiles: Dictionary = Tiles.tiles_in_speed(Unit)
	for Tile in tiles.in_speed + tiles.in_range:
		Tiles.on_remove_tile_material(Tile)
		
	if Unit == UnitSelected: UnitSelected = null
	if !absolute:
		Tiles.on_force_mouse_entered()
	
func _on_unit_selected(Unit: UnitGD) -> void:
	if Unit.Tile.unit_state() in ["TurnActive", "SpectatingUnit"]:
		Tiles.on_set_tile_material(Unit.Tile, "UnitSelected")
		var tiles: Dictionary = Tiles.tiles_in_speed(Unit)
		var enemy_tiles: Array = on_units(1).map(func(x: UnitGD): return x.Tile)

		for Tile in tiles.in_speed:
			if Unit.attack_amount > 0 and Tile in enemy_tiles:
				Tiles.on_set_tile_material(Tile, "EnemyInRange")
				
			elif Tile.solid_status == 0:
				Tiles.on_set_tile_material(Tile, "MovementRange")
			
		if Unit.attack_amount > 0:
			for Tile in tiles.in_range:
				if Tile in enemy_tiles:
					Tiles.on_set_tile_material(Tile, "EnemyInRange")
			
		UnitSelected = Unit

func on_unit_enters_vision(Unit: UnitGD) -> void:
	if Unit.team == 1: PlayerManager.on_enemy_unit_enters_vision(Unit)
		
func on_unit_exits_vision(Unit: UnitGD) -> void:
	if Unit.team == 1: PlayerManager.on_enemy_unit_exits_vision(Unit)

func on_empty_move_queue() -> void:
	if !active_event.is_empty():
		on_unit_travel_finished(active_event[1])
	active_event = []
	move_queue = []
	
func on_unit_travel_finished(Unit: UnitGD) -> void:
	on_force_resume_idle_animation_from_walk()
	
	if Unit.team == 0: PlayerManager.on_unit_travel_finished(Unit)
	elif Unit.team == 1: Tiles.on_set_tile_material(Unit.Tile, "EnemyOccupy")
	
	LevelMap.set_lock_inputs(false)
	
func on_force_resume_idle_animation_from_walk() -> void:
	if active_event.size() > 0 and active_event[0] == "MoveUnit":
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
	attack_queue.append([Unit, _Unit, Tile])
	
func on_attack_enemy() -> void:
	active_event[1].Model.attack_tile(active_event[3])
	active_event[2].Model._look_at(active_event[1].Tile)
	LevelMap.set_lock_inputs(true)
	# can do all the ui stuff here for attacking
	
func on_attack_finished(Unit: UnitGD) -> void:
	active_event[2].stats("health", -Unit.attack, Unit)
	Unit.attack_amount -= 1
	active_event = []
	LevelMap.set_lock_inputs(false)
	if Unit.team == 0: PlayerManager.on_attack_finished(Unit)
	
func _attack_target(_Unit: UnitGD, _Tile: TileGD) -> void:
	pass

func kill_unit(Unit: UnitGD, Killer: UnitGD) -> void:
	death_queue.append([Unit, Killer])

func on_death() -> void:
	active_event[1].Model.on_death()
	LevelMap.set_lock_inputs(true)

func on_death_finished(Unit: UnitGD) -> void:
	Deck.on_draw_card()
	Unit.on_death()
	active_event = []
	LevelMap.set_lock_inputs(false)
