class_name TileObjectGD
extends GameObjectGD

# Lower = faster
const SLOW_ROTATE_SPEED: int = 50
const FAST_ROTATE_SPEED: int = 15

#region Base Functions
func _ready() -> void:
	add_to_group("Loadables")
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
		
#endregion
#region Rotation
func onRotateDirection(direction: int, is_slow_speed: bool = true) -> void:
	var divisor: int = SLOW_ROTATE_SPEED if is_slow_speed else FAST_ROTATE_SPEED
	setClampRotation(direction * (PI / divisor))
#endregion
#region Variations
func clampVariation(i: int) -> void:
	var variation: int = data.variation
	variation += i
	if variation >= info.models.size(): variation = 0
	elif variation < 0: variation = info.models.size() - 1
	data.variation = variation
#endregion
