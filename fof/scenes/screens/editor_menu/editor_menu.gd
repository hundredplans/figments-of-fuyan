extends Control
signal level_editor_pressed
signal world_editor_pressed
var screen_change_signals: Array = [\
[world_editor_pressed, "res://scenes/screens/world_editor/world_editor.tscn"]
]

func _on_level_editor_pressed(): level_editor_pressed.emit()
func _on_world_editor_pressed(): world_editor_pressed.emit()
