class_name SpectateCameraGD
extends Node3D

signal mouse_in_ui

@onready var Camera = %Camera3D

@export var LOOK_AT_UNIT_HEIGHT_MULTIPLIER: float = 0.8
@export var CAMERA_UNIT_HEIGHT_MULTIPLIER: float = 1.2

@export var CAMERA_RADIUS_INCREMENT: float = 0.3
@export var CAMERA_RADIUS_LOWER_BOUND: float = 0.5
@export var CAMERA_RADIUS: float = 3.0
@export var CAMERA_RADIUS_UPPER_BOUND: float = 7.0
@export var CAMERA_ROTATION_SPEED: float = 3.0

@export var SPAWN_CAMERA_CENTRAL_POINT_HEIGHT: float = 2.4
@export var SPAWN_CAMERA_LOOK_AT_HEIGHT: float = 1.7

var Vision: VisionGD
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var Units: UnitsGD
var Tiles: TilesGD

var central_point: Vector3
var total_progress := Vector2.ZERO
var Y_SPHERE_BLOCK: float = 0.3

var spawn_tiles: Array = []
var SpectateUnit: UnitGD
var SpectateTile: TileGD
var is_spectate_spawn: bool = false
var invisible_unit_stop_track: bool = false

func onSpectate(Obj: Variant) -> void:
	onStopTrack(false)
	if Obj != null and (!Obj is UnitGD or !Obj.is_dead):
		if is_spectate_spawn: onSpectateSpawnTile(Obj)
		else: onSpectateUnit(Obj)
		onChangeCameraMode(true)
		return
	onSpectateUnitPlayerPhase()

func getUnoccupiedSpawnTiles() -> Array:
	var unit_tiles: Array = Units.all_units().map(func(x: UnitGD): return x.Tile)
	return spawn_tiles.filter(func(x: TileGD): return x not in unit_tiles)

func onSpectateSpawnTile(type: Variant) -> void:
	var Tile: TileGD
	var empty_spawn_tiles: Array = getUnoccupiedSpawnTiles()
	if type is int and SpectateTile != null:
		var tiles: Array = empty_spawn_tiles
		if tiles.size() > 1:
			var index: int = tiles.find(SpectateTile)
			index = clamp(index + type, -1, tiles.size())
			if index == tiles.size(): index = 0
			elif index == -1: index = tiles.size() - 1
			Tile = tiles[index]
	elif type is String and empty_spawn_tiles.size() > 0:
		Tile = empty_spawn_tiles[0]
	elif type is TileGD: if type != SpectateTile: Tile = type
	
	if Tile != null:
		SpectateTile = Tile
		onSpectateUnitPlayerPhase()
		onCameraStartSpectate(SpectateTile)
	
func onSpectateUnitPlayerPhase() -> void:
	if SpectateUnit != null:
		var Unit: UnitGD = SpectateUnit
		SpectateUnit = null
		Unit.onSpectatedPlayerPhase(false)
	
func onSpectateUnit(type: Variant) -> void:
	var Unit: UnitGD
	var ally_vision: Array = Vision.getTeamVision()
	if type is String:
		if SpectateUnit != null:
			if type == "AllySelf" and SpectateUnit.team == 0:
				Unit = SpectateUnit
			else:
				var relation := TeamRelationGD.new(SpectateUnit.team, type)
				var units: Array = Units.on_units(relation)
				if relation.onTeam() == 1: units = units.filter(func(x: UnitGD): return x.Tile in ally_vision)
				Unit = Units.onFindClosestUnitFromUnits(SpectateUnit, units)
		else:
			if type == "AllySelf": type = "Ally"
			var units: Array = Units.on_units(TeamRelationGD.new(0, type))
			if units.size() > 0: Unit = units[0]
	elif type is int and SpectateUnit != null:
		var units: Array = Units.on_units(TeamRelationGD.new(SpectateUnit.team))
		if SpectateUnit.team == 1: units = units.filter(func(x: UnitGD): return x.Tile in ally_vision)
		if units.size() > 1:
			var index: int = units.find(SpectateUnit)
			index = clamp(index + type, -1, units.size())
			if index == units.size(): index = 0
			elif index == -1: index = units.size() -1
			
			Unit = units[index]
	elif type is UnitGD: if type != SpectateUnit: Unit = type
	
	if Unit != null:
		onSpectateUnitPlayerPhase()
		if SpectateTile != null: SpectateTile = null
		SpectateUnit = Unit
		Unit.onSpectatedPlayerPhase(true)
		Units.onSpectatedInPlayerPhase(Unit)
		
		if Vision.vision_mode == 1: Vision.setActiveUnitVision(Unit)
		
		onCameraStartSpectate(SpectateUnit)
	
