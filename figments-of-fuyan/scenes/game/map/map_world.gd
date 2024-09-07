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
@onready var WorldEnv: WorldEnvironment = %WorldEnvironment
@onready var Camera: Camera3D = %MovementCamera
@onready var UnitSpotlight: SpotLight3D = %UnitSpotlight
#endregion

#region Helper Functions
func isActionLock() -> bool:
	return is_map_starting or is_unit_walking_to_map_node or is_unit_in_map_node_screen
	
func getMapNodeDestination(map_node: MapNodeGD) -> Vector3:
	return Vector3(map_node.position.x, 0, 0)
#endregion

#region Action Lock
func onUpdateActionLock() -> void:
	var state: bool = isActionLock()
	action_lock.emit(state)
	get_tree().call_group("MapNodesGD", "setRayPickable", !state)

#region Base Functions
func onLoad(_save_file: SaveFileGD, Card: CardGD) -> void:
	save_file = _save_file
	area = save_file.area
	
	area.map_node_selected.connect(onMapNodeSelected)
	area.map_nodes_loaded.connect(onMapStartAnimation)
	area.map_node_entered.connect(onMapNodeEntered)
	area.map_node_finished.connect(onMapNodeFinished)
	
	MapCard = Card
	MapCard.onCreateModel()
	MapCard.onIdle()
	MapCard.rotation_degrees.y = 90
	
	setEnvironment()
#endregion

#region Setters
func setEnvironment() -> void:
	WorldEnv.environment = area.info.base_environment\
	if !area.map_location.isAfterMiniboss() else area.info.late_environment
#endregion

#region Map Node Selected
var is_unit_walking_to_map_node: bool = false
func onMapNodeSelected(map_node: MapNodeGD, WALK_OVERWORLD_SPEED: float, is_initial_load_select: bool) -> void:
	var spotlight_destination := map_node.position
	spotlight_destination.y += UNIT_SPOTLIGHT_UP_OFFSET
	if is_initial_load_select:
		if Helper.admin: Camera.position = getMapNodeDestination(map_node) + CAMERA_OFFSET
		UnitSpotlight.position = spotlight_destination
		MapCard.position = map_node.position
		return
		
	is_unit_walking_to_map_node = true
	onUpdateActionLock()
	MapCard.onWalkTo(map_node.position, WALK_OVERWORLD_SPEED)
	MapCard.onLookAtObjectOnlyY(map_node)
	
	var tween := get_tree().create_tween()
	tween.tween_property(UnitSpotlight, "position", spotlight_destination, WALK_OVERWORLD_SPEED)
	
	var camera_tween := get_tree().create_tween()
	camera_tween.tween_property(Camera, "position:x", map_node.position.x, WALK_OVERWORLD_SPEED)
	
	await tween.finished
	
	is_unit_walking_to_map_node = false
	onUpdateActionLock()
	
var is_unit_in_map_node_screen: bool = false
func onMapNodeEntered(map_node: MapNodeGD) -> void:
	if map_node.info.screen != null:
		is_unit_in_map_node_screen = true
		onUpdateActionLock()
	else: area.onMapNodeFinished()
		
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	is_unit_in_map_node_screen = false
	onUpdateActionLock()
#endregion

#region Map Start
@export var MAP_START_DELAY_TIME: float = 1
@export var MAP_START_TRAVEL_TIME: float = 7
var is_map_starting: bool
func onMapStartAnimation() -> void:
	if !Helper.admin:
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
