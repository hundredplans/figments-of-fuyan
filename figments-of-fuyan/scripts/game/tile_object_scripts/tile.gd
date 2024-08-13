class_name TileGD
extends TileObjectGD

#region Base Functions
func _ready() -> void:
	add_to_group("Tiles")
	add_to_group("TileObjects")
	
func _enter_tree():
	setMapPosition()
#endregion

#region Getters
func getHeight() -> int: return data.coords.w
func getCoordsHeightless() -> Vector3i: return Vector3i(data.coords.x, data.coords.y, data.coords.z)
func getCoords() -> Vector4i: return data.coords
#endregion

#region Setters
func setCoords(coords: Vector4i) -> void:
	data.coords = coords
	setMapPosition()

func setPosition(coords: Vector4i, __: Vector3) -> void:
	setCoords(coords)

func setMapPosition() -> void:
	position = Vector3((sqrt(3) * data.coords.x + sqrt(3) * data.coords.y * 0.5), data.coords.w * 0.6, data.coords.y * 3 / 2.0)

#endregion

#region Material Updates
func setMeshesMaterial(mat: Material = null) -> void:
	for mesh in getMeshes():
		mesh.set_surface_override_material(0, mat)
#endregion

#region Collision Layers
func setDefaultCollisionLayers() -> void:
	for body in getStaticBodies():
		body.collision_layer = 24
#endregion

#region Tile Fill
var TileFill: Node3D
func onCreateTileFill(state: bool) -> String:
	if getHeight() == 0: return "NULL"
	
	data.tile_fill = state
	if TileFill != null: TileFill.queue_free()
	if data.tile_fill:
		TileFill = info.tile_fill.instantiate()
		add_child(TileFill)
		TileFill.global_position.y = 0
		TileFill.scale.y = getHeight()
		return "DESTROY"
	return "CREATE"
#endregion
