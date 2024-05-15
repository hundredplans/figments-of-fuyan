extends Node3D

signal mouse_in_ui

@onready var Camera = %Camera3D

@export var LOOK_AT_UNIT_HEIGHT_MULTIPLIER: float = 0.8
@export var CAMERA_UNIT_HEIGHT_MULTIPLIER: float = 1.2

@export var CAMERA_RADIUS: float = 2.0 * (1 + (0.01 * Settings.camera_distance))
@export var CAMERA_ROTATION_SPEED: float = 3.0

@export var SPAWN_CAMERA_CENTRAL_POINT_HEIGHT: float = 2.4
@export var SPAWN_CAMERA_LOOK_AT_HEIGHT: float = 1.7

var spectates: Dictionary = {
	"Spawn": {},
	"Enemy": {},
	"Ally": {},
}

var Vision: VisionGD
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var Units: UnitsGD
var Tiles: TilesGD

var spectate_type: String

var central_point: Vector3
var total_progress := Vector2.ZERO
var Y_SPHERE_BLOCK: float = 0.3

func onGetActiveSpectateVariant() -> Dictionary:
	if !spectate_type.is_empty():
		if spectate_type != "Spawn":
			for key in spectates[spectate_type].keys():
				if spectates[spectate_type][key].is_active:
					return spectates[spectate_type][key]
		else:
			for key in spectates.Spawn.keys():
				if spectates.Spawn[key].is_active:
					if Units.unit_by_tile_bool(spectates.Spawn[key].object):
						spectates.Spawn[key].is_active = false
						return onFindSpawnAlternativeTile()
					return spectates.Spawn[key]
			return onFindSpawnAlternativeTile()
	return {}
	
func onFindSpawnAlternativeTile() -> Dictionary:
	for key in spectates.Spawn.keys():
		if !Units.unit_by_tile_bool(spectates.Spawn[key].object):
			spectates.Spawn[key].is_active = true
			return spectates.Spawn[key]
	return {}
func onCameraStartSpectate(spectate_info: Dictionary) -> void:
	central_point = spectate_info.object.global_position
	central_point.y += spectate_info.central_point
	position = Vector3(central_point.x, central_point.y + spectate_info.look_at, central_point.z)
	setCameraPointAlongCircle()
func setCameraPointAlongCircle(progress: Vector2 = Vector2.ZERO) -> void:
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
func onStartPhaseStart() -> void:
	var i: int = 0
	for Tile in Tiles.on_is_type_get_tiles("Spawn", "obj"):
		spectates.Spawn[Tile.get_instance_id()] = {
			"progress": Vector2.ZERO,
			"is_active": i == 0,
			"look_at": SPAWN_CAMERA_LOOK_AT_HEIGHT,
			"central_point": SPAWN_CAMERA_CENTRAL_POINT_HEIGHT,
			"object": Tile,
		}
		i+= 1
	onSpectate("Spawn")
	
func onSpectate(type: Variant) -> void:
	var spectate_info: Dictionary = onGetActiveSpectateVariant()
	if !spectate_info.is_empty(): spectate_info.progress = total_progress
	
	if type is int: onSpectateDirection(spectate_info, spectate_type, type)
	elif type is String: onSpectateNewType(spectate_info, type, spectate_type)
	elif type is UnitGD or type is TileGD: onSpectateObject(type, spectate_info, spectate_type)
	elif type is Dictionary: onSpectateOldSpectateType(type, spectate_info)
	onChangeCameraMode(true)
			
func onSpectateOldSpectateType(spectate_info: Dictionary, _spectate_info: Dictionary) -> void:
	if spectate_info == _spectate_info:
		pass
			
func onSpectateObject(Obj: Variant, _spectate_info: Dictionary, _spectate_type: String) -> void:
	spectate_type = ("Ally" if Obj.team == 0 else "Enemy") if Obj is UnitGD else "Spawn"
	var spectate_info: Dictionary = spectates[spectate_type][Obj.get_instance_id()]
	
	if spectate_info != _spectate_info:
		onClearIsActive(spectate_info, spectate_type)
		onCameraStartSpectate(spectate_info)
		onUnitSpectated(spectate_info, _spectate_info, _spectate_type)
	
func onSpectateNewType(_spectate_info: Dictionary, _spectate_type: String, old_spectate_type: String) -> void:
	if spectate_type != _spectate_type:
		spectate_type = _spectate_type
		var spectate_info: Dictionary = onGetActiveSpectateVariant()
		if !spectate_info.is_empty():
			total_progress = spectate_info.progress
			onCameraStartSpectate(spectate_info)
			onUnitSpectated(spectate_info, _spectate_info, old_spectate_type)
		else: spectate_type = old_spectate_type
		
func onSpectateDirection(_spectate_info: Dictionary, _spectate_type: String, direction: int) -> void:
	if !_spectate_info.is_empty():
		var spectate_type_keys: Array = getSpectateTypeKeys()
		var new_index: int = 0
		var index: int = -1
		
		_spectate_info.is_active = false
		index = spectate_type_keys.map(func(x: Dictionary): return x.object.get_instance_id()).find(_spectate_info.object.get_instance_id())
		var max_size: int = spectate_type_keys.size()
		
		if index == -1: new_index = 0
		elif index == 0 and direction == -1: new_index = max_size - 1
		elif index == max_size - 1 and direction == 1: new_index = 0
		else: new_index = index + direction
		
		var spectate_info: Dictionary = spectate_type_keys[new_index]
		
		if spectate_info != _spectate_info:
			spectate_info.is_active = true
			total_progress = spectate_info.progress
			
			onCameraStartSpectate(spectate_info)
			onUnitSpectated(spectate_info, _spectate_info, spectate_type)
		
