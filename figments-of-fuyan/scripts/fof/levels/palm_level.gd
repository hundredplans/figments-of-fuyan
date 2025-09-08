class_name PalmLevelGD extends LevelGD

#region Globals
var ISLAND_ODDS: Dictionary[int, float] = {
	6: 0.5,
	7: 0.4,
	8: 0.1
}
	
const DISTANCE_BOUND: int = 35
const LOWER_GEN_BOUND: int = 50
const UPPER_GEN_BOUND: int = 100
#endregion

#region Save / Load / Init
func onLoadActiveLevel(data: SavedDataLevel, _save_file: SaveFileGD) -> void:
	super(data, _save_file)
	if is_init:
		var decoration_datas: Array = load(info.PALM_ISLAND_RESOURCES).palm_islands.map(func(x: Resource): return x.data)
		var palm_island_decorations: Array[PalmIslandDecoration] = []
		var decoration_amount: int = decoration_datas.size()
		var island_amount: int = Random.getRandomKeyVariant(ISLAND_ODDS)
		
		for i: int in range(island_amount):
			palm_island_decorations.append(PalmIslandDecoration.new(decoration_datas[randi_range(0, decoration_amount - 1)].duplicate()))
		
		for PalmIsland: PalmIslandDecoration in palm_island_decorations:
			var avoid_coords: Array = [Vector4i.ZERO]
			var start_coord := onRandomiseStartCoord()
			while(avoid_coords.any(isCloseCoord.bind(start_coord))):
				start_coord = onRandomiseStartCoord()
				
			avoid_coords.append(start_coord)
			PalmIsland.coords = start_coord
			PalmIsland.tile_rotation = randi_range(0, 5)
		level_area_datastore.palm_island_decorations = palm_island_decorations
	onCreatePalmDecorations()
	
func isCloseCoord(x: Vector4i, start_coord: Vector4i) -> bool:
	var distance: int = Game.getCoordsDistance(x, start_coord)
	return distance < DISTANCE_BOUND
	
func onRandomiseStartCoord() -> Vector4i:
	var x: int = randi_range(LOWER_GEN_BOUND, UPPER_GEN_BOUND)
	x *= 1 if Random.getBool() else -1
	
	var y: int = randi_range(LOWER_GEN_BOUND, UPPER_GEN_BOUND)
	y *= 1 if Random.getBool() else -1
		
	return Vector4i(x, y, -x-y, 0)
#endregion

#region Decorations
func onCreatePalmDecorations() -> void:
	for PalmIsland: PalmIslandDecoration in level_area_datastore.palm_island_decorations:
		var coords: Vector4i = Game.onRotateCoordsCC(PalmIsland.tile_rotation, PalmIsland.coords)
		var decoration_position: Vector3 = Game.onCoordsToPosition(coords)
		for _tile_object_data: SavedData in PalmIsland.data:
			var tile_object_data: SavedData = _tile_object_data.duplicate()
			
			if tile_object_data is SavedDataTile: tile_object_data.coords += coords
			else: tile_object_data.position += decoration_position - Vector3(0, 0.3, 0)
			SavedData.onLoadModel(tile_object_data, self)
#endregion

#region Level Area Datastore
func onCreateLevelAreaDatastore() -> LevelAreaDatastore:
	return PalmLevelAreaDatastore.new()
#endregion
