class_name BossIntentConditionResultFanAttack extends BossIntentConditionResult

var TripleAdjacentDiagonalTile: TileGD
@export var triple_adjacent_diagonal_tile_public_id: int

func onSave() -> void:
	triple_adjacent_diagonal_tile_public_id = TripleAdjacentDiagonalTile.public_id
	
func onLoad() -> void:
	TripleAdjacentDiagonalTile = Game.onFindPublicIDObject(triple_adjacent_diagonal_tile_public_id)

func getTripleAdjacentDiagonalTile() -> TileGD:
	return TripleAdjacentDiagonalTile

func setTripleAdjacentDiagonalTile(Tile: TileGD) -> void:
	TripleAdjacentDiagonalTile = Tile
