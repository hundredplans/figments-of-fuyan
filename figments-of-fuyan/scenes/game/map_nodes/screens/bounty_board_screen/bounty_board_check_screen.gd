extends Control

@onready var MainContainer: Container = %MainContainer
func setInfo(kill_amounts: Array) -> void:
	for _kill_amount in kill_amounts:
		var _LabelCardUIContainer := HBoxContainer.new()
		
		
