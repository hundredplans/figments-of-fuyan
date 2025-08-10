class_name PriceDatastore extends Resource

@export var price: int
@export var data: SavedData
@export var bought: bool

func _init(_price: int = 0, _data: SavedData = null) -> void:
	price = _price
	data = _data

func toString() -> String:
	return\
		"Price: " + str(price) +\
		", DataType: " + str(data.getInfoType().getFofName()) +\
		", ID: " + str(data.id)

func setBought(state: bool = true) -> void:
	bought = state
	
