extends Control

#region Globals
@onready var Background: ButtonAutomask = %Background
@onready var ArtPop: ButtonAutomask = %ArtPop
@onready var NameLabel: Label = %NameLabel
#endregion

#region Exports
@export var rarities: Array[Image]
#endregion
func setInfo(Unit: UnitGD) -> void:
	Background.setTexture(rarities[Unit.info.rarity])
	ArtPop.setTexture(Unit.getArtPop())
	NameLabel.text = Unit.info.name
	
