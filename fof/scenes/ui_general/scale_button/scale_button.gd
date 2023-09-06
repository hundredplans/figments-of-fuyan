extends Control

var is_mouse_entered: bool = false
var can_press: int = 0
const initial_delay: float = 0.3
const regular_delay: float = 0.05
var initial_delay_passed: int = 0
var regular_delay_passed: int = 0

@onready var timer: Timer = $DelayTimer
@export var default: int
@export var totalmin: int
@export var totalmax: int
@export var step: int
@export var bigstep: int
@export var label_text: String

func _process(_delta: float) -> void:
	if Input.is_action_pressed("LeftClick"):
		if can_press:
			on_step()
	else:
		regular_delay_passed = 0
		initial_delay_passed = 0

#	if is_mouse_entered:
#		var old_can_press: int = can_press
#		if Input.is_action_pressed("ShiftLeftArrow"):
#			can_press = -2
#
#		elif Input.is_action_pressed("LeftArrow"):
#			can_press = -1
#
#		if Input.is_action_pressed("ShiftRightArrow"):
#			can_press = 2
#
#		elif Input.is_action_pressed("RightArrow"):
#			can_press = 1
#
#		on_step()
#		can_press = 0 if !old_can_press else old_can_press

func _enter_tree() -> void:
	if default >= totalmin and default <= totalmax:
		$Number.text = str(default)
	
	$Label.text = label_text
	
	$Outside.color = Helper.DARK_BROWN
	for child in [$Steppers/Left/BigStep, $Steppers/Right/BigStep]:
		child.color = Color.BLACK
	
	$Inside.color = Helper.LIGHT_BROWN
	for child in [$Steppers/Left/SmallStep, $Steppers/Right/SmallStep]:
		child.color = Color.WHITE
		
	(func():$Outside.size.x += $Label.size.x + 23; $Inside.size.x += $Label.size.x + 23).call_deferred()
		
func on_step() -> void:
	if initial_delay_passed in [0,2]:
		if regular_delay_passed == 2:
			match can_press:
				-2: default = clamp(int($Number.text) - bigstep, totalmin, totalmax)
				-1: default = clamp(int($Number.text) - step, totalmin, totalmax)
				1: default = clamp(int($Number.text) + step, totalmin, totalmax)
				2: default = clamp(int($Number.text) + bigstep, totalmin, totalmax)
				
			$Number.text = str(default)
		elif initial_delay_passed == 2 and regular_delay_passed in [0,2]:
			regular_delay_passed = 1
			Helper.start_timer_attach_method(timer, regular_delay, on_regular_delay_passed)
	
	start_initial_delay_passed()

func on_regular_delay_passed() -> void:
	regular_delay_passed = 2

func start_initial_delay_passed() -> void:
	if initial_delay_passed == 0:
		initial_delay_passed = 1
		Helper.start_timer_attach_method(timer, initial_delay, on_initial_delay_passed)
		
func on_initial_delay_passed() -> void:
	initial_delay_passed = 2

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
