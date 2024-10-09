class_name CoordsSaver extends Resource

enum TYPES {NULL, CARD, TILE, OBJECT}

@export var coords: Vector4i
@export var type: TYPES
@export var index: int # Index saved if it's an object

func onSave(fof_object: FofGD) -> CoordsSaver:
	var gdscript: Variant = fof_object.get_script()
	
	if gdscript is CardGD: type = TYPES.CARD; coords = fof_object.getCoords()
	elif gdscript is TileGD: type = TYPES.TILE; coords = fof_object.getCoords()
	elif gdscript is ObjectGD:
		type = TYPES.OBJECT
		
		var Tile: TileGD = fof_object.occupied_tiles[0]
		index = Tile.occupied_objects.find(fof_object)
		coords = Tile.getCoords()
	return self

func onLoad() -> FofGD:
	match type:
		TYPES.CARD: return Game.getFieldCard(Game.getTile(coords))
		TYPES.TILE: return Game.getTile(coords)
		TYPES.OBJECT: return Game.getTile(coords).occupied_objects[index]
	return null
