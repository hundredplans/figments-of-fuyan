extends EncounterGD

func getStashItemPrice(item: FofGD) -> int:
	var base_tier: int = Game.getArea().getWorldDifficulty()
	var above_tier_mult: int = max(item.getTier() - base_tier + 1, 1)
	return -1 * (int(Game.getPriceForItem(item, false) * (item.getTier() + 1)) * above_tier_mult)

func isStashDragItem() -> bool:
	return false
