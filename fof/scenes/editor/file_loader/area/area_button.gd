extends Control
signal pressed
var can_press: bool = false
var info: Dictionary

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick") and can_press:
		pressed.emit(self, info)
		
func set_info(_info: Dictionary) -> void:
	info = _info
	$Label.text = "World " + str(info.world) + "\n\n" + info.iname
	$ID.text = str(info.id)
	$Background/Outside.color = info.pcolor
	$Background/Inside.color = info.acolor

func _on_area_2d_mouse_entered(): can_press = true
func _on_area_2d_mouse_exited(): can_press = false
