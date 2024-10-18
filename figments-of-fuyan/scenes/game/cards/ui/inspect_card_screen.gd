extends Control

@export var tooltip: PackedScene

@onready var InspectSubviewport: SubViewport = %InspectSubviewport
@onready var CardSpot: Control = %CardSpot
@onready var FlavorTextLabel: Label = %FlavorTextLabel
@onready var TooltipContainer: VBoxContainer = %TooltipContainer

var Card: CardGD
func setInfo(_Card: CardGD) -> void:
	Card = _Card
	var CardUI: Control = Card.onCreateCardUI(CardSpot)
	CardUI.setBuffLabels()
	
	FlavorTextLabel.text = Card.info.flavor_text
	InspectSubviewport.setInfo(Card)
	
	for FofObject in Card.field_traits + Card.status_effects:
		var Tooltip: Control = tooltip.instantiate()
		TooltipContainer.add_child(Tooltip)
		Tooltip.setInfo(FofObject)
		
