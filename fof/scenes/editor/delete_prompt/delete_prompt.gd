extends Control
signal delete_item

func on_ready(i: int, confirm_name: String, file_valid: bool) -> void:
	match file_valid:
		true:
			match i:
				0: on_confirm_name(confirm_name)
				1: on_confirm_checkbox()
				2: on_confirm_match(true)
		false: on_confirm_match(false)

func on_confirm_checkbox() -> void:
	var binary_button: Control = preload('res://scenes/ui_general/binary_button/binary_button.tscn').instantiate()
	binary_button.default = -1
	binary_button.label_text = "Confirm File Delete"
	$Prompt.add_child(binary_button)
	binary_button.position = Vector2(200, 150)
	binary_button.item_selected.connect((func(x: int): on_confirm_match(x == 1)))
	
func on_confirm_name(confirm_name: String) -> void:
	var line_edit: LineEdit = LineEdit.new()
	$Prompt.add_child(line_edit)
	line_edit.placeholder_text = confirm_name
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_edit.text_submitted.connect((func(x: String): on_confirm_match(x == confirm_name)))
	line_edit.size.x = $Prompt.size.x
	line_edit.position.y = 150
	line_edit.theme = preload("res://assets/UI/lora/lora48.tres")

func on_confirm_match(x: bool) -> void:
	_on_exit_button_pressed()
	var sfx: Dictionary = {
		false: "unconfirm_default",
		true: "confirm_default"
	}
	if x: delete_item.emit()
	AudioMaster.play_sfx(sfx[x])

func _on_exit_button_pressed():
	queue_free()
