class_name GameObjectGD
extends Node3D

var info: TileObjectInfoGD
var data: TileObjectDataGD

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
