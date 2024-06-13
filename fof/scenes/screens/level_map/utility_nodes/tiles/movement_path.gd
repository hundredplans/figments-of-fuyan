class_name MovementPathGD
extends Resource

var OriginTile: TileGD
var DestinationTile: TileGD
var fneighbours: Array # Array of fneighbour, fall dmg
var fall_damages: Dictionary # Dictionary that associates each tile to a specific fall dmg
var vis_array: Array = []
var is_attack: bool = false

func _init(_Tile: TileGD) -> void:
	OriginTile = _Tile

static func onFindTile(Tile: TileGD, movement_paths: Array) -> MovementPathGD:
	for movement_path in movement_paths: if movement_path.DestinationTile == Tile: return movement_path
	return null

static func onFindEnterVisionIndex(movement_path: MovementPathGD) -> int:
	for i in range(movement_path.vis_array.size()):
		if movement_path.vis_array[i].total_vision == VisInfoGD.ENTER:
			return i
	return -1

static func onFneighboursTiles(_fneighbours: Array):
	return _fneighbours.map(func(x: FneighbourGD): return x.Tile)

func isVisArrayInvis() -> bool:
	return vis_array.all(func(x: VisInfoGD): return x.isNull() or x.total_vision == VisInfoGD.INVISIBLE)
