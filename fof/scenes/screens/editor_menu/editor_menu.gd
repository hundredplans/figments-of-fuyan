extends Control
@onready var screen_change_signals: Array = [
[$Buttons/LeftButtons/AreaEditor.pressed, "res://scenes/screens/area_editor/area_editor.tscn"],
[$Buttons/RightButtons/LoreBooksEditor.pressed, "res://scenes/screens/lore_books_editor/lore_books_editor.tscn"]
]
