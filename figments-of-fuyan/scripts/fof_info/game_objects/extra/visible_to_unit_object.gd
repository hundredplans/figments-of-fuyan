class_name VisibleToUnitObject extends VisibleToUnit

var by_tiles: Dictionary # The tiles that are visible that make this visible
@export var tiles_public_ids: Array

func onSave() -> void:
	tiles_public_ids = by_tiles.keys().map(func(x: TileGD): return x.public_id)
	
func onLoad() -> void:
	for Tile in tiles_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x)):
		by_tiles[Tile] = null
	
func isVisibleToUnit() -> bool:
	return direct or !by_tiles.keys().is_empty()

func onAddTile(Tile: TileGD) -> void:
	by_tiles[Tile] = null
	
func onRemoveTile(Tile: TileGD) -> void:
	by_tiles.erase(Tile)
