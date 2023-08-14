extends Control
signal level_editor_pressed
signal area_editor_pressed
var screen_change_signals: Array = [\
[area_editor_pressed, "res://scenes/screens/area_editor/area_editor.tscn"]
]

func _on_level_editor_pressed(): level_editor_pressed.emit()
func _on_area_editor_pressed(): area_editor_pressed.emit()
