class_name ObjectGD extends TileObjectGD

#region Globals
var ROTATION_SPEED: float = 0.02
#endregion
#region Saved Data
var map_rotation: float
var map_position: Vector3
var height: int
var occupied_coords: Array
var occupied_tiles: Array
var groups: Array
#endregion

var GroupLabel: Label3D # Set by level editor
var loaded_in_level: bool
var loaded_in_editor: bool

#region Getters
func getLockRotation() -> bool:
	return info.lock_rotation
#endregion

#region is Checks
func isSolid() -> bool:
	return info.solids[variation]
	
func isAdjacent(_coords: Vector4i, distance: int = 1) -> bool:
	return	 occupied_tiles.any(func(x: TileGD): return x.isAdjacent(_coords, distance))
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
	var offset: float = occupied_tiles[0].getCardYOffsetBase() if !occupied_tiles.is_empty() else 0.3
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + offset, coords.y * 3 / 2.0)

func setPosition(_coords := Vector4i.ZERO, point := Vector3.ZERO, force_tile_lock: bool = false) -> void:
	coords = _coords
	height = coords.w
	
	if info.lock_tile or force_tile_lock: position = onCoordsToPosition()
	else: position = point
	map_position = position
#endregion

#region Tile Coords
func getCoords() -> Array:
	return occupied_tiles.map(func(x: TileGD): return x.getCoords())

func getTilesCoords() -> Array:
	return info.tile_coords[variation]

func onLoadTilesCoords(parent: Node3D, tile_info: TileInfo) -> void:
	for i in range(info.models.size()):
		if i >= info.tile_coords.size(): info.tile_coords.append([Vector4.ZERO])
	
	for tile_coords in info.tile_coords[variation]:
		SavedData.onLoadModel(SavedDataTile.new(tile_info.id, false, 0, tile_coords), parent)
		#Tile.setHalfTransparent()
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
	return SavedDataObject.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, variation, map_rotation, map_position, height,\
	occupied_tiles.map(func(x: TileGD): return x.getCoords()), groups)

func onLoadData(data: SavedData) -> void:
	super(data)
	position = data.position
	groups = data.groups
	
	if !info.lock_rotation: rotation.y = data.rotation
	else: setTileRotation(data.tile_rotation)
	
	map_position = position
	map_rotation = rotation.y
	height = data.height
	occupied_coords = data.occupied_coords
	
	onLoadModel()
	add_to_group("ObjectsGD")
	
func onLoadDataLevel() -> void:
	loaded_in_level = true
	occupied_tiles = occupied_coords.map(func(x: Vector4i): return Game.getTile(x))
	for Tile in occupied_tiles:
		Tile.setOccupiedObject(self)
	super()
	
func onLoadDataLevelFofInit() -> void:
	super()
	vision_datastore = VisionDatastore.new()
	
func onCreateGroupLabel() -> void:
	GroupLabel = load(info.SPAWN_GROUP_LABEL_SCENE_PATH).instantiate()
	Model.add_child(GroupLabel)
	GroupLabel.setInfo(groups)
	
func onFofInit() -> void:
	pass
#endregion

#region Collision Layers
func setDefaultCollisionLayers() -> void:
	setCollisionLayers(20)
	
func setCollisionLayers(layer: int) -> void:
	if loaded_in_level and info.ignore_collisions: super(0)
	else: super(layer)
#endregion

#region Occupied Tiles
func setOccupiedTiles(tile_position_to_tile: Dictionary) -> void:
	var closest_tile: TileGD
	var closest_distance: float = 1000
	for pos in tile_position_to_tile:
		var distance: float = pos.distance_to(position)
		if distance < closest_distance:
			closest_tile = tile_position_to_tile[pos]
			closest_distance = distance
	
	var tile_rotation_force: int = getTileRotationForce()
	var coords_array: Array = getTilesCoords().map(func(x: Vector4i): return Game.onRotateCoordsCC(tile_rotation_force, x))\
		.map(func(x: Vector4i): return x + closest_tile.getCoords())
	
	occupied_tiles = coords_array.map(func(x: Vector4i): return Game.getTile(x)).filter(func(x: TileGD): return x != null)
	
	for Tile in occupied_tiles:
		Tile.setOccupiedObject(self)
		
func getTile() -> TileGD:
	return occupied_tiles[0]
#endregion

#region Vision
func getRevealVisibleGroup() -> Array:
	return [self] + occupied_tiles
#endregion

#region Actions
func onProcessAction(action: Action) -> void:
	super(action)
#endregion

func getMaxMovementHeight() -> float: # Returns whether card can go below it or not
	return 0

func onCreateAdjustedPoints():
	if !info.ignore_collisions: super()
	else: adjusted_points = []
	
func onOccupy(_state: bool) -> void:
	pass

#region Variations
func clampVariation(i: int) -> void:
	if variation >= 0:
		variation += i
		if variation >= info.models.size(): variation = 0
		elif variation < 0: variation = info.models.size() - 1
#endregion

var half_transparent_base_material: ShaderMaterial = preload("res://resources/materials/game/base_material_half_transparent.tres")
func setHalfTransparent() -> void:
	setMeshesMaterial(half_transparent_base_material)

func onApplyGreyscaleMaterial() -> void:
	var greyscale_material: ShaderMaterial = load(info.GREYSCALE_MATERIAL) if !isLevelVisible() and !Helper.admin_datastore.see else null
	for mesh in getMeshes():
		for surface_id in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface_id, greyscale_material)

func onChangeSpawnGroup(group_index: int) -> void:
	if !groups.has(group_index): groups.append(group_index)
	else: groups.erase(group_index)
	
	GroupLabel.setGroups(groups)
	
