extends Resource

@export_group("Add to 100%")
@export_range(0, 100, 0.1) var nothing: float
@export_range(0, 100, 0.1) var heal: float
@export_range(0, 100, 0.1) var minitool: float
@export_range(0, 100, 0.1) var crab: float
@export_group("")

func getDict() -> Dictionary:
	return {
		"nothing": nothing,
		"heal": heal,
		"minitool": minitool,
		"crab": crab
	}
