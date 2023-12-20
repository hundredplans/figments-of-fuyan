extends Control
var node_type: int = 0

func _ready() -> void:
	for btn in $Buttons.get_children():
		btn.mouse_exited.connect(on_btn_mouse_exited)
		btn.mouse_entered.connect(on_btn_mouse_entered.bind(int(str(btn.name))))

func on_btn_mouse_entered(i: int) -> void:
	node_type = i
	
func on_btn_mouse_exited() -> void:
	node_type = 0
