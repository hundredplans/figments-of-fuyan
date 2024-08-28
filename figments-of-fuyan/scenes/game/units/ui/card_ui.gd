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
func setInfo(Unit: UnitGD) -> void:
	Background.setTexture(rarities[Unit.info.rarity])
	ArtPop.setTexture(Unit.getArtPop())
	
	AreaBackground.setTexture(Unit.getArea().card_background)
	NameLabel.text = Unit.info.name
	
