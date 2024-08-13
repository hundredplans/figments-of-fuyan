extends Button

signal custom_pressed

var info: TileObjectInfo
func setInfo(_info: TileObjectInfo) -> void:
	info = _info
	text = _info.name

func _on_pressed():
	custom_pressed.emit(info)
