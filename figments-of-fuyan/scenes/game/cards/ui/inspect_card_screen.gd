extends Control

signal mouse_in_ui

@export var TooltipItemPackedScene: PackedScene

@export var ActiveTurnIcon: Texture2D
@export var PassedTurnIcon: Texture2D
@export var AwakenedInCombatIcon: Texture2D
@export var TemporaryCardIcon: Texture2D

@onready var InspectSubviewport: SubViewport = %InspectSubviewport
@onready var CardSpot: Control = %CardSpot
@onready var FlavorTextLabel: Label = %FlavorTextLabel
@onready var TooltipContainer: VBoxContainer = %TooltipContainer

@onready var ArchetypeNameLabel: Label = %ArchetypeNameLabel
@onready var ArchetypeDescriptionLabel: Label = %ArchetypeDescriptionLabel
@onready var ArchetypePanel: PanelContainer = %ArchetypePanel

var Card: CardGD
func setInfo(_Card: CardGD) -> void:
	Card = _Card
	var CardUI: Control = Card.onCreateCardUI(CardSpot, false, false)
	CardUI.mouse_in_ui.connect(onMouseInUI)
	CardUI.setBuffLabels()
		
	FlavorTextLabel.text = Card.info.flavor_text
	InspectSubviewport.setInfo(Card)
	
	for FofObject in (Card.getFieldTraits() + Card.status_effects + Card.field_effects + [Card.Tool]).filter(func(x: FofGD): return x != null):
		var TooltipItem: Control = TooltipItemPackedScene.instantiate()
		TooltipContainer.add_child(TooltipItem)
		TooltipItem.setInfo(FofObject, true)
		TooltipItem.mouse_in_ui.connect(onTooltipMouseEntered.bind(TooltipItem))
		
		
	onCreateCustomTooltip(Card.turn_state == Game.TurnStates.PASSED,\
		"This unit's turn has passed, it has to wait until it's next turn to move or use abilities", "Passed Turn", PassedTurnIcon)
	onCreateCustomTooltip(Card.turn_state == Game.TurnStates.ACTIVE,\
		"This unit is currently active, it can move, attack and use abilities unless another unit is moved or it's turn is passed", "Active Turn", ActiveTurnIcon)
	onCreateCustomTooltip(Card.is_awakened_in_combat,\
		"This unit was awakened in combat and will not give energy upon death", "Awakened in Combat", AwakenedInCombatIcon)
	onCreateCustomTooltip(Card.isTemporary(), \
		"This unit is temporary and not an official part of your deck", "Temporary Card", TemporaryCardIcon)
	
	ArchetypePanel.visible = Card.isEnemy(0)
	if Card.isEnemy(0):
		ArchetypeNameLabel.text = Card.info.archetype.name
		ArchetypeDescriptionLabel.text = Card.info.archetype.description
		
func onCreateCustomTooltip(condition: bool, text: String, title: String, icon: Texture2D) -> void:
	if !condition: return
	var Tooltip: Control = TooltipItemPackedScene.instantiate()
	TooltipContainer.add_child(Tooltip)
	Tooltip.setInfoDirect(title, icon, text)
		
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	
func onTooltipMouseEntered(state: bool, TooltipItem: Control) -> void:
	Game.onMouseInUITooltip(state, TooltipItem.getTextInfos(), self)
