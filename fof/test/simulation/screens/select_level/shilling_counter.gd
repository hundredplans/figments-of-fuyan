extends Control

var change_shillings: int = 1
var can_drag: bool = false
var held: bool = true
var old_text: String

func _ready() -> void:
	on_change_shillings_button()

func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - 140
			position.y = (get_viewport().get_mouse_position().y) - 80
		else:
			held = false

func _on_grab_zone_mouse_entered():
	can_drag = true

func _on_grab_zone_mouse_exited():
	can_drag = false

func _on_remove_button_pressed():
	queue_free()

func on_change_shillings_pressed(i: int):
	change_shillings = i
	on_change_shillings_button()

func on_change_shillings_button() -> void:
	match change_shillings:
		-1:
			$ChangeShillings/Subtract.modulate = Color(1,0,0)
			$ChangeShillings/Add.modulate = Color(1,1,1)
		1:
			$ChangeShillings/Subtract.modulate = Color(1,1,1)
			$ChangeShillings/Add.modulate = Color(1,0,0)

func on_shilling_update_counter(i: int) -> void:
	if $Count.text.is_valid_int() or $Count.text == "":
		$Count.text = str(max(int($Count.text) + (i * change_shillings), 0))
		old_text = $Count.text
		
func _on_count_text_changed(new_text):
	if new_text.is_valid_int() or new_text == "":
		old_text = new_text
	else:
		$Count.text = old_text
