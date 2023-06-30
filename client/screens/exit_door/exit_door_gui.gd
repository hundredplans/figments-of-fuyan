@tool
extends Control
signal go_back_step_from_child
signal exit_door_exit_game
const exit_path: String = "res://screens/exit_door/exit-door-path.tres"

@export var font_color := Color8(255, 255, 160, 255)
@export var outline_font_color := Color8(103, 79, 0, 255)

@export var pressed_font_color := Color8(146, 143, 0, 255)
@export var pressed_outline_font_color := Color8(45, 33, 0, 255)

@export var hover_font_color := Color8(178, 174, 0, 255)
@export var hover_outline_font_color := Color8(110, 85, 0, 255)

func _ready():
	
	for i in [$Body/Confirm, $Body/Cancel]:
		var ls: LabelSettings = i.get_node("Label").label_settings
		ls.font_color = font_color
		ls.outline_color = outline_font_color
		
		i.mouse_entered.connect((func(s): s.font_color = hover_font_color; s.outline_color = hover_outline_font_color).bind(ls))
		i.mouse_exited.connect((func(s): s.font_color = font_color; s.outline_color = outline_font_color).bind(ls))
		i.pressed.connect((func(s): s.font_color = pressed_font_color; s.outline_color = pressed_outline_font_color).bind(ls))

func _on_cancel_pressed(): go_back_step_from_child.emit()
func _on_confirm_pressed(): exit_door_exit_game.emit(exit_path); queue_free()

