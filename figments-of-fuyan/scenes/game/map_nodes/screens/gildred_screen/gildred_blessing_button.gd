extends Button

signal custom_pressed
@onready var label: FancyTextLabel = %Label

func setInfo(map_effect: MapEffectGD) -> void:
	label.setText(map_effect.getDescription())
