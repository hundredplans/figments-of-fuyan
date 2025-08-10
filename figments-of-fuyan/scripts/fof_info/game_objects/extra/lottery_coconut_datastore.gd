extends Resource

@export_range(0, 1, 0.005) var heal: float = 0.7
@export_range(0, 1, 0.005) var minitool: float = 0.2
@export_range(0, 1, 0.005) var crab: float = 0.1

func getDict() -> Dictionary:
	return {
		"heal": heal,
		"minitool": minitool,
		"crab": crab
	}
