extends Node

var item_properties: Array = []
var TILE_OBJECT_NAME_TO_FULL_NAME: Dictionary = {
	"tile": "tiles",
	"wdeco": "decorations/walls",
	"tdeco": "decorations/tiles",
	"obj": "objects",
	"wall": "walls",
}
var TILE_OBJECT_NAMES: Array = ["tile", "wall", "obj", "tdeco", "wdeco"]
var _LevelTile: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/tiles/level_tile.tscn")
var light_tester_gd: Script = preload("res://assets/base_game/levels/level/loaded_level_light_tester.gd")
var cube_directions: Array[Vector3] = [
Vector3(1, 0, -1),
Vector3(1, -1, 0),
Vector3(0, -1, 1),
Vector3(-1, 0, 1),
Vector3(-1, 1, 0),
Vector3(0, 1, -1)
]

@export var _level_info: LevelInfoGD
func _ready() -> void:
	onLoadItemProperties()
	if _level_info != null: onBakeLevel(_level_info)

func onBakeLevel(level_info: LevelInfoGD) -> void:
	print("Beginning baking")
	var packed_scene := PackedScene.new()
	var load_level_path: String = "res://assets/base_game/levels/level/loaded_level.tscn"
	var alt_path: String = "res://assets/base_game/levels/levels/" + level_info.folder_name + "/loaded_level.tscn"
	if FileAccess.file_exists(alt_path): load_level_path = alt_path
		
	var LoadedLevel: Node3D = load(load_level_path).instantiate()
	for child in LoadedLevel.get_node("Tiles").get_children(): child.free()
	add_child(LoadedLevel)
	print("Old tiles removed")
	var tiles: Array = []
	for tile_info in level_info.tiles:
		tiles.append(onCreateTile(tile_info, LoadedLevel))
	print("New tiles created")
	await get_tree().process_frame
	tiles = tiles.filter(func(x: TileGD): return x != null)
	var id: int = 1
	for Tile in tiles: 
		onSortTileCollisions(Tile, tiles, level_info.area.id)
		onCreateUnitHeight(Tile, tiles)
		Tile.id = id
		id += 1
	
	print("Collision points and unit height assigned")
	for Tile in tiles:
		setTileSolidStatus(Tile, tiles)
	
	print("Solid status to tiles assigned")
	for Tile in tiles:
		onCreateFneighbours(Tile, tiles)
	print("Neighbour relationships created for tiles")
	
	await get_tree().process_frame # absolutely necessary
	LoadedLevel.script = light_tester_gd
	packed_scene.pack(LoadedLevel)
	ResourceSaver.save(packed_scene, alt_path)
	LoadedLevel.queue_free()
	print("Finished")

func onCreateTile(tile_info: Dictionary, owner_node: Node3D) -> TileGD:
	if TILE_OBJECT_NAMES.any(func(x: String): return tile_info[x].id > 0):
		var LevelTile: Node3D = _LevelTile.instantiate()
	
		LevelTile.name = str(randi())
		owner_node.get_node("Tiles").add_child(LevelTile)
		owner_node.set_editable_instance(LevelTile, true)
		LevelTile.owner = owner_node
		
		var temp_vec: Vector4 = Vector4(tile_info.position[0], tile_info.position[1], tile_info.position[2], tile_info.position[3])
		LevelTile.position = Vector3(
		(sqrt(3) * temp_vec.x + sqrt(3) * temp_vec.y * 0.5),
		temp_vec.w * 1.2,
		temp_vec.y * 3 / 2)
		
		for child in LevelTile.ModelManager.get_children(): child.queue_free()
		for obj_name in TILE_OBJECT_NAMES:
			LevelTile[obj_name] = tile_info[obj_name]
			LevelTile.w = tile_info.position[3]
			LevelTile.tpos = Vector3(tile_info.position[0], tile_info.position[1], tile_info.position[2])
		return LevelTile
	return null
	
func getFirstFneighbours(Tile: TileGD, tiles: Array) -> Array:
	for i in range(cube_directions.size()):
		var direction: Vector3 = cube_directions[i]
		var neighbour_tiles: Array = tiles.filter(func(x: TileGD): return x.tpos == direction + Tile.tpos and x.tile.id != 0 and x.solid_status == 0)
		neighbour_tiles.sort_custom(func(x: TileGD, y: TileGD): return x.w > y.w)
		var is_non_regular_tile: bool = Tile.tile.type in [1, 2]
		var tile_below_accessable: bool = false
		for _Tile in neighbour_tiles:
			Tile.fneighbours.append({"Tile": _Tile})
			if _Tile.w <= Tile.w: break
	return []
	
