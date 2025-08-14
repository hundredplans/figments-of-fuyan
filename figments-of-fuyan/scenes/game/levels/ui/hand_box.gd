extends HBoxContainer

const BOTTOM_SCREEN_OFFSET: int = 5
signal mouse_in_ui

const UI_DELAY: float = 0.05
var selectable_cards: bool
var pinned: bool = true
var is_down: bool
var level: LevelGD

var is_mouse_in_ui: bool

@export var BottomBox: Control
var temp_up: bool
var temp_down: bool

func onMouseInUI(state: bool) -> void:
	if get_viewport().get_mouse_position().y >= get_viewport().size.y - BOTTOM_SCREEN_OFFSET: return
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	if !pinned:
		if state: temp_up = true
		else: temp_down = true

var phase: Game.Phases
func setPhase(_phase: Game.Phases, instant: bool) -> void:
	phase = _phase
	var state: bool = onCheckPin()
	
	if state:
		onPin(instant)
	else:
		onUnpin(instant)
	
	onSelectableCards(state)
	
func onCheckPin() -> bool:
	return phase in [Game.Phases.START, Game.Phases.HAND]

func onPin(instant: bool) -> void:
	pinned = true
	await get_tree().process_frame
	if !pinned: return
	onUp(instant)
		
func onUnpin(instant: bool) -> void:
	pinned = false
	if !is_mouse_in_ui: onDown(instant)

var energy: int
func onSelectableCards(_selectable_cards: bool) -> void:
	selectable_cards = _selectable_cards
	for CardUI in get_children():
		CardUI.setDisabled(!selectable_cards or !CardUI.Card.isPlayable(energy))

func onDrawCardUI(Card: CardGD, CardUI: Control) -> void:
	CardUI.setDisabled(!selectable_cards or !CardUI.Card.isPlayable(energy))

func onUpdateEnergy(_energy: int) -> void:
	energy = _energy
	onSelectableCards(selectable_cards)

func onUp(instant: bool = false) -> void:
	if is_tweening: return
	onPlayTween(false, instant)
	if is_tweening:
		is_down = false
	
func onDown(instant: bool = false) -> void:
	if is_tweening: return
	onPlayTween(true, instant)
	if is_tweening:
		is_down = true

const TWEEN_OFFSET: int = 410
const TWEEN_SPEED: float = 0.2
var is_tweening: bool
func onPlayTween(down: bool, instant: bool) -> void:
	if !is_tweening and !((down and is_down) or (!down and !is_down)):
		var tween := get_tree().create_tween()
		var offset: int = TWEEN_OFFSET * (1 if down else -1)
		
		if !instant:
			tween.tween_property(BottomBox, "position:y", offset, TWEEN_SPEED).as_relative()
			
			is_tweening = true
			await tween.finished
			is_tweening = false
		else:
			BottomBox.position.y += offset
			is_tweening = true
			await get_tree().process_frame
			is_tweening = false
		onTweenFinished()

func onTweenFinished() -> void:
	if pinned and is_down:
		onUp()
		
	elif !pinned and !is_down and !is_mouse_in_ui:
		onDown()
		
func _on_child_entered_tree(CardUI: Node) -> void:
	if CardUI is not Control: return

func _process(_delta: float) -> void:
	if temp_up and temp_down:
		temp_up = false
		temp_down = false
	elif temp_up:
		temp_up = false
		onUp()
	elif temp_down:
		temp_down = false
		onDown()
