extends Button

signal custom_pressed

var info: TileObjectInfoGD
func setInfo(_info: TileObjectInfoGD) -> void:
	info = _info
	text = _info.name

func _on_pressed():
	custom_pressed.emit(info.getBaseData())
