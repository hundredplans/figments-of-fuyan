class_name OffsetDatastore extends Resource

@export var offset: Vector4i
@export var height_below: int
@export var height_above: int
@export var ignore_height: bool

@export var relative_offset: Vector4i

func _init(_offset := Vector4i.ZERO, _height_below: int = 0, _height_above: int = 0, _ignore_height: bool = false) -> void:
	offset = _offset
	height_below = _height_below
	height_above = _height_above
	ignore_height = _ignore_height

func onAddOffset(_offset: Vector4i) -> void:
	offset += _offset

func getTile(coords := Vector4i.ZERO) -> TileGD:
	# offset = 0, height_above = 1 would go through 1 -> 0
	coords += offset
	if ignore_height:
		for w in range(20):
			var Tile: TileGD = Game.getTile(Vector4i(coords.x, coords.y, coords.z, w))
			if Tile != null:
				return Tile
			
	for height in range(coords.w + height_above, max(coords.w - height_below - 1, -1)):
		var Tile: TileGD = Game.getTile(Vector4i(coords.x, coords.y, coords.z, height))
		if Tile != null: return Tile
	return null