func onCreateFneighbours(Tile: TileGD, tiles: Array) -> void:
	getFirstFneighbours(Tile, tiles)
	var real_fneighbours: Array = []
	for fn in Tile.fneighbours:
		fn.hdiff = 0
		fn.unit_height = 0
		fn.movement_type = FneighbourGD.UNPASSABLE
		var _Tile: TileGD = fn.Tile
		fn.id = fn.Tile.id
		if _Tile.w == Tile.w: # Regular movement
			if !isRamp(Tile, _Tile, fn):
				if !isJump(Tile, _Tile, fn):
					if !isFall(Tile, _Tile, fn):
						isRegular(Tile, _Tile, fn)
		elif _Tile.w > Tile.w: # Half jump up / ramp ascension
			if !isRamp(Tile, _Tile, fn):
				if !isHigh(Tile, _Tile, fn):
					isJump(Tile, _Tile, fn)
		else: # Jump down
			if !isRamp(Tile, _Tile, fn):
				isFall(Tile, _Tile, fn)
				
		if fn.unit_height >= 0:
			real_fneighbours.append(FneighbourGD.new(fn.id, fn.movement_type, fn.unit_height, fn.hdiff, _Tile.solid_status == 1))
	Tile.fneighbours = real_fneighbours
	
func isHigh(Tile: TileGD, _Tile: TileGD, fn: Dictionary) -> bool:
	var hdiff: int = onCalculateHdiff(Tile, _Tile)
	if hdiff > 1:
		fn.hdiff = hdiff
		fn.movement_type = FneighbourGD.HIGH
		return true
	return false
	
func isFall(Tile: TileGD, _Tile: TileGD, fn: Dictionary) -> bool: # Non ramp fall
	if _Tile.w < Tile.w or (Tile.tile.type == 1 and _Tile.tile.type == 0):
		fn.unit_height = min(Tile.unit_height, _Tile.unit_height)
		fn.hdiff = onCalculateHdiff(Tile, _Tile)
		fn.movement_type = FneighbourGD.FALL
		return true
	return false
	
func onCalculateHdiff(Tile: TileGD, _Tile: TileGD) -> int:
	var h_one: int = abs(Tile.w * 2)
	if (Tile.tile.type in [1, 2]): h_one += 1
	var h_two: int = abs(_Tile.w * 2)
	if (_Tile.tile.type in [1, 2]): h_two += 1
	return abs(h_one - h_two)
	
func isRegular(Tile: TileGD, _Tile: TileGD, fn: Dictionary) -> void:
	fn.unit_height = min(Tile.unit_height, _Tile.unit_height)
	fn.movement_type = FneighbourGD.REGULAR
	
func isJump(Tile: TileGD, _Tile: TileGD, fn: Dictionary) -> bool:
	if (_Tile.tile.type == 1 and Tile.tile.type == 0 and abs(Tile.w - _Tile.w) == 0) or (Tile.tile.type == 1 and _Tile.tile.type == 0 and abs(Tile.w - _Tile.w) == 1):
		fn.unit_height = min(Tile.unit_height, _Tile.unit_height)
		fn.movement_type = FneighbourGD.JUMP
		return true
	return false
	
func isRampCalculate(RampTile: TileGD, Tile: TileGD, fn: Dictionary) -> bool:
	var ramp_rot: int = RampTile.tile.rotation
	var neirot: int = onNeighbourRotation(RampTile, Tile)
	
	if (neirot == (ramp_rot + 1) % 6 and RampTile.w + 1 == Tile.w) \
	or (neirot == (ramp_rot + 4) % 6 and RampTile.w == Tile.w):
		fn.movement_type = FneighbourGD.RAMP
	else: fn.movement_type = FneighbourGD.UNPASSABLE
	fn.unit_height = min(RampTile.unit_height, Tile.unit_height)
	return true
	
func isRamp(Tile: TileGD, _Tile: TileGD, fn: Dictionary) -> bool:
	var is_ramp: bool = Tile.tile.type == 2
	var _is_ramp: bool = _Tile.tile.type == 2
	if (is_ramp and !_is_ramp): return isRampCalculate(Tile, _Tile, fn)
	elif (!is_ramp and _is_ramp): return isRampCalculate(_Tile, Tile, fn)
	return false
		
func onNeighbourRotation(Tile: TileGD, _Tile: TileGD) -> int:
	var direction: Variant = _Tile.onTTpos() - Tile.onTTpos()
	direction = Vector3(direction.x, direction.y, direction.z)
	for i in range(cube_directions.size()):
		if cube_directions[i] == direction:
			return i
	return -1
	
