extends Control

signal selected
@onready var ToolIcon: TextureRect = %ToolIcon
@onready var ToolNameLabel: Label = %ToolNameLabel
@onready var ToolbeltSlots: HBoxContainer = %ToolbeltSlots

@export var PanelButtonPacked: PackedScene
@export var ToolIconPacked: PackedScene

var id: int
func setInfo(tool_info: ToolInfo, save_file: SaveFileGD) -> void:
	ToolIcon.texture = tool_info.getIcon()
	ToolNameLabel.text = tool_info.name
	id = tool_info.id
	
	for i in range(Game.TOOLBELT_SIZE):
		var tool_exists: bool = save_file.tool_belt.size() > i
		if !tool_exists:
			var PanelButton: Control = PanelButtonPacked.instantiate()
			PanelButton.custom_minimum_size = Vector2(80, 80)
			ToolbeltSlots.add_child(PanelButton)
			continue
			
		var ToolIcon: Control = ToolIconPacked.instantiate()
		ToolbeltSlots.add_child(ToolIcon)
		var ToolbeltTool: ToolGD = save_file.tool_belt[i]
		ToolIcon.custom_minimum_size = Vector2(80, 80)
		ToolIcon.setInfo(ToolbeltTool)
		ToolIcon.pressed.connect(onSelected)

func onDeckButtonPressed() -> void:
	var DeckScreen: Control = Game.onCreateDeckScreen(self, true, 1, onFilterCardsWithTool)
	DeckScreen.selected.connect(onDeckScreenSelected)

func onDeckScreenSelected(Card: CardGD) -> void:
	onSelected(Card.Tool, Card)

func onFilterCardsWithTool(CardUI: Control) -> bool:
	return !(CardUI.Card.Tool != null and CardUI.Card.Tool.info.id == id)

func onSelected(Tool: ToolGD, Card: CardGD = null) -> void:
	selected.emit(Tool, Card) # Card null if from tool belt
	queue_free()
