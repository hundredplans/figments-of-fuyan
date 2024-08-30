extends Button

signal custom_pressed

var data: SavedData
var info: TileObjectInfo
func setInfo(_info: TileObjectInfo) -> void:
	info = _info
	@warning_ignore("incompatible_ternary")
	data = SavedDataTile.new(info.id) if info is TileInfo else SavedDataObject.new(info.id)
	text = _info.name

func _on_pressed():
	custom_pressed.emit(getData())

func getData() -> SavedData:
	return data.duplicate(true)
