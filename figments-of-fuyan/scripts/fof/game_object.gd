class_name GameObjectGD extends FofGD

#region Saved Data
var Model: Node3D
var coords: Vector4i
var tile_rotation: int
var level_visible: bool
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
#endregion

#region Getters
func getLockRotation() -> bool: return false

func getRayPickable() -> bool:
	for body in getStaticBodies(): return body.input_ray_pickable
	return false
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
func onLoadData(data: SavedData) -> void:
	setLevelVisible(data.level_visible)
	add_to_group("GameObjectsGD")
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

#region Level Visible
func setLevelVisible(state: bool) -> void:
	level_visible = state
#endregion
