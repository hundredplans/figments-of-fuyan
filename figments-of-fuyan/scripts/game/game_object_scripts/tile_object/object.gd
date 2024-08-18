class_name ObjectGD
extends TileObjectGD

#region Base Functions
func _ready():
	add_to_group("Objects")

func _enter_tree():
	if data != null: setMapPosition(data.position)
#endregion

#region Positions
func onCoordsToPosition(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)

func setMapPosition(_position: Vector3) -> void:
	position = _position

func setPosition(coords := Vector4i.ZERO, point := Vector3.ZERO, force_tile_lock: bool = false) -> void:
	if info.lock_tile or force_tile_lock: setMapPosition(onCoordsToPosition(coords))
	else: position = point
	data.position = position
	data.height = coords.w

func getHeight() -> int:
	return data.height
#endregion

#region Tile Coords
func onLoadTilesCoords(parent: Node3D, tile_info: TileInfoGD) -> void:
	for i in range(info.models.size()):
		if i >= info.tile_coords.size(): info.tile_coords.append([])
	
	for coords in info.tile_coords[data.variation]:
		var tile_data: TileDataGD = tile_info.createData()
		var Tile: TileGD = tile_data.onLoad(parent, tile_info)
		Tile.setPosition(coords)
		Tile.setRayPickable(false)
		Tile.setHalfTransparent()
	ResourceSaver.save(info)
	
func onSaveTile(coords: Vector4i) -> void:
	info.tile_coords[data.variation].append(coords)
	ResourceSaver.save(info)
	
func onDeleteTile(coords: Vector4i) -> void:
	info.tile_coords[data.variation].erase(coords)
	ResourceSaver.save(info)
#endregion
