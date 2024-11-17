extends Control

@export var DeckScreenPacked: PackedScene

@onready var ToolIcon: TextureRect = %ToolIcon
@onready var ToolNameLabel: Label = %ToolNameLabel
@onready var SlotOne: PanelContainer = %SlotOne
@onready var SlotTwo: PanelContainer = %SlotTwo

signal taken

var Tool: ToolGD
var save_file: SaveFileGD
func setInfo(_Tool: ToolGD, _save_file: SaveFileGD) -> void:
	Tool = _Tool
	save_file = _save_file
	
	ToolIcon.texture = Tool.getIcon()
	ToolNameLabel.text = Tool.info.name
	
	SlotOne.setDisabled(save_file.tool_belt.size() > 0)
	SlotTwo.setDisabled(save_file.tool_belt.size() != 1)
		
func onSlotPressed() -> void:
	save_file.onUpdateToolbelt(Tool)
	onTaken()

func _on_bin_button_pressed() -> void:
	onTaken()

func _on_deck_screen_pressed() -> void:
	var DeckScreen: Control = DeckScreenPacked.instantiate()
	add_child(DeckScreen)
	DeckScreen.selected.connect(onCardSelected)
	DeckScreen.setInfo(true)
	DeckScreen.onDisableCards(onDisableCardsWithTool)
	
func onCardSelected(Card: CardGD) -> void:
	Card.onAddTool(Tool)
	Tool.reparent(Card)
	onTaken()
	
func onTaken() -> void:
	taken.emit(Tool)
	queue_free()
	
func onDisableCardsWithTool(CardUI: Control) -> bool:
	return CardUI.Card.Tool != null
	
