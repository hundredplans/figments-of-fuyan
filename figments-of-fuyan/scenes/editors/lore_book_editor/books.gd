extends VBoxContainer

@export var PackedPanelButton: PackedScene
@export var lore_books_path: String
func _ready() -> void:
	for file_name in Helper.getFilesRecursive(lore_books_path):
		file_name = file_name.substr(lore_books_path.length() + 1).left(-4)
		var panel_button: PanelContainer = PackedPanelButton.instantiate()
		add_child(panel_button)
		panel_button.setText(file_name)
