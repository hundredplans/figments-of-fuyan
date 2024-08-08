extends Control
var mouse_state: bool = false
const TOOLTIP_DELAY: float = 0.4
var tooltip: Control

signal mouse_in_ui

@export var ToolIcon: Sprite2D
@export var ToolBox: Sprite2D
@export var ToolBoxOutline: Node

var tool: ToolGD

func _ready() -> void: visible = false; ToolIcon.texture = null

func onCreateTooltip() -> void:
	await get_tree().create_timer(TOOLTIP_DELAY).timeout
	if mouse_state and tooltip == null:
		tooltip = preload("res://scenes/screens/level_ui/base_tooltip/base_tooltip.tscn").instantiate()
		var text: String = tool.tool_info.display_name + ": " + tool.getDescription()
		add_child(tooltip)
		tooltip.setInfo(text)
		
func onRemoveTooltip() -> void:
	if tooltip != null: tooltip.queue_free()

func onIsMouseInUI(x: bool):
	mouse_state = x
	if x: onCreateTooltip()
	else: onRemoveTooltip()
	mouse_in_ui.emit(x)

@export var TOOL_ICON_SIZE: int = 40
@export var EQUIP_ANIMATION_TIME: float = 0.3
@export var ROTATION_ANIMATION_TIME: float = 0.3
func setInfo(_tool: ToolGD = null) -> void:
	await onUnequipAnimation()
	tool = _tool
	visible = tool != null
	if visible:
		if tool.tool_info.rarity == tool.tool_info.RARITIES.MINI:
			ToolBoxOutline.texture = preload("res://assets/base_game/tools/base_tool/tool_box_mini.png")
			ToolBox.texture = preload("res://assets/base_game/tools/base_tool/tool_box_mini.png")
		else:
			ToolBoxOutline.texture = preload("res://assets/base_game/tools/base_tool/tool_box_outline.png")
			if tool.is_ascended: ToolBox.texture = preload("res://assets/base_game/tools/base_tool/tool_box_ascended.png")
			else: ToolBox.texture = preload("res://assets/base_game/tools/base_tool/tool_box_regular.png")

		ToolBoxOutline.modulate = Helper.rarity_boon_tool_colors[tool.tool_info.rarity]
		ToolIcon.texture = tool.tool_info.icon
		await onEquipAnimation()

func onUnequipAnimation() -> void:
	if ToolBox.texture != null:
		var tween := create_tween()
		tween.tween_property(ToolIcon, "region_rect:position:x", TOOL_ICON_SIZE, EQUIP_ANIMATION_TIME)
		await get_tree().create_timer(EQUIP_ANIMATION_TIME * 1.2).timeout

func onEquipAnimation() -> void:
	ToolIcon.region_rect.position.x = TOOL_ICON_SIZE
	var tween := create_tween()
	tween.tween_property(ToolIcon, "region_rect:position:x", 0, EQUIP_ANIMATION_TIME)
	
	
	await get_tree().create_timer(EQUIP_ANIMATION_TIME * 1.2).timeout
	var rotate_tween := create_tween()
	rotate_tween.tween_property(ToolIcon, "rotation", TAU, ROTATION_ANIMATION_TIME).as_relative()
	

func _process(_delta: float) -> void:
	if tooltip != null: tooltip.setPosition()

func onToolAbilityUsed(delay: float) -> void:
	for child in get_children(): child.material = preload("res://assets/shaders/bounce_from_center/bounce_from_center.tres")
	await get_tree().create_timer(delay).timeout
	for child in get_children(): child.material = null