func onClearIsActive(spectate_info: Dictionary, type: String) -> void:
	for _spectate_info in spectates[type].values():
		_spectate_info.is_active = false
	spectate_info.is_active = true
		
func getSpectateTypeKeys() -> Array:
	if spectate_type == "Spawn":
		var unoccupied_spawn_dicts: Array = []
		for spawn_dict in spectates.Spawn.values():
			if !Units.unit_by_tile_bool(spawn_dict.object):
				unoccupied_spawn_dicts.append(spawn_dict)
		return unoccupied_spawn_dicts
	return spectates[spectate_type].values().filter(func(x: Dictionary): return x.object.team == 0 or x.object.Tile in Vision.ally_vision)
		
func onUnitSpectated(spectate_info: Dictionary, _spectate_info: Dictionary, _spectate_type: String) -> void:
	if spectate_type in ["Ally", "Enemy"]:
		spectate_info.object.on_spectated_in_player_phase(true)
		if Vision.vision_mode == 1: Vision.on_recalculate_vision(spectate_info.object)
		Units.onSpectatedInPlayerPhase(spectate_info.object)
		
	if _spectate_type in ["Ally", "Enemy"]:
		Units.PlayerManager._on_unit_deselected(Units.PlayerManager.UnitSelected)
		if !_spectate_info.is_empty(): _spectate_info.object.on_spectated_in_player_phase(false)
		
func onPlayerPhaseStart() -> void:
	onEndTrackUnit()
	onSpectate("Ally")
func onPlayerEndTurnPhaseStart() -> void:
	onEndTrackUnit()
	onSpectate("Ally")
func onHandPhaseStart() -> void:
	onEndTrackUnit()
	onSpectate("Ally")
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().update_mouse_cursor_state()
		mouse_in_ui.emit(true)
		
	elif Input.is_action_just_released(Helper.interact_button(true)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_in_ui.emit(false)
			
	if is_unit_camera:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			setCameraPointAlongCircle((event.relative / 10000) * CAMERA_ROTATION_SPEED)

	onFreelookCamera(event)

var track_unit_info: Dictionary
func onStartTrackUnit(Unit: UnitGD) -> void:
	track_unit_info = spectates["Ally" if Unit.team == 0 else "Enemy"][Unit.get_instance_id()].duplicate()
	onSpectate(Unit)
func onEndTrackUnit() -> void:
	track_unit_info = {}
func onTrackUnit() -> void:
	onCameraStartSpectate(track_unit_info)
	
var thread: Thread
func _ready() -> void:
	thread = Thread.new()
	
func onUpdateFreelookThread(delta: float) -> void:
	onUpdateFreelookCamera(delta)
	
func _process(delta: float) -> void:
	if !track_unit_info.is_empty(): onTrackUnit()
	onUpdateFreelookCamera(delta)

func onUnitAwakened(Unit: UnitGD) -> void:
	var team_spectate_type: String = "Ally" if Unit.team == 0 else "Enemy"
	spectates[team_spectate_type][Unit.get_instance_id()] = {
		"progress": Vector2.ZERO,
		"is_active": false,
		"look_at": Unit.height.top * CAMERA_UNIT_HEIGHT_MULTIPLIER,
		"central_point": Unit.height.top * LOOK_AT_UNIT_HEIGHT_MULTIPLIER,
		"object": Unit,
	}
func onDeathFinished(Unit: UnitGD) -> void:
	spectates["Ally" if Unit.team == 0 else "Enemy"].erase(Unit.get_instance_id())
	if !track_unit_info.is_empty() and track_unit_info.object == Unit: onEndTrackUnit()
	
func getSpectateUnit(team: Array = ["Ally"]) -> UnitGD:
	if spectate_type in team:
		var spectate_info: Dictionary = onGetActiveSpectateVariant()
		if !spectate_info.is_empty(): return spectate_info.object
	return null

const FOV_TYPES: Dictionary = {
	"UNIT_MODE": 100,
	"REGULAR": 75,
}

const FOV_TWEEN_TIME: float = 0.2
func onUpdateFOV(type: String) -> void:
	var FOVTween := create_tween()
	FOVTween.tween_property(Camera, "fov", FOV_TYPES[type], FOV_TWEEN_TIME)

var last_spectate: Dictionary
var is_unit_camera: bool = true
func onChangeCameraMode(state: bool, type: Variant = "") -> void:
	if is_unit_camera != state:
		is_unit_camera = state
		if is_unit_camera:
			if type == "": # Change camera mode and go back to last spectate
				onSpectate(last_spectate)
				last_spectate = {}
			else: # Change camera mode and go to specified spectate
				onSpectate(type)
				last_spectate = {}
			setCameraPointAlongCircle(total_progress)
		else:
			_total_pitch = 0
			last_spectate = onGetActiveSpectateVariant()
			onEndTrackUnit()
	
# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

func onFreelookCamera(event: InputEvent) -> void:
	if !is_unit_camera:
		if event is InputEventMouseMotion:
			_mouse_position = event.relative
		
		# Receives mouse button input
		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
					_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
				MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
					_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

		# Receives key input
		if event is InputEventKey and !(get_viewport().gui_get_focus_owner() as LineEdit):
			match event.keycode:
				KEY_W:
					_w = event.pressed
				KEY_S:
					_s = event.pressed
				KEY_A:
					_a = event.pressed
				KEY_D:
					_d = event.pressed
func onUpdateFreelookCamera(delta: float) -> void:
	if !is_unit_camera:
		_update_mouselook()
		_update_movement(delta)
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3((_d as float) - (_a as float), 
						(_e as float) - (_q as float), 
						(_s as float) - (_w as float))
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

