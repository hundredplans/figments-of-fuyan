extends TileGD

func getFallDamage(Tile: TileGD) -> int:
	return 0

func getCardPosition() -> Vector3:
	return super() - Vector3(0, 0.1, 0)
