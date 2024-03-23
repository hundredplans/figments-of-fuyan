extends Control

var Heroes: Node
var ActiveUnit: UnitGD
var UnitStatus: Control
@onready var label: Label = $Label
func on_set_state(Unit: UnitGD, state: bool) -> void:
	if !state and UnitStatus != null:
		UnitStatus.queue_free()
		
	elif Unit != null and state and !(UnitStatus != null and UnitStatus == Unit.UnitStatus.UnitStatusExtra):
		if UnitStatus != null: UnitStatus.queue_free()
		UnitStatus = preload("res://scenes/screens/level_ui/unit_status/unit_status.tscn").instantiate()
		add_child(UnitStatus)
		UnitStatus.HOVER_CARD_OFFSET = Vector2(-120, -540)
		UnitStatus.position.x -= 12
		UnitStatus.Heroes = Heroes
		UnitStatus.on_set_unit(Unit)
		UnitStatus.on_set_status_box_modulate("TurnActive")
		UnitStatus.on_unit_spectated(true)
		Unit.UnitStatus.UnitStatusExtra = UnitStatus
		
func _on_child_exiting_tree(__: Control):
	on_set_state(null, false)
