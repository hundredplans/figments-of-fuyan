extends TileGD

func getFallDamage(Tile: TileGD) -> int:
	return floor(super(Tile) / 2.0)
