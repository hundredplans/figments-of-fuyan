extends Control

#region Globals
@onready var AreaBackground: ButtonAutomask = %AreaBackground
@onready var Background: ButtonAutomask = %Background
@onready var ArtPop: ButtonAutomask = %ArtPop
@onready var NameLabel: Label = %NameLabel
#endregion

#region Exports
@export var is_inspectable: bool
@export_group("Admin")
@export var rarities: Array[Image]
#endregion
func setInfo(Card: CardGD) -> void:
	Background.setTexture(rarities[Card.info.rarity])
	ArtPop.setTexture(Card.info.art_pop)
	
	AreaBackground.setTexture(Card.getArea().card_background)
	NameLabel.text = Card.info.name
	
