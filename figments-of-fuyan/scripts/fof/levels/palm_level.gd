class_name PalmLevelGD extends LevelGD

#region Globals
var decoration_datas: Array
var decoration_coords: Array
var ISLAND_ODDS: Dictionary = {
	"1": 0.5,
	"2": 0.5,
		#"2": 0.39,
		#"3": 0.1,
		#"4": 0.01
}
	
const DISTANCE_BOUND: int = 30
const LOWER_GEN_BOUND: int = 40
const UPPER_GEN_BOUND: int = 60
#endregion

#region Save / Load / Init
func onFofInit() -> void:
	super()
	decoration_datas = load(info.PALM_ISLAND_RESOURCES).palm_islands.map(func(x: Resource): return x.data)
	decoration_datas.shuffle()
	decoration_datas.resize(int(Random.getRandomKey(ISLAND_ODDS)))
	
	var avoid_coords: Array = [Vector4i.ZERO]
	for island in decoration_datas:
		var start_coord := Vector4i.ZERO
		while(avoid_coords.any(func(x: Vector4i): return Game.getCoordsDistance(x, start_coord) <= DISTANCE_BOUND)):
			var x: int = randi_range(LOWER_GEN_BOUND, UPPER_GEN_BOUND)
			x *= int(Random.getBool()) * -1
			
			var y: int = randi_range(-UPPER_GEN_BOUND, UPPER_GEN_BOUND)
			
			start_coord = Vector4i(x, y, -x-y, 0) if Random.getBool() else Vector4i(y, x, -y-x, 0)
			
		avoid_coords.append(start_coord)
		decoration_coords.append(start_coord)
	onCreatePalmDecorations()
			
func onSave() -> SavedDataPalmLevel:
	return SavedDataPalmLevel.new(info.id, false, timeout, decoration_datas, decoration_coords)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	decoration_datas = data.decoration_datas
	decoration_coords = data.decoration_coords
	
	onCreatePalmDecorations()
	
#endregion

#region Decorations
func onCreatePalmDecorations() -> void:
	add_child(preload("res://test/water_repating.tscn").instantiate())
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
