class_name PriceDatastore extends Resource

@export var price: int
@export var data: SavedData
@export var position: Vector2
@export var bought: bool

func _init(_price: int = 0, _data: SavedData = null, _position := Vector2.ZERO) -> void:
	price = _price
	data = _data
	position = _position

func toString() -> String:
	return\
		"Price: " + str(price) +\
		", DataType: " + str(data.getInfoType().getFofName()) +\
		", ID: " + str(data.id)

func setBought(state: bool = true) -> void:
	bought = state
	
func getData() -> SavedData:
	return data
	
func getPosition() -> Vector2:
	return position
