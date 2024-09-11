extends Button

@export var start_state: bool = true
@export var hide_node: Control

func _ready() -> void:
	setVisible(start_state)
	setText()

func _on_pressed() -> void:
	if hide_node != null:
		setVisible(!hide_node.visible)
		setText()
		
func setText() -> void:
	if hide_node != null:
		text = "Show" if !hide_node.visible else "Hide"

func setVisible(state: bool) -> void:
	if hide_node != null: hide_node.visible = state