func onCameraStartSpectate(Obj: Variant) -> void:
	central_point = Obj.global_position
	central_point.y += SPAWN_CAMERA_CENTRAL_POINT_HEIGHT if Obj is TileGD else (Obj.height.top * CAMERA_UNIT_HEIGHT_MULTIPLIER)
	Camera.position = Vector3(central_point.x, central_point.y +\
	SPAWN_CAMERA_LOOK_AT_HEIGHT if Obj is TileGD else (Obj.height.top * LOOK_AT_UNIT_HEIGHT_MULTIPLIER),\
	central_point.z)
	
	setCameraPointAlongCircle()
	
func setCameraPointAlongCircle(progress: Vector2 = Vector2.ZERO) -> void:
	if progress != Vector2.ZERO:
		total_progress.x = clampf(total_progress.x + progress.x, 0, 1)
		if total_progress.x <= 0: total_progress.x = 1
		elif total_progress.x >= 1: total_progress.x = 0
		
		total_progress.y = clampf(total_progress.y + progress.y, -Y_SPHERE_BLOCK, Y_SPHERE_BLOCK)
	
	var theta: float = total_progress.x * 2 * PI
	var phi: float = total_progress.y * PI

	Camera.position.x = cos(phi) * cos(theta) * CAMERA_RADIUS + central_point.x
	Camera.position.y = sin(phi) * CAMERA_RADIUS + central_point.y
	Camera.position.z = cos(phi) * sin(theta) * CAMERA_RADIUS + central_point.z
	Camera.look_at(central_point)
	
func onStartPhaseStart() -> void:
	is_spectate_spawn = true
	spawn_tiles = Tiles.on_is_type_get_tiles("Spawn", "obj")
	onSpectate(spawn_tiles[0])
		
func onPlayerPhaseStart() -> void:
	is_spectate_spawn = false
	onSpectate("AllySelf")
	
func onHandPhaseStart() -> void:
	onSpectate("AllySelf")
	
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
		if !LevelUI.is_mouse_in_ui:
			if Input.is_action_just_released("ScrollUp"):
				CAMERA_RADIUS = max(CAMERA_RADIUS - CAMERA_RADIUS_INCREMENT, CAMERA_RADIUS_LOWER_BOUND)
				setCameraPointAlongCircle()
				
			elif Input.is_action_just_released("ScrollDown"):
				CAMERA_RADIUS = min(CAMERA_RADIUS + CAMERA_RADIUS_INCREMENT, CAMERA_RADIUS_UPPER_BOUND)
				setCameraPointAlongCircle()

	onFreelookCamera(event)
	
func _process(delta: float) -> void:
	if SpectateUnit != null and is_unit_camera and !invisible_unit_stop_track:
		onCameraStartSpectate(SpectateUnit)
	onUpdateFreelookCamera(delta)

var OldSpectateUnit: UnitGD
var is_unit_camera: bool = true
func onChangeCameraMode(state: bool) -> void:
	if is_unit_camera != state:
		is_unit_camera = state
		@warning_ignore("incompatible_ternary")
		if is_unit_camera: onSpectate(OldSpectateUnit if OldSpectateUnit != null else "Ally")
		else: OldSpectateUnit = SpectateUnit; _total_pitch = 0; onSpectate(null); LevelUI._on_team_button_item_selected(LevelUI.team_selected)
	
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
			Tiles.on_mouse_entered(Tiles.on_find_tile_by_raycast())
					
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
	
		Camera.translate(_velocity * delta * speed_multi)
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
	
		Camera.rotate_y(deg_to_rad(-yaw))
		Camera.rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func onStopTrack(state: bool = true) -> void:
	invisible_unit_stop_track = state
