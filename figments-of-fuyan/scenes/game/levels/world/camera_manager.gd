extends Node3D

signal update_ui
signal camera_position_updated
signal create_camera_action
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

var total_progress: Vector2
var action_lock: bool = false
var last_freelook_rotation: Vector3

var LastSpawnSpectateObject: SpawnGD # Not saved across sessions
var LastAllySpectateObject: CardGD
var LastEnemySpectateObject: CardGD
var LastCycleSpectateObject: GameObjectGD
var cycle_objects: Array
#endregion

#region Helpers
func isFreelook() -> bool:
	return CurrentCamera == FreelookCamera
#endregion

#region Action Lock
func setActionLock(_action_lock: bool) -> void:
	action_lock = _action_lock
	if isFreelook(): setCameraType(false)
#endregion
		
#region Base Functions
func setInfo(level_camera_data: LevelCameraData) -> void:
	if level_camera_data != null:
		total_progress = level_camera_data.total_progress
		FreelookCamera.position = level_camera_data.freelook_posrot.pos
		FreelookCamera.rotation = level_camera_data.freelook_posrot.rot
		
		setCameraType(level_camera_data.is_in_freelook)
		
		onCreateCameraChangeAction(\
			getGameObjectFromCoords(level_camera_data.coords) if !level_camera_data.is_in_freelook else null)
		
func _input(event: InputEvent) -> void:
	if CurrentCamera == LevelCamera:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
			setCameraPointAlongCircle((event.relative / 10000) * CAMERA_ROTATION_SPEED)
			
		if Input.is_action_just_pressed("ZoomIn"): setCameraRadius(-1); zooming.emit()
		elif Input.is_action_just_pressed("ZoomOut"): setCameraRadius(1); zooming.emit()
			
		if !action_lock and !get_viewport().gui_get_focus_owner() is LineEdit:
			if Input.is_action_just_pressed("ChangeCameraLeft"): onChangeCameraInDirection(-1)
			elif Input.is_action_just_pressed("ChangeCameraRight"): onChangeCameraInDirection(1)
		
func getGameObjectFromCoords(coords: Vector4i) -> GameObjectGD:
	var Tile: TileGD = Game.getTile(coords)
	var Card: CardGD = Game.getFieldCard(Tile)
	if Card == null: return Tile.getSpawnTile()
	return Card
#endregion

#region Spectate
var SpectateObject: GameObjectGD
func onCameraChange(_SpectateObject: GameObjectGD) -> void:
	SpectateObject = _SpectateObject
	if SpectateObject != null:
		setCameraType(false)
		setCameraCentralPoint()
		setCameraPointAlongCircle()

func onCreateCameraChangeAction(NewSpectateObject: GameObjectGD) -> void:
	create_camera_action.emit(NewSpectateObject)
	
func setCameraCentralPoint() -> void:
	central_point = SpectateObject.position
	central_point.y += (SPAWN_CENTRAL_Y) if SpectateObject is SpawnGD else (SpectateObject.info.top + CARD_CENTRAL_Y)
	
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
	camera_position_updated.emit(CurrentCamera.position)
	
func setCameraRadius(direction: int) -> void:
	camera_radius = clamp(camera_radius + (CAMERA_RADIUS_INCREMENT * direction), CAMERA_RADIUS_LOWER_BOUND, CAMERA_RADIUS_UPPER_BOUND)
	setCameraPointAlongCircle()
#endregion

#region Reseters
func onSwapCameraType() -> void:
	setCameraType(CurrentCamera == LevelCamera, true)

func setCameraType(is_freelook: bool, spectate_first_ally: bool = false) -> void:
	if (CurrentCamera == null or (is_freelook and CurrentCamera == LevelCamera) or (!is_freelook and CurrentCamera == FreelookCamera)):
		if CurrentCamera != null:
			CurrentCamera.current = false
			CurrentCamera.disable_freelook = true
		
		CurrentCamera = LevelCamera if !is_freelook else FreelookCamera
		CurrentCamera.current = true
		CurrentCamera.disable_freelook = false
		
		FreelookCamera.disable_movement = CurrentCamera != FreelookCamera
		
		if is_freelook: FreelookCamera.rotation_degrees = last_freelook_rotation
		else: last_freelook_rotation = FreelookCamera.rotation_degrees
		
		if is_freelook: onCreateCameraChangeAction(null)
		elif spectate_first_ally: onSpectateAllies()
		
func onSpectateSpawn() -> void:
	var _SpectateObject: GameObjectGD = LastSpawnSpectateObject
	if _SpectateObject == null:
		var spawns: Array = get_tree().get_nodes_in_group("AllySpawnsGD").filter(func(x: SpawnGD): return !x.isSpawnOccupied())
		if !spawns.is_empty(): _SpectateObject = spawns[0]
	
	onCreateCameraChangeAction(_SpectateObject)
	
func onSpectateAllies() -> void:
	var _SpectateObject: GameObjectGD = LastAllySpectateObject
	if _SpectateObject == null:
		var allies: Array = Game.getAllyUnits()
		if !allies.is_empty(): _SpectateObject = allies[0]
	
	onCreateCameraChangeAction(_SpectateObject)
	
func onSpectateCycle() -> void:
	var _SpectateObject: GameObjectGD = LastCycleSpectateObject
	if _SpectateObject == null:
		if !cycle_objects.is_empty(): _SpectateObject = cycle_objects[0]
	
	onCreateCameraChangeAction(_SpectateObject)
	
func onChangeCameraInDirection(direction: int) -> void:
	if !action_lock and SpectateObject != null:
		var arr: Array = getCameraObjectArray()
		var spectate_index: int = arr.find(SpectateObject)
		
		if spectate_index + direction == arr.size(): spectate_index = 0
		elif spectate_index + direction < 0: spectate_index = arr.size() - 1
		else: spectate_index += direction
		
		onCreateCameraChangeAction(arr[spectate_index])
		
func getCameraObjectArray() -> Array:
	if SpectateObject != null:
		if !cycle_objects.is_empty(): return cycle_objects
		elif SpectateObject is SpawnGD: return get_tree().get_nodes_in_group("AllySpawnsGD").filter(func(x: SpawnGD): return !x.isSpawnOccupied())
		elif SpectateObject.isAlly(): return Game.getAllyUnits()
		else: return Game.getEnemyUnits().filter(func(x: CardGD): return x.level_visible)
	return []
#endregion
	
#region Save
func setCameraSaveables(level: LevelGD) -> void:
	var coords := Vector4i(0, 0, 0, -1)
	if SpectateObject != null:
		if SpectateObject is SpawnGD: coords = SpectateObject.getCoords()[0]
		elif SpectateObject is CardGD: coords = SpectateObject.getCoords()
	
	level.level_camera_data = LevelCameraData.new(coords, isFreelook(), PosRot.new(FreelookCamera.position, FreelookCamera.rotation), total_progress, camera_radius)
#endregion

#region Tracking
var previous_position: Vector3
var track_card: bool = true
func _process(_delta: float) -> void:
	if SpectateObject is CardGD and track_card:
		setCameraCentralPoint()
		setCameraPointAlongCircle()
#endregion

#region Cycle
func setCycleObjects(_cycle_objects: Array) -> void:
	cycle_objects = _cycle_objects
	if !cycle_objects.is_empty():
		onSpectateCycle()
		
func onRemoveCycleObjects() -> void:
	cycle_objects = []
		
func isCycle() -> bool:
	return !cycle_objects.is_empty()
#endregion
