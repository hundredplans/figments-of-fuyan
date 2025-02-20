extends TileGD

func getFallDamage(Tile: TileGD) -> int:
	return max(super(Tile) - 2, 0)

func getCardPosition() -> Vector3:
	return super() - Vector3(0, 0.1, 0)
