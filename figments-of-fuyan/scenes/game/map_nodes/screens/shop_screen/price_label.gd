extends Control

@onready var PriceDisplay: Label = %PriceDisplay
func setShillings(shillings: int) -> void:
	PriceDisplay.text = str(shillings)
