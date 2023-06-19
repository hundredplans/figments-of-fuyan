extends Control
var currently_stepping_back: bool = false
var back_history: Array = []

func _ready():
	$BackArrow.visible = false

func load_gui(path: String) -> void:
	
	for child in $MainScreen.get_children():
		child.queue_free()
		
	var gui_screen: Control = load(path).instantiate()
	$MainScreen.add_child(gui_screen)	
func _on_back_arrow_pressed():
	on_go_back_step()
func _process(_delta: float):
	if Input.is_action_just_pressed("InputBackMenu"):
		on_go_back_step()
func on_go_back_step() -> void:
	if back_history.size():
		if !currently_stepping_back:
			currently_stepping_back = true
			back_history[0][0].call([back_history[0][1], func(): currently_stepping_back = false; $BackArrow.disabled = false])
			back_history.remove_at(0)
	
	if !back_history.size():
		$BackArrow.visible = false
		
func add_to_back_history(item: Array):
	back_history.append(item)
	$BackArrow.visible = true
	
func change_animation_status(status: int):
	if !status:
		$BackArrow.disabled = false
	else:
		$BackArrow.disabled = true
