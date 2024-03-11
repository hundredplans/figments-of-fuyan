extends Node3D
signal mouse_in_ui

@onready var Camera: Camera3D = get_node("SpringArm/Camera3D")
@export var LOOK_AT_UNIT_HEIGHT_MULTIPLIER: float = 0.8
@export var CAMERA_UNIT_HEIGHT_MULTIPLIER: float = 1.2
@export var CAMERA_RADIUS: float = 2.0 * (1 + (0.01 * Settings.camera_distance))

@export var CAMERA_LOOK_AT_HEIGHT: Dictionary = {
	"Spawn": 1.9, # This is always equal to a 2 height unit to make transitions as smoothless as possible
	"Unit": 0.0,
}

@export var CAMERA_HEIGHT: Dictionary = {
	"Spawn": 2.7, # This is always equal to a 2 height unit to make transitions as smoothless as possible
	"Unit": 0.0,
}
@export var CAMERA_ROTATION_SPEED: float = 3.0

var LevelMap: LevelMapGD
var Units: UnitsGD
var Tiles: TilesGD

var central_point: Vector3
func on_camera_start_spectate(pos: Vector3, type: String) -> void:
	central_point = pos
	central_point.y += CAMERA_LOOK_AT_HEIGHT[type]
	position = Vector3(pos.x, pos.y + CAMERA_HEIGHT[type], pos.z)
	
	on_set_camera_point_along_circle()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().update_mouse_cursor_state()
		mouse_in_ui.emit(true)
		
	elif Input.is_action_just_released(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_in_ui.emit(false)
			
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		on_set_camera_point_along_circle((event.relative / 10000) * CAMERA_ROTATION_SPEED)

var total_progress := Vector2.ZERO
var Y_SPHERE_BLOCK: float = 0.3
func on_set_camera_point_along_circle(progress: Vector2 = Vector2.ZERO) -> void:
	if progress != Vector2.ZERO:
		total_progress.x = clampf(total_progress.x + progress.x, 0, 1)
		if total_progress.x <= 0: total_progress.x = 1
		elif total_progress.x >= 1: total_progress.x = 0
		
		total_progress.y = clampf(total_progress.y + progress.y, -Y_SPHERE_BLOCK, Y_SPHERE_BLOCK)
	
	var theta: float = total_progress.x * 2 * PI
	var phi: float = total_progress.y * PI
	
	position.x = cos(phi) * cos(theta) * CAMERA_RADIUS + central_point.x
	position.y = sin(phi) * CAMERA_RADIUS + central_point.y
	position.z = cos(phi) * sin(theta) * CAMERA_RADIUS + central_point.z
	look_at(central_point)
	
var spectate_type: String
var unit_spectate_id: int = 0
var spawn_spectate_id: int = 0
var unit_positions: Array = []
var spawn_positions: Array = []

func on_start_phase_start() -> void:
	for i in range(Tiles.on_is_type_get_tiles("Spawn", "obj").size()): spawn_positions.append(Vector2.ZERO)

func on_spectate(type: String = "Unit", id: int = -1, direction: int = 0) -> void:
	spectate_type = type
	match type:
		"Spawn":
			var spawn_tiles: Array = Tiles.on_is_type_get_tiles("Spawn", "obj")
			spawn_positions[spawn_spectate_id] = total_progress
			
			if id == -1: spawn_spectate_id += direction
			else: spawn_spectate_id = id
			
			if spawn_spectate_id >= spawn_tiles.size(): spawn_spectate_id = 0
			elif spawn_spectate_id < 0: spawn_spectate_id = spawn_tiles.size() - 1
			
			total_progress = spawn_positions[spawn_spectate_id]
			on_camera_start_spectate(spawn_tiles[spawn_spectate_id].position, type)
		"Unit":
			if !(id >= 0 and id == unit_spectate_id):
				if Units.PlayerManager.UnitSelected != null:
					Units.PlayerManager._on_unit_deselected(Units.PlayerManager.UnitSelected)
				
				var units: Array = Units.on_units(0, "Ally")
				if units.size() > unit_spectate_id:
					var past_unit: UnitGD = units[unit_spectate_id]
					unit_positions[unit_spectate_id] = total_progress
					Tiles.on_remove_tile_material(past_unit.Tile, "SpectatingUnit")
					past_unit.UnitStatus.on_unit_spectated(false)
					
				if id == -1: unit_spectate_id += direction
				else: unit_spectate_id = id
				
				if unit_spectate_id == units.size(): unit_spectate_id = 0
				elif unit_spectate_id < 0: unit_spectate_id = units.size() - 1
				
				if units.size() > unit_spectate_id:
					var Unit: UnitGD = units[unit_spectate_id]
					CAMERA_HEIGHT["Unit"] = Unit.height.top * CAMERA_UNIT_HEIGHT_MULTIPLIER
					CAMERA_LOOK_AT_HEIGHT["Unit"] = Unit.height.top * LOOK_AT_UNIT_HEIGHT_MULTIPLIER
					
					total_progress = unit_positions[unit_spectate_id]
					on_camera_start_spectate(Unit.position, type)
					SpectateUnit = Unit
					if LevelMap.game_phase == "PlayerPhase":
						Unit.on_spectated_in_player_phase()

var SpectateUnit: UnitGD
func on_select_spectate_camera_direction(i: int) -> void:
	on_spectate(spectate_type, -1, i)

var TrackUnit: UnitGD
func on_start_track_unit(Unit: UnitGD) -> void:
	TrackUnit = Unit
	
func on_end_track_unit() -> void:
	TrackUnit = null
	
func on_track_unit() -> void:
	on_camera_start_spectate(TrackUnit.global_position, "Unit")
	
func _process(_delta) -> void:
	if TrackUnit != null: on_track_unit()
