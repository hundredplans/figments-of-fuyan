extends Control

signal pressed
#region Globals
@onready var AreaBackground: ButtonAutomask = %AreaBackground
@onready var Background: ButtonAutomask = %Background
@onready var ArtPop: ButtonAutomask = %ArtPop
@onready var NameLabel: Label = %NameLabel

@onready var AttackLabel: Label = %AttackLabel
@onready var HealthLabel: Label = %HealthLabel
@onready var SpeedLabel: Label = %SpeedLabel
@onready var EnergyLabel: Label = %EnergyLabel
@onready var TextLabel: FancyTextLabel = %TextLabel
@onready var ToolControl: Control = %ToolControl
#endregion

#region Exports
@export var is_inspectable: bool
@export_group("Admin")
@export var rarities: Array[Image]
#endregion
var Card: CardGD

func setInfo(_Card: CardGD) -> void:
	Card = _Card
	Background.setTexture(rarities[Card.info.rarity])
	ArtPop.setTexture(Card.info.art_pop)
	TextLabel.setText(Card.getAbilityText())
	AreaBackground.setTexture(Card.getArea().card_background)
	NameLabel.text = Card.info.name
	AttackLabel.text = str(Card.attack)
	HealthLabel.text = str(Card.health)
	SpeedLabel.text = str(Card.speed)
	EnergyLabel.text = str(Card.energy)
	ToolControl.visible = false
	
func onPressed() -> void:
	pressed.emit(self)
