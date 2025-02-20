class_name PalmLevelGD extends LevelGD

#region Globals
var ISLAND_ODDS: Dictionary = {
	"6": 0.5, # 0.5
	"7": 0.4, # 0.5
	"8": 0.1
		#"2": 0.39,
		#"3": 0.1,
		#"4": 0.01
}
	
const DISTANCE_BOUND: int = 30
const LOWER_GEN_BOUND: int = 70
const UPPER_GEN_BOUND: int = 120
#endregion

#region Save / Load / Init
func onLoadActiveLevel(data: SavedDataLevel, _save_file: SaveFileGD) -> void:
	super(data, _save_file)
	if is_init:
		var decoration_datas: Array = load(info.PALM_ISLAND_RESOURCES).palm_islands.map(func(x: Resource): return x.data)
		decoration_datas.append(decoration_datas[0].duplicate())
		decoration_datas.append(decoration_datas[1].duplicate())
		decoration_datas.append(decoration_datas[0].duplicate())
		decoration_datas.append(decoration_datas[1].duplicate())
		decoration_datas.append(decoration_datas[0].duplicate())
		decoration_datas.append(decoration_datas[1].duplicate())
		
		var decoration_coords: Array = []
		if !decoration_datas.is_empty():
			decoration_datas.shuffle()
			decoration_datas.resize(int(Random.getRandomKey(ISLAND_ODDS)))
			
			var avoid_coords: Array = [Vector4i.ZERO]
			for island in decoration_datas:
				var start_coord := onRandomiseStartCoord()
				while(!avoid_coords.all(func(x: Vector4i): return Game.getCoordsDistance(x, start_coord) >= DISTANCE_BOUND)):
					start_coord = onRandomiseStartCoord()
					
				avoid_coords.append(start_coord)
				decoration_coords.append(start_coord)
			level_area_datastore.decoration_coords = decoration_coords
			level_area_datastore.decoration_datas = decoration_datas
	onCreatePalmDecorations()
	
func onRandomiseStartCoord() -> Vector4i:
	var x: int = randi_range(LOWER_GEN_BOUND, UPPER_GEN_BOUND)
	x *= 1 if Random.getBool() else -1
	
	var y: int = randi_range(LOWER_GEN_BOUND, UPPER_GEN_BOUND)
	y *= 1 if Random.getBool() else -1
		
	return Vector4i(x, y, -x-y, 0)
#endregion

#region Decorations
func onCreatePalmDecorations() -> void:
	var water_repeating: Node3D = preload("res://test/water_repating.tscn").instantiate()
	add_child(water_repeating)
	water_repeating.name = "WaterRepeating"
	
	var decoration_datas: Array = level_area_datastore.decoration_datas
	var decoration_coords: Array = level_area_datastore.decoration_coords
	
	for i in range(decoration_datas.size()):
		var data: Array = decoration_datas[i]
		var start_coord: Vector4i = decoration_coords[i]
		for tile_object_data in data:
			if tile_object_data is SavedDataTile:
				tile_object_data.coords += start_coord
			else:
				tile_object_data.position += (Game.onCoordsToPosition(start_coord) - Vector3(0, 0.3, 0))
			SavedData.onLoadModel(tile_object_data, self)
#endregion

#region Level Area Datastore
func onCreateLevelAreaDatastore() -> LevelAreaDatastore:
	return PalmLevelAreaDatastore.new()
#endregion
