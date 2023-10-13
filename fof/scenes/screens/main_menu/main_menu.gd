extends Control
@onready var screen_change: Array = [
["Play", ""],
["Simulation", get_parent().get_parent().get_parent().sim_pressed],
["EditorMenu", "res://scenes/screens/editor_menu/editor_menu.tscn"],
["Settings", "res://scenes/screens/settings_menu/settings_menu.tscn"],
["Fuyanopedia", "res://scenes/screens/fuyanopedia/fuyanopedia.tscn"],
["LevelEditor", "res://scenes/screens/level_editor/level_editor.tscn"],
["Quit", get_parent().get_parent().get_parent().on_user_quit],
]

func _ready() -> void:
	$AnimationItem.visible = false

func on_move_screen_setup() -> void:
	$AnimationItem.visible = true
