extends Control

signal mouse_in_ui
signal pressed
signal send_to_stash
signal lock_slot
signal remove_deck_card

var CardUI: Control
var deck_slot: DeckSlot
var lock_state: bool
var selected: bool

@export var LOCK_CLOSED_TX: Texture2D
@export var LOCK_OPEN_TX: Texture2D

@onready var DeckSlotUITexture: TextureRect = %DeckSlotUITexture
@onready var ExitButton: Label = %ExitButton
@onready var LockIcon: Control = %LockIcon

func _ready() -> void:
	default_hover_color = DeckSlotUITexture.HOVER_COLOR

func setCardUI(_CardUI: Control = null) -> void:
	if CardUI != null: CardUI.queue_free()
	CardUI = _CardUI
	
	if CardUI != null:
		var Card: CardGD = CardUI.Card
		move_child(CardUI, 1)
	
	setButtons()
	setDeckSlotUIModulate()

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)

func onLockPressed() -> void:
	setLock(!lock_state)
	lock_slot.emit(deck_slot, lock_state)
	
	if lock_state and selected:
		onDeckSlotPressed()

func onExitButtonPressed() -> void:
	CardUI.Card.onChangeCardPlace(Game.CardPlaces.STASH)
	send_to_stash.emit(deck_slot, CardUI.Card)
	CardUI.queue_free()
	remove_deck_card.emit(CardUI, deck_slot)
	CardUI = null
	setButtons()
	
func setButtons() -> void:
	ExitButton.visible = CardUI != null
	LockIcon.visible = CardUI == null
	
	if CardUI != null:
		ExitButton.setDisabled(CardUI.Card.info.rarity == Game.Rarities.CHAMPION)
		
func setDeckSlot(_deck_slot: DeckSlot) -> void:
	deck_slot = _deck_slot
	setLock(deck_slot.is_locked)
		
func setLock(state: bool) -> void:
	LockIcon.texture = LOCK_CLOSED_TX if state else LOCK_OPEN_TX
	lock_state = state
	DeckSlotUITexture.setDisabled(lock_state)
	
	setDeckSlotUIModulate()

func onDeckSlotPressed() -> void:
	onSelect(!selected)
	pressed.emit(deck_slot, selected)
	
func onSelect(state: bool) -> void:
	selected = state
	setDeckSlotUIModulate()

const SELECTED_MODULATE := Color(1, 1, 1)
const DEFAULT_MODULATE := Color(0.5, 0.5, 0.5)
const LOCKED_MODULATE := Color(0.38, 0.188, 0.0)
var default_hover_color: Color

func setDeckSlotUIModulate() -> void:
	DeckSlotUITexture.self_modulate = SELECTED_MODULATE if selected else (DEFAULT_MODULATE if !lock_state else LOCKED_MODULATE)
	#DeckSlotUITexture.onChangeHoverColor(Color(1, 1, 1) if selected else default_hover_color)
