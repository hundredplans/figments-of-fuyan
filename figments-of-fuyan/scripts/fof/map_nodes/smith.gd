extends EncounterGD

func getStashItemPrice(item: FofGD) -> int:
	return -1 * int(Game.getPriceForItem(item, false) * (item.getTier() + 1))

func isStashDragItem() -> bool:
	return false
