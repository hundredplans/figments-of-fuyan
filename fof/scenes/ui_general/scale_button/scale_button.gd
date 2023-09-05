extends Control

var is_mouse_entered: bool = false
var can_press: int = 0
@export var default: int
@export var totalmin: int
@export var totalmax: int
@export var step: int
@export var bigstep: int
@export var label_text: String

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick") and can_press: on_step()

	if is_mouse_entered:
		if Input.is_action_pressed("ShiftLeftArrow"):
			pass
			
		elif Input.is_action_pressed("LeftArrow"):
			pass
			
		if Input.is_action_pressed("ShiftRightArrow"):
			pass
			
		elif Input.is_action_pressed("RightArrow"):
			pass
	

func _enter_tree() -> void:
	if default >= totalmin and default <= totalmax:
		$Number.text = str(default)
	
	$Label.text = label_text
	
	for child in [$Outside, $Steppers/Left/BigStep, $Steppers/Right/BigStep]:
		child.color = Helper.DARK_BROWN
	
	for child in [$Inside, $Steppers/Left/SmallStep, $Steppers/Right/SmallStep]:
		child.color = Helper.LIGHT_BROWN
		
func on_step() -> void:
	match can_press:
		-2: default = clamp(int($Number.text) - bigstep, totalmin, totalmax)
		-1: default = clamp(int($Number.text) - step, totalmin, totalmax)
		1: default = clamp(int($Number.text) + step, totalmin, totalmax)
		2: default = clamp(int($Number.text) + bigstep, totalmin, totalmax)
		
	$Number.text = str(default)

func _on_big_step_mouse_entered(i: int):
	can_press = 2 * i

func _on_big_step_mouse_exited():
	can_press = 0

func _on_small_step_mouse_entered(i: int):
	can_press = 1 * i

func _on_small_step_mouse_exited():
	can_press = 0

func _on_mouse_exited():
	is_mouse_entered = false
	can_press = 0

func _on_mouse_entered():
	is_mouse_entered = true
