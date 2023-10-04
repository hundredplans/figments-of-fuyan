extends Control
const SCROLL_PIXELS: int = 60
var is_open: int = -1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and $GrabButton.button_pressed:
		position += event.relative
		
	if is_open > 0:
		for input in [["MouseDown", -1], ["MouseUp", 1]]:
			if Input.is_action_just_pressed(input[0]):
				on_scroll_text(input[1])
		
func on_scroll_text(direction: int) -> void:
	var label: Label = $OpenMenu.get_child(0)
	label.position.y = clamp(label.position.y + (SCROLL_PIXELS * direction), -label.size.y + $OpenMenu.size.y, 0)
	
func _ready() -> void:
	if Settings.hide_patch_notes_menu == 1:
		visible = false
	elif Settings.open_patch_notes_menu > 0:
		_on_version_history_pressed()
	
func _on_version_history_pressed():
	is_open = -1 if is_open == 1 else 1
	for node in [$GrabZone, $GrabButton, $Background]:
		node.size.y += ($OpenMenu.size.y + 10) * is_open
		
	match is_open:
		1:
			var label := Label.new()
			$OpenMenu.add_child(label)
			label.autowrap_mode = TextServer.AUTOWRAP_WORD
			label.size.x = $OpenMenu.size.x
			label.text = Helper.return_file_contents("res://scenes/screens/main_menu/patch_notes/version_history.txt")
		-1:
			for child in $OpenMenu.get_children(): child.queue_free()
