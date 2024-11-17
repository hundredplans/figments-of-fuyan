extends HBoxContainer

const UI_DELAY: float = 0.2
var selectable_cards: bool
var pinned: bool
var is_down: bool
var level: LevelGD

var mouse_in_ui: bool
@export var AniPlayer: AnimationPlayer

func _ready() -> void:
	AniPlayer.animation_finished.connect(onAnimationFinished)

var temp_up: bool
var temp_down: bool

func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	if !pinned:
		if state: temp_up = true
		else: temp_down = true

var phase: Game.Phases
func setPhase(_phase: Game.Phases) -> void:
	phase = _phase
	var state: bool = onCheckPin()
	if state: onPin()
	else: onUnpin()
	
	onSelectableCards(phase in [Game.Phases.START, Game.Phases.HAND])
	
func onCheckPin() -> bool:
	return phase in [Game.Phases.START, Game.Phases.HAND]

func onPin() -> void:
	pinned = true
	onUp()
		
func onUnpin() -> void:
	pinned = false
	if !mouse_in_ui: onDown()

var energy: int
func onSelectableCards(_selectable_cards: bool) -> void:
	selectable_cards = _selectable_cards
	for CardUI in get_children():
		CardUI.setDisabled(!selectable_cards or !CardUI.Card.isPlayable(energy))

func onUpdateEnergy(_energy: int) -> void:
	energy = _energy
	onSelectableCards(selectable_cards)

func onUp() -> void:
	if onPlayAnimation(false):
		is_down = false
	
func onDown() -> void:
	if onPlayAnimation(true):
		is_down = true

func onPlayAnimation(down: bool) -> bool:
	if !AniPlayer.is_playing() and !((down and is_down) or (!down and !is_down)):
		if down: AniPlayer.play("HandPanelMovement")
		else: AniPlayer.play_backwards("HandPanelMovement")
		return true
	return false

func onAnimationFinished(animation_name: String) -> void:
	if pinned and is_down:
		onUp()
		
	elif !pinned and !is_down and !mouse_in_ui:
		onDown()
		
func _on_child_entered_tree(CardUI: Node) -> void:
	if CardUI is not Control: return
	CardUI.mouse_in_ui.connect(onMouseInUI)

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

func onCardSelected(selected: bool) -> void:
	if selected: onUnpin()
	else: onPin()
		
