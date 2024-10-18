extends Button

signal custom_pressed

var data: SavedData
var info: TileObjectInfo
func setInfo(_info: TileObjectInfo) -> void:
	info = _info
	data = info.saved_data.new(info.id)
	text = _info.name

func _on_pressed():
	custom_pressed.emit(getData())

func getData() -> SavedData:
	return data.duplicate(true)
