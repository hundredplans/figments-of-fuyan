class_name DefaultButton extends DefaultControl

signal pressed

@export var CLICK_NOISE: AudioStreamMP3 = load("res://assets/sounds/ui/default_press.mp3")
@export var HOVER_NOISE: AudioStreamMP3 = load("res://assets/sounds/ui/default_hover.mp3")

func _ready() -> void:
	super()
	mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND

func onMouseInUI(state: bool) -> void:
	super(state)
	if is_mouse_in_ui and !disabled and pressable:
		Audio.onSoundEffect(HOVER_NOISE)
	
var pressable: bool = true
func setPressable(state: bool) -> void:
	pressable = state
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled and pressable:
		onPressed()
		
func setDisabled(state: bool) -> void:
	super(state)
	mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	get_viewport().update_mouse_cursor_state()
		
func onPressed() -> void:
	pressed.emit()
	Audio.onSoundEffect(CLICK_NOISE)
