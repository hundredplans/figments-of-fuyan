extends Node3D

#region Exports
@export var CAMERA_OFFSET: Vector3
@export var UNIT_SPOTLIGHT_UP_OFFSET: float
#endregion

#region Globals
signal action_lock
var MapCard: CardGD
var save_file: SaveFileGD
var area: AreaGD
var UI: Control
var ActiveWorld: Node3D

var is_camera_disabled_by_ui: bool

const MOUSE_HOLD_SLOWDOWN: float = 0.005

@onready var WorldEnv: WorldEnvironment = %WorldEnvironment
@onready var Camera: Camera3D = %MovementCamera
@onready var UnitSpotlight: SpotLight3D = %UnitSpotlight
#endregion

#region Helper Functions
func isActionLock() -> bool:
	return is_map_starting or is_unit_walking_to_map_node or is_unit_entered
	
func getMapNodeDestination(map_node: MapNodeGD) -> Vector3:
	return Vector3(map_node.position.x, 0, 0)
#endregion

#region Base Functions
func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	
	area.init_load.connect(onInitLoad)
	
	var Card: CardGD = save_file.getChampionCard()
	MapCard = Card
	MapCard.onCreateModel()
	MapCard.onIdle()
	MapCard.Model.rotation_degrees.y = 90
	
	var EnteredMapNode: MapNodeGD = area.getEnteredMapNode()
	var spotlight_destination := EnteredMapNode.position
	spotlight_destination.y += UNIT_SPOTLIGHT_UP_OFFSET
	UnitSpotlight.position = spotlight_destination
	MapCard.position = EnteredMapNode.position
	Camera.position = getMapNodeDestination(EnteredMapNode) + CAMERA_OFFSET
	
	UI.screen_created.connect(onScreenCreated)
	
	setEnvironment()
	for map_node in get_tree().get_nodes_in_group("MapNodesGD"):
		map_node.pressed.connect(onMapNodePressed)
		map_node.entered.connect(onMapNodeEntered)
		map_node.finished.connect(onMapNodeFinished)
		map_node.create_world_scene.connect(onMapNodeCreateWorldScene)
	
func onInitLoad() -> void:
	onMapStartAnimation()
	
func _input(event: InputEvent) -> void:
	if Camera.current:
		if Input.is_action_just_pressed("AltInput") and !is_camera_disabled_by_ui:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Camera.onDisableMovement(true)
			get_viewport().warp_mouse(get_viewport().get_mouse_position())
		elif Input.is_action_just_released("AltInput") and !is_camera_disabled_by_ui:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Camera.onDisableMovement(false)
			get_viewport().warp_mouse(get_viewport().get_mouse_position())
		
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Camera.position.x += -event.relative.x * MOUSE_HOLD_SLOWDOWN
			Camera.onClampPosition()
#endregion

#region Map Node Selected / Entered / Finished
var is_unit_walking_to_map_node: bool = false
var is_unit_entered: bool = false
func onMapNodePressed(map_node: MapNodeGD) -> void:
	var EnteredMapNode: MapNodeGD = area.getEnteredMapNode()
	if !(EnteredMapNode.isMapNodeLink(map_node) and EnteredMapNode.is_finished): return
	
	var spotlight_destination := map_node.position
	spotlight_destination.y += UNIT_SPOTLIGHT_UP_OFFSET
		
	is_unit_walking_to_map_node = true
	onUpdateActionLock()
	MapCard.onWalkTo(map_node.position, Game.SELECTED_MAP_NODE_TRAVEL_SPEED)
	MapCard.onLookAtObjectOnlyY(map_node)
	
	var tween := get_tree().create_tween()
	tween.tween_property(UnitSpotlight, "position", spotlight_destination, Game.SELECTED_MAP_NODE_TRAVEL_SPEED)
	
	var camera_tween := get_tree().create_tween()
	camera_tween.tween_property(Camera, "position:x", map_node.position.x, Game.SELECTED_MAP_NODE_TRAVEL_SPEED)
	
	await tween.finished
	is_unit_walking_to_map_node = false
	onUpdateActionLock()

func onMapNodeEntered(_map_node: MapNodeGD) -> void:
	is_unit_entered = true
	onUpdateActionLock()
	
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	is_unit_entered = false
	onUpdateActionLock()
	
	onDisableCameraByUI(false)
	if ActiveWorld != null:
		ActiveWorld.queue_free()
		WorldEnv.environment = area.info.base_environment
#endregion

#region Map Start
@export var MAP_START_DELAY_TIME: float = 1
@export var MAP_START_TRAVEL_TIME: float = 7
var is_map_starting: bool
func onMapStartAnimation() -> void:
	if Helper.getAdmin(): return
	
	var map_node: MapNodeGD = area.getEnteredMapNode()
	is_map_starting = true
	onUpdateActionLock()
	
	var boss_node: MapNodeGD = area.getBossMapNode()
	var start_node: MapNodeGD = area.getStartMapNode()
	Camera.position = getMapNodeDestination(boss_node) + CAMERA_OFFSET
	
	await get_tree().create_timer(MAP_START_DELAY_TIME).timeout
	var tween := get_tree().create_tween()
	var relative_position: float = getMapNodeDestination(start_node).x - Camera.position.x
	tween.tween_property(Camera, "position:x", relative_position, MAP_START_TRAVEL_TIME).as_relative()\
	.set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	is_map_starting = false
	onUpdateActionLock()
#endregion

#region Action Lock
func onUpdateActionLock() -> void:
	var state: bool = isActionLock()
	action_lock.emit(state)
	get_tree().call_group("MapNodesGD", "setRayPickableGlobal", !state)
#endregion

#region Environment
func setEnvironment() -> void:
	WorldEnv.environment = area.info.base_environment\
	if !area.isAfterMiniboss() else area.info.late_environment
#endregion

#region World Screen
func onMapNodeCreateWorldScene(map_node: MapNodeGD, _ActiveWorld: Node3D) -> void:
	ActiveWorld = _ActiveWorld
	add_child(ActiveWorld)
	ActiveWorld.setInfo(map_node)
	
	ActiveWorld.position = Vector3(0, 1000, 0)
	
	Camera.current = false
	WorldEnv.environment = null
#endregion

#region Screen
func onScreenCreated() -> void:
	onDisableCameraByUI(true)
#region Camera
func onDisableCameraByUI(state: bool) -> void:
	is_camera_disabled_by_ui = state
	Camera.onDisableMovement(state)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#endregion
