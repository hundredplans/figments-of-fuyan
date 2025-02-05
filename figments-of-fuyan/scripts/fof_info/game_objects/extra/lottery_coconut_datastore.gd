extends Resource

@export_group("Add to 100%")
@export_range(0, 100, 0.1) var heal: float = 70
@export_range(0, 100, 0.1) var minitool: float = 20
@export_range(0, 100, 0.1) var crab: float = 10
@export_group("")

func getDict() -> Dictionary:
	return {
		"heal": heal,
		"minitool": minitool,
		"crab": crab
	}
