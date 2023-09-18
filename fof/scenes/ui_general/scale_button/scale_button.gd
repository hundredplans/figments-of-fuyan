extends Control

signal item_selected
var pressed_inputs: Dictionary = {
	"DownArrow": -2,
	"LeftArrow": -1,
	"UpArrow": 2,
	"RightArrow": 1,
	}
	
var inputs: Dictionary = {
	"MouseDown": -1,
	"MouseUp": 1,
	}

var grabbed: bool = false
var is_mouse_entered_grabber_area: bool = false
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
		if can_press: on_step()
		elif is_mouse_entered_grabber_area or grabbed:
			grabbed = true
			var true_mouse_pos: int = get_viewport().get_mouse_position().x - $GradientInside.global_position.x
			var new_mouse_pos: float = true_mouse_pos
			$GradientInside/Grabber.position.x = (clamp(new_mouse_pos, 0, 200) * 0.825)
			default = ($GradientInside/Grabber.position.x) / 1.7
			set_grabber_position()
			$Number.text = str(default)
			item_selected.emit(default)
		return
			
	elif is_mouse_entered:
		var old_can_press: int = can_press
		for key in pressed_inputs:
			if Input.is_action_pressed(key):
				can_press = pressed_inputs[key]
				on_step()
				can_press = 0 if !old_can_press else old_can_press
				return
				
		for key in inputs:
			if Input.is_action_just_pressed(key):
				can_press = inputs[key]
				on_step()
				can_press = 0 if !old_can_press else old_can_press
				return
				
	regular_delay_passed = 0
	initial_delay_passed = 0
	grabbed = false
	for method in [on_regular_delay_passed, on_initial_delay_passed, Helper.on_timeout_disconnect]:
		if timer.timeout.is_connected(method):
			timer.timeout.disconnect(method)

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
	set_grabber_position()
		
func on_step() -> void:
	if initial_delay_passed in [0,2]:
		if regular_delay_passed in [0, 2]:
			match can_press:
				-2: default = clamp(int($Number.text) - bigstep, totalmin, totalmax)
				-1: default = clamp(int($Number.text) - step, totalmin, totalmax)
				1: default = clamp(int($Number.text) + step, totalmin, totalmax)
				2: default = clamp(int($Number.text) + bigstep, totalmin, totalmax)
				
			$Number.text = str(default)
			item_selected.emit(default)
			set_grabber_position()
			if regular_delay_passed != 1: regular_delay_passed = 0
			
	if initial_delay_passed == 0:
		initial_delay_passed = 1
		Helper.start_timer_attach_method(timer, initial_delay, on_initial_delay_passed)
		
	elif initial_delay_passed == 2 and regular_delay_passed == 0:
		regular_delay_passed = 1
		Helper.start_timer_attach_method(timer, regular_delay, on_regular_delay_passed)

func on_regular_delay_passed() -> void:
	regular_delay_passed = 2
		
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

func set_grabber_position() -> void:
	$GradientInside/Grabber.position.x = default * 1.7
	$GradientInside/Grabber/GrabberSprite.modulate = $GradientInside.texture.get_image().get_pixel(\
	$GradientInside/Grabber.position.x + 10, $GradientInside/Grabber.position.y + 30)

func _on_grabber_area_mouse_entered():
	is_mouse_entered_grabber_area = true

func _on_grabber_area_mouse_exited():
	is_mouse_entered_grabber_area = false
