extends BoonGD

var charges: int = 2
func onCustomTrigger(val: int) -> int:
	charges -= 1
	if charges == 0: Boons.onRemoveBoon(6)
	return val * 2
