extends Control
var screen_change: Array = [
["Play", "", 0],
["Simulation", func(): get_parent().get_parent().sim_pressed(), 0],
["Editor Menu", "res://scenes/screens/editor_menu/editor_menu.tscn", 0],
["Settings", "res://scenes/screens/settings_menu/settings_menu.tscn", 0],
["Fuyanopedia", "res://scenes/screens/fuyanopedia/fuyanopedia.tscn", 0],
["Level Editor", "res://scenes/screens/level_editor/level_editor.tscn", 1],
["Quit", func(): get_parent().get_parent().on_user_quit(); get_tree().quit(), 2],
]
