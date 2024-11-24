extends Control

@export var DeckScreenPacked: PackedScene
@export var PanelButtonPacked: PackedScene
@export var ToolIconPacked: PackedScene
@export var ToolConfirmScreenPacked: PackedScene
@export var toolbelt_slots_label_settings: LabelSettings

@onready var ToolIcon: TextureRect = %ToolIcon
@onready var ToolNameLabel: Label = %ToolNameLabel
@onready var ToolbeltSlots: Container = %ToolbeltSlots

@onready var DisposeLabel: Label = %DisposeLabel
@onready var DisposeContainer: Container = %DisposeContainer

signal taken

var Tool: ToolGD
var save_file: SaveFileGD
func setInfo(_Tool: ToolGD, _save_file: SaveFileGD, remove_dispose: bool = false) -> void:
	Tool = _Tool
	save_file = _save_file
	
	ToolIcon.texture = Tool.getIcon()
	ToolNameLabel.text = Tool.info.name
	
	for i in range(Game.TOOLBELT_SIZE):
		var tool_exists: bool = save_file.tool_belt.size() > i
		if !tool_exists:
			var PanelButton: Control = PanelButtonPacked.instantiate()
			PanelButton.label_settings = toolbelt_slots_label_settings
			PanelButton.text = "+"
			PanelButton.pressed.connect(onSlotPressed)
			ToolbeltSlots.add_child(PanelButton)
			continue
			
		var ToolIcon: Control = ToolIconPacked.instantiate()
		ToolbeltSlots.add_child(ToolIcon)
		var ToolbeltTool: ToolGD = save_file.tool_belt[i]
		ToolIcon.custom_minimum_size = Vector2(80, 80)
		ToolIcon.setInfo(ToolbeltTool)
		ToolIcon.pressed.connect(onToolPressed)
	
	if remove_dispose:
		DisposeLabel.visible = false
		DisposeContainer.visible = false
		
func onSlotPressed() -> void:
	save_file.onUpdateToolbelt(Tool)
	onTaken()
	
func onToolPressed(ToolbeltTool: ToolGD) -> void:
	var ascend_tool: bool = ToolbeltTool.info.id == Tool.info.id and !ToolbeltTool.ascended and !Tool.ascended
	var override_tool: bool = !ascend_tool
	
	var ToolConfirmScreen: Control = ToolConfirmScreenPacked.instantiate()
	add_child(ToolConfirmScreen)
	ToolConfirmScreen.setInfo(ToolbeltTool, ascend_tool, override_tool)
	ToolConfirmScreen.confirmed.connect(onToolConfirmed)
	
func onToolConfirmed(ToolbeltTool: ToolGD) -> void:
	var ascend_tool: bool = ToolbeltTool.info.id == Tool.info.id and !ToolbeltTool.ascended and !Tool.ascended
	if ascend_tool: ToolbeltTool.ascended = true
	else:
		save_file.onRemoveToolFromToolbelt(ToolbeltTool)
		save_file.onUpdateToolbelt(Tool)
	onTaken()

func _on_bin_button_pressed() -> void:
	onTaken()

func _on_deck_screen_pressed() -> void:
	var DeckScreen: Control = DeckScreenPacked.instantiate()
	add_child(DeckScreen)
	DeckScreen.selected.connect(onCardSelected)
	DeckScreen.setInfo(true)
	
func onCardSelected(Card: CardGD) -> void:
	if Card.Tool == null or Card.Tool.info.id != Tool.info.id:
		Tool.reparent(Card)
		Card.onAddTool(Tool)
	else:
		Card.Tool.setAscended(true)
	onTaken()
	
func onTaken() -> void:
	taken.emit(Tool)
	queue_free()
	
