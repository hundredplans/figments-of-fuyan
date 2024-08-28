class_name GameObjectGD
extends Node3D

#region Saved Data
var info: GameObjectInfoGD
var variation: int
var coords: Vector4i
var tile_rotation: int
#endregion

#region Points
const POINT_PATH: String = "res://scenes/editors/game_object_editor/point.tscn"
func onLoadPoints(parent: Node3D) -> void:
	for i in range(info.models.size()):
		if i >= info.points.size(): info.points.append([])
			
	for point in info.points[variation]:
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
	info.points[variation].append(point)
	ResourceSaver.save(info)
	
func onRemovePoint(point: Vector3) -> void:
	info.points[variation].erase(point)
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
	
func isIDVariation(id: int, _variation: int) -> bool: return info.id == id and _variation == variation
#endregion

#region Getters
func getLockRotation() -> bool: return false
#endregion

#region Setters
func setOwner(new_owner: Node3D) -> void:
	owner = new_owner
	for child in get_children(): child.owner = new_owner

func setRayPickable(state: bool) -> void:
	for body in getStaticBodies():
		body.input_ray_pickable = state

func setVisible(state: bool) -> void: visible = state

func onRotateDirection(direction: int) -> void:
	tile_rotation += direction
	if tile_rotation > 6: tile_rotation = 1
	elif tile_rotation < 0: tile_rotation = 6
	setTileRotation(tile_rotation)

func setTileRotation(_tile_rotation: int) -> void:
	tile_rotation = _tile_rotation
	rotation.y = tile_rotation * (PI / 3)
	
func setCoords(_coords: Vector4i) -> void:
	coords = _coords
	setMapPosition()
	
func setMapPosition() -> void:
	position = Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), coords.w * 0.6, coords.y * 3 / 2.0)
#endregion

#region Save/Load/Clear
func onClear() -> void: queue_free()
func onSave() -> SavedDataGameObject:
	return SavedDataGameObject.new(info.id, variation, coords, tile_rotation)
	
func onLoad(data: SavedData, parent: Node3D) -> void:
	info = data.getBaseInfo()
	variation = data.variation
	
	if parent != null:
		var model: Node3D = info.getModel(variation).instantiate()
		parent.add_child(self)
		add_child(model)
	
		setCoords(data.coords)
		setTileRotation(data.tile_rotation)
	
		call("setDefaultCollisionLayers")
		setRayPickable(false)
	add_to_group("Loadables")
#endregion

#region Material Updates

var half_transparent_base_material: ShaderMaterial = preload("res://resources/materials/game/base_material_half_transparent.tres")
func setHalfTransparent() -> void:
	setMeshesMaterial(half_transparent_base_material)

func setRegularMaterial() -> void:
	setMeshesMaterial()
	
func setMeshesMaterial(mat: Material = null) -> void:
	for mesh in getMeshes():
		for surface in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface, mat)
			
func setEmptyCollisionLayers() -> void:
	for body in getStaticBodies():
		body.collision_layer = 0
#endregion

#region Variations
func clampVariation(i: int) -> void:
	variation += i
	if variation >= info.models.size(): variation = 0
	elif variation < 0: variation = info.models.size() - 1
#endregion
