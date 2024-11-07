extends VBoxContainer

@export var PackedPanelButton: PackedScene
@export var lore_books_path: String
func _ready() -> void:
	for directory in Helper.getDirectoriesRecursive(lore_books_path):
		directory = directory.substr(lore_books_path.length() + 1)
		var panel_button: PanelContainer = PackedPanelButton.instantiate()
		add_child(panel_button)
		panel_button.setText(directory)
