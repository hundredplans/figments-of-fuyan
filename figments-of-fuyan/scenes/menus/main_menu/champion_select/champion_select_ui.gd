extends Control

signal start
@onready var CardSpot: Control = %CardSpot
@onready var ChampionNameLabel: Label = %ChampionNameLabel
func setInfo(Unit: UnitGD) -> void:
	ChampionNameLabel.text = Unit.info.name
	Unit.onCreateCardUI(CardSpot).set_anchors_preset(PRESET_CENTER)

func _on_cancel_button_pressed() -> void:
	queue_free()

func _on_start_button_pressed() -> void:
	start.emit()
