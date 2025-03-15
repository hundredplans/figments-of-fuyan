extends TileGD

func getFallDamage(Tile: TileGD) -> int:
	return max(super(Tile) - 2, 0)

func getCardYOffsetBase() -> float:
	return 0.2