func setTileSolidStatus(Tile: TileGD, tiles: Array) -> void:
	var positions: Array = tiles.map(func(x: TileGD): return x.onTTpos())
	var btab: int = 0
	for tile_object in Helper.BTAB_TO_TYPE[-1]:
		if tile_object != "tile":
			if Tile[tile_object].id > 0:
				for info in item_properties:
					if info.id[0] == btab and info.id[1] == Tile[tile_object].id:
						var abs_positions: Array = positions.map(func(x: Vector4): return Vector3(Tile.tpos.x - x.x,\
						Tile.tpos.y - x.y, Tile.w - x.w))
						for key in info:
							if key.contains("|"):
								var pos: Vector3 = Vector3(int(key.get_slice("|", 0)), int(key.get_slice("|", 1)), int(key.get_slice("|", 2)))
								for i in range(abs_positions.size()):
									if abs_positions[i] == pos:
										if tiles[i].solid_status < 1 and info[key].solidity > 0:
											tiles[i].solid_status = 1
		btab += 1
	
func onLoadItemProperties() -> void:
	var data: String = Helper.return_file_contents("res://static/game_info/item_properties.txt")
	for line in data.split("\n", false):
		item_properties.append(str_to_var(line))
		
func onSortTileCollisions(Tile: TileGD, tiles: Array, area: int) -> void:
	for obj_name in TILE_OBJECT_NAMES:
		var scene_path: String = "null"
		match obj_name:
			"tile": scene_path = Helper.tid_to(Tile[obj_name].id, area, Tile[obj_name].type)
			"wall": scene_path = Helper.wid_to(Tile[obj_name].id, area, Tile[obj_name].type)
			_: scene_path = Helper.editor_id_to(Helper.TYPE_TO_BTAB[obj_name], Tile[obj_name].id, Tile[obj_name].type)
	
		if scene_path != "null":
			match obj_name:
				"wall":
					var packed_wall: PackedScene = load("res://assets/models/walls/" + scene_path + ".tscn")
					for n in range(4 - Tile['wall'].tile_wall):
						var scene: Node3D = packed_wall.instantiate()
						Tile.ModelManager.add_child(scene)
						scene.rotation_degrees.y = Tile['wall'].rotation * 60
						scene.position.y = (n * 0.3) + 0.3
						if n == 1: onCreateCollisionPoints(Tile, tiles, scene.global_position, Tile['wall'].rotation * 60, scene.collision_points, 'wall')
				_: 
					if !(obj_name == "obj" and Tile['obj'].id in range(1, 5)):
						var scene: Node3D = load("res://assets/models/" + TILE_OBJECT_NAME_TO_FULL_NAME[obj_name] + "/" + scene_path + ".tscn").instantiate()
						Tile.ModelManager.add_child(scene)
						scene.position.y = 0.0 if obj_name == "tile" else 0.3
						scene.rotation_degrees.y = Tile[obj_name].rotation * 60
						onCreateCollisionPoints(Tile, tiles, scene.global_position, Tile[obj_name].rotation * 60,  scene.collision_points, obj_name)
		
	for grandchild in Tile.ModelManager.get_children():
		grandchild.owner = Tile.owner

func onCreateCollisionPoints(Tile: TileGD, tiles: Array, pos: Vector3, p_rot: int, points: Array, type: String) -> void:
	if points.size() > 0:
		match type:
			"tile":
				var match_type: int = Tile['tile'].type
				if match_type != 2 and getAdjacentTiles(Tile, tiles).all(func(x: TileGD): return x['tile'].type == match_type):
					for i in range(6 + int(Tile.w == 0)): points.remove_at(7)
			"wall":
				if Tile['wall'].type == 2:
					var _tiles: Array = getAdjacentTiles(Tile, tiles)
					if _tiles.size() == 6 and _tiles.all(func(x: TileGD): return x['wall'].type == 2):
						points = []
			
		for point in points:
			Tile.collision_points.append(getRotationPoint(point, p_rot) + pos)

func getAdjacentTiles(Tile: TileGD, tiles: Array) -> Array:
	var keep_tiles: Array = []
	for _Tile in tiles:
		if Tile.w == _Tile.w:
			var pos: Vector3 = Tile.tpos - _Tile.tpos
			if ((abs(pos.x) + abs(pos.y) + abs(pos.z)) / 2) == 1: keep_tiles.append(_Tile)
	return keep_tiles

func getRotationPoint(xyz: Vector3, rot: int) -> Vector3:
	var r: float = deg_to_rad(rot)
	return Vector3(xyz.x * (cos(r)) - xyz.z * (sin(r)), xyz.y, xyz.z * (cos(r)) + xyz.x * (sin(r)))

func onCreateUnitHeight(Tile: TileGD, tiles: Array) -> void:
	Tile.unit_height = 0.6 if Tile.tile.type == 0 else 0.0
	for w in range(Tile.w + 1, Tile.w + 6):
		for _Tile in tiles:
			if _Tile.w == w and _Tile.tpos == Tile.tpos and (Tile.tile.id != 0 or Tile.solid_status == 1):
				return
		Tile.unit_height += 1.2
	Tile.unit_height = 50
