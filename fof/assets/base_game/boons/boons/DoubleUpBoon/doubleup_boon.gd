extends BoonGD

var charges: int = 0
func onArrive() -> void:
	charges = 2 if is_ascended else 1

func onCustomTrigger(val: int) -> int:
	if charges > 0 and val > 0:
		charges -= 1
		return val * 2
	return val
