extends Control

signal mouse_in_ui

@export var button: TextureButton
var boon_info: BoonInfoGD
func setInfo(_boon_info: BoonInfoGD) -> void:
	boon_info = _boon_info
	button.texture = boon_info.icon

func _on_button_mouse_in_ui(x: bool): mouse_in_ui.emit(x)
