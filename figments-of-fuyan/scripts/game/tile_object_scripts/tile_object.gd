class_name TileObjectGD
extends Node3D

# Lower = faster
const SLOW_ROTATE_SPEED: int = 50
const FAST_ROTATE_SPEED: int = 15

var info: TileObjectInfo
var data: TileObjectData

func setInfo(_info: TileObjectInfo, _data: TileObjectData) -> void:
	info = _info
	data = _data
	setDefaultCollisionLayers()
	rotation.y = data.rotation
	setRayPickable(false)

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
			
#endregion
#region Collision Layers
func setDefaultCollisionLayers() -> void:
	for body in getStaticBodies():
		body.collision_layer = 16
		
func setEmptyCollisionLayers() -> void:
	for body in getStaticBodies():
		body.collision_layer = 0
		
func setRayPickable(state: bool) -> void:
	for body in getStaticBodies():
		body.input_ray_pickable = state
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
	
func setVisible(state: bool) -> void: visible = state
#endregion
#region Rotation
func onLockRotateDirection(direction: int) -> void:
	setClampRotation(direction * (PI / 3))
	
func setClampRotation(val: float) -> void:
	rotation.y += val
	if rotation.y > 2 * PI: rotation.y -= 2 * PI
	elif rotation.y < 0: rotation.y += 2 * PI
	data.rotation = rotation.y
	
func onRotateDirection(direction: int, is_slow_speed: bool = true) -> void:
	var divisor: int = SLOW_ROTATE_SPEED if is_slow_speed else FAST_ROTATE_SPEED
	setClampRotation(direction * (PI / divisor))
	
func setRotation(rot: float) -> void: rotation.y = rot; data.rotation = rot
#endregion
#region Variations
func clampVariation(i: int) -> void:
	var variation: int = data.variation
	variation += i
	if variation >= info.models.size(): variation = 0
	elif variation < 0: variation = info.models.size() - 1
	data.variation = variation
#endregion
