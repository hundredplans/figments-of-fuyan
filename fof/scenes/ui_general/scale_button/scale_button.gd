extends Control
signal item_selected

var arrow_delay: int = 0
@onready var GradientButton: TextureButton = $GradientButton
@onready var Grabber: TextureButton = $Grabber

@export var min_max: Vector2i = Vector2i(0, 100)
@export var steps: Vector2i = Vector2(1, 10)
@export var default: int = 0
@export var label_text: String
@export var disable_scrollwheel: bool
@export var snap_mode: bool

const INITIAL_DELAY: float = 0.3
const REGULAR_DELAY: float = 0.05
const GRADIENT_OFFSET: int = 20

@onready var pressed_inputs: Dictionary = {
	"DownArrow": -steps.y,
	"LeftArrow": -steps.x,
	"UpArrow": steps.y,
	"RightArrow": steps.x,
	}
	
@onready var inputs: Dictionary = {
	"MouseDown": -steps.x,
	"MouseUp": steps.x,
	}
func _process(_delta: float) -> void:
	if Grabber.button_pressed: _on_gradient_button_pressed()
	var is_pressed: bool = false
	if Rect2(GradientButton.global_position, GradientButton.size).has_point(get_viewport().get_mouse_position()):
		for input in pressed_inputs:
			if Input.is_action_pressed(input):
				is_pressed = true
				if arrow_delay in [0, 3]:
					match arrow_delay:
						0: arrow_delay = 1
						3: arrow_delay = 4
					default = clamp(default + pressed_inputs[input], min_max.x, min_max.y)
					set_grabber_position()
					break
		
		if !disable_scrollwheel:
			for input in inputs:
				if Input.is_action_just_pressed(input):
					default = clamp(default + inputs[input], min_max.x, min_max.y)
					set_grabber_position()
					break

		if arrow_delay in [1, 4]:
			var delay: float
			match arrow_delay:
				1: arrow_delay = 2; delay = INITIAL_DELAY
				4: arrow_delay = 5; delay = REGULAR_DELAY
			await get_tree().create_timer(delay).timeout
			arrow_delay = 3
			
	if !is_pressed: arrow_delay = 0

func _ready() -> void:
	Helper.create_button_clickmask(Grabber)
	(func():$Background/Outside.size.x += $Label.size.x + 23; $Background/Inside.size.x += $Label.size.x + 23).call_deferred()
	set_grabber_position()
	if snap_mode:
		var total: int = min_max.y - min_max.x - 1
		var difference: int = round($SnapBars.size.x / (total + 1))
		for i in range(total + 2):
			var bar := ColorRect.new()
			$SnapBars.add_child(bar)
			bar.color = Color(0,0,0)
			bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bar.size.y = $SnapBars.size.y
			bar.size.x = 6
			bar.position.x = (difference * i) - 3
			
	
func _enter_tree() -> void:
	default = clamp(default, min_max.x, min_max.y)
	$Label.text = label_text
	
func set_grabber_position() -> void:
	if str(default) != $Number.text:
		$Number.text = str(default)
		var gbgpx: int = int(GradientButton.position.x)
		Grabber.position.x = round(remap(default, min_max.x, min_max.y, gbgpx + GRADIENT_OFFSET, gbgpx + GradientButton.size.x - GRADIENT_OFFSET) - 15)
		Grabber.modulate = GradientButton.texture_normal.get_image().get_pixel(\
		int(Grabber.position.x - GradientButton.position.x + (Grabber.size.x * 0.5)), 30)
		item_selected.emit(default)

func _on_gradient_button_pressed():
	var gbgpx: int = int(GradientButton.global_position.x)
	var clamped_mouse: int = clamp(get_viewport().get_mouse_position().x, gbgpx + GRADIENT_OFFSET, gbgpx + GradientButton.size.x - GRADIENT_OFFSET)
	default = round(remap(clamped_mouse, gbgpx + GRADIENT_OFFSET, gbgpx + GradientButton.size.x - GRADIENT_OFFSET, min_max.x, min_max.y))
	set_grabber_position()
