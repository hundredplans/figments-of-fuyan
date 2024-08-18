class_name GameObjectGD
extends Node3D

var info: GameObjectInfoGD
var data: GameObjectDataGD

func setInfo(_info: GameObjectInfoGD, _data: GameObjectDataGD) -> void:
	info = _info
	data = _data
	setDefaultCollisionLayers()
	rotation.y = data.rotation
	setRayPickable(false)

#region Base Functions
func _ready() -> void:
	add_to_group("Loadables")
#region Points
const POINT_PATH: String = "res://scenes/editors/game_object_editor/point.tscn"
func onLoadPoints(parent: Node3D) -> void:
	for i in range(info.models.size()):
		if i >= info.points.size(): info.points.append([])
			
	for point in info.points[data.variation]:
		var Point: MeshInstance3D = load(POINT_PATH).instantiate()
		Point.setInfo(self)
		Point.position = point
		parent.add_child(Point)
	ResourceSaver.save(info)
	
func onCreatePoint(parent: Node3D, point: Vector3) -> void:
	var Point: MeshInstance3D = load(POINT_PATH).instantiate()
	Point.setInfo(self)
	Point.position = point
	parent.add_child(Point)
	info.points[data.variation].append(point)
	ResourceSaver.save(info)
	
func onRemovePoint(point: Vector3) -> void:
	info.points[data.variation].erase(point)
	ResourceSaver.save(info)
#endregion

#region Helper Functions
func getMeshes() -> Array[MeshInstance3D]:
	var arr: Array[MeshInstance3D] = []
	arr.assign(Helper.getChildrenRecursive(self).filter(func(x: Node): return x is MeshInstance3D))
	return arr

func getStaticBodies() -> Array[StaticBody3D]:
	var arr: Array[StaticBody3D] = []
	arr.assign(Helper.getChildrenRecursive(self).filter(func(x: Node): return x is StaticBody3D))
	return arr
	
func isIDVariation(id: int, variation: int) -> bool: return info.id == id and data.variation == variation
#endregion

#region Setters
func setRayPickable(state: bool) -> void:
	for body in getStaticBodies():
		body.input_ray_pickable = state

func setVisible(state: bool) -> void: visible = state
#endregion
#region Empty Functions
func setDefaultCollisionLayers() -> void: pass
#endregion
#region Rotation
func onLockRotateDirection(direction: int) -> void:
	setClampRotation(direction * (PI / 3))
	
func setClampRotation(val: float) -> void:
	rotation.y += val
	if rotation.y > 2 * PI: rotation.y -= 2 * PI
	elif rotation.y < 0: rotation.y += 2 * PI
	data.rotation = rotation.y
	
func setRotation(rot: float) -> void: rotation.y = rot; data.rotation = rot
#endregion

#region Save/Load/Clear
func onClear() -> void: queue_free()
func onSave(arr: Array[GameObjectDataGD]) -> void: arr.append(data)
#endregion
