extends Node3D

#region Exports
@export var CAMERA_OFFSET: Vector3
#endregion

#region Globals
signal action_lock

var MapCard: CardGD
var save_file: SaveFileGD
var area: AreaGD
var UI: Control
@onready var WorldEnv: WorldEnvironment = %WorldEnvironment
@onready var Camera: Camera3D = %MovementCamera
#endregion

#region Base Functions
func onLoad(_save_file: SaveFileGD, Card: CardGD) -> void:
	save_file = _save_file
	area = save_file.area
	area.map_node_selected.connect(onMapNodeSelected)
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

func onMapNodeSelected(map_node: MapNodeGD, show_move: bool = true) -> void:
	var destination :=  Vector3(map_node.position.x, 0.3, map_node.position.z)
	if !show_move: MapCard.position = destination; Camera.position = destination + CAMERA_OFFSET
	action_lock.emit(true)
