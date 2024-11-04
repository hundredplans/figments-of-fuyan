extends Control

signal custom_pressed
signal mouse_in_ui

@onready var PanelButton: PanelContainer = %PanelButton

var data: SavedData
var info: TileObjectInfo
func setInfo(_info: TileObjectInfo) -> void:
	info = _info
	data = info.saved_data.new(info.id)
	PanelButton.setText(info.name)
	PanelButton.pressed.connect(_on_pressed)
	PanelButton.mouse_in_ui.connect(func(x: bool): mouse_in_ui.emit(x))

func _on_pressed():
	custom_pressed.emit(getData())

func getData() -> SavedData:
	return data.duplicate(true)
