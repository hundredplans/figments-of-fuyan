extends Resource

@export var offensive_trinkets: Array[GDScript]
@export var defensive_trinkets: Array[GDScript]
@export var misc_trinkets: Array[GDScript]
@export var debuff_trinkets: Array[GDScript]
@export var support_trinkets: Array[GDScript]
@export var icons: Array[Texture2D]

func getTrinketScript(id: int) -> TrinketEffectGD:
	var arr: Array[GDScript]
	match id:
		0: arr = offensive_trinkets
		1: arr = defensive_trinkets
		2: arr = misc_trinkets
		3: arr = debuff_trinkets
		4: arr = support_trinkets
	
	var random: int = randi() % arr.size()
	var Trinket := TrinketEffectGD.new(id, random)
	Trinket.script = arr[random]
	return Trinket

func getIcon(id: int) -> Texture2D:
	return icons[id]
