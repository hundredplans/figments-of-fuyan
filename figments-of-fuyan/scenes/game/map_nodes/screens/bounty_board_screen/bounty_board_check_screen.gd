extends Control

@onready var MainContainer: Container = %MainContainer
func setInfo(kill_amounts: Array) -> void:
	for kill_amount in kill_amounts:
		var LabelCardUIContainer := HBoxContainer.new()
		
		
