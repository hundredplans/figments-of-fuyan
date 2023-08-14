extends Control
var can_drag: bool = false
var held: bool = true
func _on_exit_button_pressed(): queue_free()

func _on_roll_pressed():
	for chr in $Numbers.text:
		if int(chr) not in [0,1,2,3,4,5,6,7,8,9]:
			return
			
	if $Numbers.text.length() > 0:
		$Result.text = str(randi_range(1, int($Numbers.text)))

func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - 280
			position.y = (get_viewport().get_mouse_position().y) - 40
		else:
			held = false

func _on_grab_zone_mouse_entered():
	can_drag = true

func _on_grab_zone_mouse_exited():
	can_drag = false
