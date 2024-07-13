extends Control
var mouse_state: bool = false
const TOOLTIP_DELAY: float = 0.4
var tooltip: Control

signal mouse_in_ui

@export var ToolIcon: Sprite2D
@export var ToolBox: Sprite2D
@export var ToolBoxOutline: Node

var tool: ToolGD

func _ready() -> void: visible = false

func onCreateTooltip() -> void:
	await get_tree().create_timer(TOOLTIP_DELAY).timeout
	if mouse_state and tooltip == null:
		tooltip = preload("res://scenes/screens/level_ui/base_tooltip/base_tooltip.tscn").instantiate()
		var text: String = tool.tool_info.display_name + ": " + tool.getDescription()
		tooltip.setInfo(text)
		add_child(tooltip)
		tooltip.setPosition()
		
func onRemoveTooltip() -> void:
	if tooltip != null: tooltip.queue_free()

func onIsMouseInUI(x: bool):
	mouse_state = x
	if x: onCreateTooltip()
	else: onRemoveTooltip()
	mouse_in_ui.emit(x)

func setInfo(_tool: ToolGD) -> void:
	tool = _tool
	visible = tool != null
	if visible:
		ToolBoxOutline.visible = tool.tool_info.rarity != tool.tool_info.RARITIES.MINI
		if tool.is_ascended: ToolBox.texture = preload("res://assets/base_game/tools/base_tool/tool_box_ascended.png")
		elif tool.tool_info.rarity == tool.tool_info.RARITIES.MINI:
			ToolBox.texture = preload("res://assets/base_game/tools/base_tool/tool_box_mini.png")
		else: ToolBox.texture = preload("res://assets/base_game/tools/base_tool/tool_box_regular.png")

		ToolBoxOutline.modulate = Helper.rarity_boon_tool_colors[tool.tool_info.rarity]
		ToolIcon.texture = tool.tool_info.icon

func _process(_delta: float) -> void:
	if tooltip != null: tooltip.setPosition()
