extends Node3D

signal zooming
#region Exports
# How high / low the level camera can go
@export var Y_SPHERE_BLOCK: float = 0.3
# How much to add to the default central point for cards / spawns
@export var SPAWN_CENTRAL_Y: float = 1.4
@export var CARD_CENTRAL_Y: float = 0.5
# How fast camera rotates
@export var CAMERA_ROTATION_SPEED: float = 3.0

# How much to zoom in / out when scroll is pressed
@export var CAMERA_RADIUS_INCREMENT: float = 0.3
# How far you can zoom in and out overall
@export var CAMERA_RADIUS_UPPER_BOUND: float = 7.0
@export var CAMERA_RADIUS_LOWER_BOUND: float = 0.5
#endregion

#region Globals
@onready var LevelCamera: Camera3D = %LevelCamera
@onready var FreelookCamera: Camera3D = %FreeLookCamera
var CurrentCamera: Camera3D

var camera_radius: float = 3
var central_point: Vector3
var ally_spectate_index: int
var spawn_spectate_index: int
var spectate_index: int
var spectate_type: Game.SpectateTypes
var total_progress: Vector2
var action_lock: bool = false
#endregion

#region Helpers
func getCameraObjectArray() -> Array:
	match spectate_type:
		Game.SpectateTypes.ALLY: return Game.getAllyUnits()
		Game.SpectateTypes.ENEMY: return Game.getEnemyUnits()
		Game.SpectateTypes.SPAWN: return get_tree().get_nodes_in_group("AllySpawnsGD")
	return []
#endregion

#region Action Lock
func setActionLock(_action_lock: bool) -> void:
	action_lock = _action_lock
	if CurrentCamera == FreelookCamera:
		setCameraType(false)
#endregion
		
#region Base Functions
func setInfo(level_camera_data: LevelCameraData) -> void:
	if level_camera_data != null:
		ally_spectate_index = level_camera_data.ally_spectate_index
		spawn_spectate_index = level_camera_data.spawn_spectate_index
		spectate_type = level_camera_data.spectate_type
		total_progress = level_camera_data.total_progress
		FreelookCamera.position = level_camera_data.freelook_posrot.pos
		FreelookCamera.rotation = level_camera_data.freelook_posrot.rot
		setCameraType(level_camera_data.is_in_freelook)
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ChangeCameraLeft"): onChangeCameraInDirection(-1)
	elif Input.is_action_just_pressed("ChangeCameraRight"): onChangeCameraInDirection(1)
	
	if !action_lock and CurrentCamera == LevelCamera:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
			setCameraPointAlongCircle((event.relative / 10000) * CAMERA_ROTATION_SPEED)
		elif Input.is_action_just_pressed("ZoomIn"): setCameraRadius(-1); zooming.emit()
		elif Input.is_action_just_pressed("ZoomOut"): setCameraRadius(1); zooming.emit()
#endregion

#region Spectate
var SpectateObject: FofGD
func onResetSpectate() -> void:
	var camera_objects: Array = getCameraObjectArray()
	if !camera_objects.is_empty():
		if spectate_index >= camera_objects.size(): spectate_index = 0
		SpectateObject = camera_objects[spectate_index]
		central_point = SpectateObject.position
		central_point.y += (SPAWN_CENTRAL_Y) if SpectateObject is SpawnGD else (SpectateObject.info.top + CARD_CENTRAL_Y)
		setCameraPointAlongCircle()
	
func setCameraPointAlongCircle(progress := Vector2.ZERO) -> void:
	if progress != Vector2.ZERO:
		total_progress.x = clampf(total_progress.x + progress.x, 0, 1)
		if total_progress.x <= 0: total_progress.x = 1
		elif total_progress.x >= 1: total_progress.x = 0
		
		total_progress.y = clampf(total_progress.y + progress.y, -Y_SPHERE_BLOCK, Y_SPHERE_BLOCK)
	
	var theta: float = total_progress.x * 2 * PI
	var phi: float = total_progress.y * PI

	CurrentCamera.position.x = cos(phi) * cos(theta) * camera_radius + central_point.x
	CurrentCamera.position.y = sin(phi) * camera_radius + central_point.y
	CurrentCamera.position.z = cos(phi) * sin(theta) * camera_radius + central_point.z
	CurrentCamera.look_at(central_point)
	
