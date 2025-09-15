extends Control
signal mouse_in_ui
signal exit_start

@onready var SettingsButton: DefaultButton = %SettingsButton
@onready var ButtonsContainer: Container = %ButtonsContainer
@onready var FadeCreamBackground: Control = %FadeCreamBackground

const SCALE_BUTTONS_TIME: float = 0.5
const FADE_BACKGROUND_TIME: float = 0.25

func _ready() -> void:
	ButtonsContainer.pivot_offset = ButtonsContainer.size / 2
	ButtonsContainer.scale = Vector2.ZERO
	
	var main_color: Color = Game.getArea().getAreaColor()
	var second_color: Color = Game.getArea().getSecondAreaColor()
	var third_color: Color = Game.getArea().getThirdAreaColor()
	
	FadeCreamBackground.FADE_COLOR = main_color
	FadeCreamBackground.color = main_color
	FadeCreamBackground.onFade(true)
	
	SettingsButton.setDisabled(true)
	
	for btn: DefaultButton in ButtonsContainer.get_children():
		btn.BASE_COLOR = main_color
		btn.HOVER_COLOR = second_color
		btn.DISABLED_COLOR = third_color
		btn.setModulate()
	
	var tween := create_tween()
	tween.tween_property(ButtonsContainer, "scale", Vector2.ONE, SCALE_BUTTONS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	await tween.finished
	
	pressable_state = true

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)

func onResumeButtonPressed() -> void:
	onExit()

var pressable_state: bool
func setPressableState(state: bool) -> void:
	pressable_state = state
	for button: Label in ButtonsContainer.get_children():
		button.setPressable(state)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back") and pressable_state:
		onExit()
		
func onExit() -> void:
	setPressableState(false)
	var tween := create_tween()
	tween.tween_property(ButtonsContainer, "scale", -Vector2.ONE, SCALE_BUTTONS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	FadeCreamBackground.onFade(false)
	
	exit_start.emit()
	await tween.finished
	queue_free()

func onQuitButtonPressed() -> void:
	Game.getSaveFile().onSaveToFile()
	get_tree().quit()

func onMainMenuButtonPressed() -> void:
	setPressableState(false)
	
	FadeCreamBackground.DEFAULT_ALPHA = 255
	FadeCreamBackground.FADE_COLOR = Color.BLACK
	FadeCreamBackground.onFade(true)
	
	var tween := create_tween()
	tween.tween_property(ButtonsContainer, "scale", -Vector2.ONE, SCALE_BUTTONS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	Game.getSaveFile().onSaveToFile()
	Game.getSaveFile().onLoadMainMenu()
