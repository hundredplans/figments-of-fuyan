extends Control
signal mouse_in_ui

@onready var ButtonsContainer: Container = %ButtonsContainer
@onready var FadeBackground: Control = %FadeBackground

const SCALE_BUTTONS_TIME: float = 0.5
const FADE_BACKGROUND_TIME: float = 0.25

func _ready() -> void:
	ButtonsContainer.pivot_offset = ButtonsContainer.size / 2
	ButtonsContainer.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(ButtonsContainer, "scale", Vector2.ONE, SCALE_BUTTONS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
	FadeBackground.modulate.a = 0
	var fade_tween := create_tween()
	fade_tween.tween_property(FadeBackground, "modulate:a", 0.5, FADE_BACKGROUND_TIME)
		
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
	
	var fade_tween := create_tween()
	fade_tween.tween_property(FadeBackground, "modulate:a", 0, FADE_BACKGROUND_TIME)
	
	await tween.finished
	queue_free()

func onQuitButtonPressed() -> void:
	Game.getSaveFile().onSaveToFile()
	get_tree().quit()

func onMainMenuButtonPressed() -> void:
	setPressableState(false)
	var fade_tween := create_tween()
	fade_tween.tween_property(FadeBackground, "modulate", Color.BLACK, FADE_BACKGROUND_TIME)
	
	var tween := create_tween()
	tween.tween_property(ButtonsContainer, "scale", -Vector2.ONE, SCALE_BUTTONS_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	Game.getSaveFile().onLoadMainMenu()
