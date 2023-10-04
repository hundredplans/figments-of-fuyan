extends Control
@onready var screen_change_signals: Array = [
[$Buttons/LeftButtons/AreaEditor.pressed, "res://scenes/screens/area_editor/area_editor.tscn"],
[$Buttons/RightButtons/LoreBooksEditor.pressed, "res://scenes/screens/lore_books_editor/lore_books_editor.tscn"],
[$Buttons/LeftButtons/CardEditor.pressed, "res://scenes/screens/card_editor/card_editor.tscn"],
[$Buttons/LeftButtons/LevelEditor.pressed, "res://scenes/screens/level_editor/level_editor.tscn"],
]
