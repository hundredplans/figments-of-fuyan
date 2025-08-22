extends Control

@onready var PriceDisplay: Label = %PriceDisplay
func setShillings(shillings: int) -> void:
	PriceDisplay.text = str(shillings)
	PriceDisplay.modulate = Color.WHITE if shillings >= 0 else Color.RED
