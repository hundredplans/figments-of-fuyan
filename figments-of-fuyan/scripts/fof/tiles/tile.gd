class_name TileGD
extends TileObjectGD

#region Global
var occupied_objects: Array = []
#endregion

#region Saved Data
var tile_fill: bool = false
#endregion
#region Getters
func getHeight() -> int: return coords.w
func getCoordsHeightless() -> Vector3i: return Vector3i(coords.x, coords.y, coords.z)
func getCoords() -> Vector4i: return coords
func getLockRotation() -> bool: return true
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
	
	tile_fill = state
	if TileFill != null: TileFill.queue_free()
	if tile_fill:
		TileFill = info.tile_fill.instantiate()
		add_child(TileFill)
		TileFill.global_position.y = 0
		TileFill.scale.y = getHeight()
		return "DESTROY"
	return "CREATE"
#endregion
#region Save / Load
func onSave() -> SavedDataGameObject:
	return SavedDataTile.new(info.id, false, coords, tile_rotation, level_visible, variation, tile_fill)

func onLoadData(data: SavedData) -> void:
	super(data)
	onLoadModel()
	onCreateTileFill(data.tile_fill)
	add_to_group("TilesGD")
	
func onLoadModel() -> void:
	super()
	setCoords(coords)
	setTileRotation(tile_rotation)
	
func onLevelFofInit() -> void:
	setLevelVisible(SpawnGD in occupied_objects.map(func(x: ObjectGD): return x.get_script()))

func setLevelVisible(state: bool) -> void:
	super(state)
	for object in occupied_objects: object.setLevelVisible(state)

#endregion

#region Occupied Objects
func setOccupiedObject(object: ObjectGD) -> void:
	occupied_objects.append(object)
#endregion
