extends EncounterGD

func getStashItemPrice(item: FofGD) -> int:
	return -1 * int(Game.getPriceForItem(item, false))
	
func isStashDragItem() -> bool:
	return false