func setCameraRadius(direction: int) -> void:
	camera_radius = clamp(camera_radius + (CAMERA_RADIUS_INCREMENT * direction), CAMERA_RADIUS_LOWER_BOUND, CAMERA_RADIUS_UPPER_BOUND)
	setCameraPointAlongCircle()
#endregion

#region Reseters
func setCameraType(is_freelook: bool, override_action_lock: bool = false) -> void:
	if (!action_lock or override_action_lock) and  \
	(CurrentCamera == null or (!is_freelook and CurrentCamera == LevelCamera) or (is_freelook and CurrentCamera == FreelookCamera)):
		if CurrentCamera != null:
			CurrentCamera.current = false
		
		CurrentCamera = LevelCamera if !is_freelook else FreelookCamera
		CurrentCamera.current = true
	
func onSpectateSpawn() -> void:
	if spectate_type != Game.SpectateTypes.SPAWN:
		setCameraType(false, true)
		spectate_type = Game.SpectateTypes.SPAWN
		
		spectate_index = spawn_spectate_index
		setSpawnSpectateIndex()
		onResetSpectate()
		setSpectateIndex()
	
func onSpectateCard(Card: CardGD) -> void:
	setCameraType(false, true)
	spectate_type = Game.SpectateTypes.ALLY if Card.isAlly() else Game.SpectateTypes.ENEMY
	spectate_index = getCameraObjectArray().find(Card)
	onResetSpectate()
	setSpectateIndex()
	
func onSpectateAllies() -> void:
	if spectate_type != Game.SpectateTypes.ALLY:
		setCameraType(false, true)
		spectate_index = ally_spectate_index
		spectate_type = Game.SpectateTypes.ALLY
		onResetSpectate()
		setSpectateIndex()
	
func onChangeCameraInDirection(direction: int) -> void:
	if !action_lock:
		var arr: Array = getCameraObjectArray()
		spectate_index = getSpectateIndex()
		if spectate_index + direction == arr.size(): spectate_index = 0
		elif spectate_index + direction < 0: spectate_index = arr.size() - 1
		else: spectate_index += direction
		
		setSpawnSpectateIndex(arr, direction)
		onResetSpectate()
		setSpectateIndex()
		
#endregion
	
#region Spectate Index
func getSpectateIndex() -> int:
	match spectate_type:
		Game.SpectateTypes.SPAWN: return spawn_spectate_index
		Game.SpectateTypes.ALLY: return ally_spectate_index
		_: return spectate_index

func setSpectateIndex() -> void:
	match spectate_type:
		Game.SpectateTypes.SPAWN: spawn_spectate_index = spectate_index
		Game.SpectateTypes.ALLY: ally_spectate_index = spectate_index

func setSpawnSpectateIndex(arr: Array = getCameraObjectArray(), direction: int = 1) -> void:
	if spectate_type == Game.SpectateTypes.SPAWN:
		arr = arr.map(func(x: SpawnGD): return null if x.isSpawnOccupied() else x)
		
		while (arr[spectate_index] == null):
			if spectate_index + direction == arr.size(): spectate_index = 0
			elif spectate_index + direction < 0: spectate_index = arr.size() - 1
			else: spectate_index += direction
#endregion
	
#region Save
func setCameraSaveables(level: LevelGD) -> void:
	level.level_camera_data = LevelCameraData.new(\
		spectate_type, ally_spectate_index, spawn_spectate_index, CurrentCamera == FreelookCamera,\
		PosRot.new(FreelookCamera.position, FreelookCamera.rotation), total_progress, camera_radius)
#endregion
