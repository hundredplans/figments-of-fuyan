extends TileGD

func getFallDamage(Tile: TileGD) -> int:
	return max(super(Tile) - 2, 0)

func getCardYOffset() -> float:
	return 0.2
