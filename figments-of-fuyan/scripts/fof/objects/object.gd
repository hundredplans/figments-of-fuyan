class_name ObjectGD extends TileObjectGD

#region Globals
var ROTATION_SPEED: float = 0.02
#endregion
#region Saved Data
var map_rotation: float
var map_position: Vector3
var height: int
#endregion

#region Getters
func getLockRotation() -> bool:
	return info.lock_rotation
#endregion

#region Rotation
func onRotateDirection(direction: int) -> void:
	if !getLockRotation():
		var val: float = direction * PI * ROTATION_SPEED
		rotation.y += val
		if rotation.y > 2 * PI: rotation.y -= 2 * PI
		elif rotation.y < 0: rotation.y += 2 * PI
	else: super(direction)
	map_rotation = rotation.y
#endregion

#region Positions
func onCoordsToPosition() -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)

func setPosition(_coords := Vector4i.ZERO, point := Vector3.ZERO, force_tile_lock: bool = false) -> void:
	coords = _coords
	height = coords.w
	
	if info.lock_tile or force_tile_lock: position = onCoordsToPosition()
	else: position = point
	map_position = position
#endregion

#region Tile Coords
func onLoadTilesCoords(parent: Node3D, tile_info: TileInfo) -> void:
	for i in range(info.models.size()):
		if i >= info.tile_coords.size(): info.tile_coords.append([Vector4.ZERO])
	
	for tile_coords in info.tile_coords[variation]:
		var Tile := TileGD.new()
		Tile.onLoad(SavedDataTile.new(tile_info.id, tile_coords), parent)
		Tile.setHalfTransparent()
	ResourceSaver.save(info)
	
func onSaveTile(tile_coords: Vector4i) -> void:
	info.tile_coords[variation].append(tile_coords)
	ResourceSaver.save(info)
	
func onDeleteTile(tile_coords: Vector4i) -> void:
	info.tile_coords[variation].erase(tile_coords)
	ResourceSaver.save(info)
#endregion

#region Save/Load
func onSave() -> SavedDataGameObject:
	return SavedDataObject.new(info.id, coords, tile_rotation, variation, map_rotation, map_position, height)

func onLoadData(data: SavedData) -> void:
	super(data)
	position = data.position
	rotation.y = data.rotation
	
	map_position = position
	map_rotation = rotation.y
	height = data.height
	
	onLoadModel()
	add_to_group("ObjectsGD")
#endregion

#region Collision Layers
func setDefaultCollisionLayers() -> void:
	for body in getStaticBodies():
		body.collision_layer = 16
#endregion
