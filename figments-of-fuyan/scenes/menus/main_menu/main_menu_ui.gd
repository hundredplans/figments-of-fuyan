extends Control

var World: Node3D
@onready var GoBackLabel: Label = %GoBackLabel
func _ready() -> void:
	GoBackLabel.visible = false
	if World != null:
		World.begin_travel.connect(onBeginTravel)
		World.end_travel.connect(onEndTravel)

func onBeginTravel(__: String, ___: bool) -> void:
	GoBackLabel.visible = false

func onEndTravel(__: String, ___: bool) -> void:
	GoBackLabel.visible = true
