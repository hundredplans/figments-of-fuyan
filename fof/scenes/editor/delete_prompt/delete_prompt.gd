extends Control
signal delete_item

func on_ready(i: int, confirm_name: String) -> void:
	match i:
		0: on_confirm_name(confirm_name)
		1: on_confirm_checkbox()
		2: delete_item.emit(); queue_free()

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
	line_edit.text_submitted.connect((func(x: String): on_confirm_match.bind(x == confirm_name)))
	line_edit.size.x = $Prompt.size.x
	line_edit.position.y = 150
	line_edit.theme = preload("res://assets/UI/lora/lora48.tres")

func on_confirm_match(x: bool) -> void:
	_on_exit_button_pressed()
	var sfx: Dictionary = {
		false: "res://scenes/editor/delete_prompt/unconfirm.wav",
		true: "res://scenes/editor/delete_prompt/confirm.wav",
	}
	if x: delete_item.emit()
	AudioMaster.play_sfx(load(sfx[x]), -10)

func _on_exit_button_pressed():
	queue_free()
