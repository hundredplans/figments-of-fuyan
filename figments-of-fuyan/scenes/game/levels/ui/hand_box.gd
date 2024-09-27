extends HBoxContainer

const UI_DELAY: float = 0.2
var selectable_cards: bool
var pinned: bool
var is_down: bool
var mouse_in_ui: bool
var AniPlayer: AnimationPlayer
var area: Area2D

func setInfo(_AniPlayer: AnimationPlayer, _area: Area2D) -> void:
	AniPlayer = _AniPlayer
	area = _area
	area.mouse_entered.connect(onMouseInUI.bind(true))
	area.mouse_exited.connect(onMouseInUI.bind(false))

func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	if !pinned:
		if state: onUp()
		else: onDown()

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
