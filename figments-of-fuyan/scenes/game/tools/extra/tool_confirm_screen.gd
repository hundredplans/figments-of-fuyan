extends Control

signal confirmed

@onready var TextLabel: Label = %TextLabel

@export_multiline var ascend_tool_text: String
@export_multiline var override_tool_text: String

var Tool: ToolGD
func setInfo(_Tool: ToolGD, ascend_tool: bool, override_tool: bool) -> void:
	Tool = _Tool
	if ascend_tool: TextLabel.text = ascend_tool_text
	elif override_tool: TextLabel.text = override_tool_text
	else: TextLabel.text = "Are you sure about that?"

func _on_yes_button_pressed() -> void:
	confirmed.emit(Tool)

func _on_no_button_pressed() -> void:
	queue_free()
