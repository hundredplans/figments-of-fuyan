extends Control

signal mouse_in_ui
signal pressed
signal lock_slot
signal remove_deck_card

const LOCKED_MODULATE := Color(0.38, 0.188, 0.0)

var CardUI: Control
var is_mouse_in_ui: bool
var deck_slot: DeckSlot
var lock_state: bool

@export var LOCK_CLOSED_TX: Texture2D
@export var LOCK_OPEN_TX: Texture2D

@export var lock_lock_sfx: AudioStream
@export var lock_unlock_sfx: AudioStream

@onready var CardUISpot: Control = %CardUISpot
@onready var DeckSlotUITexture: TextureRect = %DeckSlotUITexture
@onready var LockIcon: Control = %LockIcon

func setCardUI(_CardUI: Control = null) -> void:
	if CardUI != null: CardUI.queue_free()
	CardUI = _CardUI
	onUpdateModulate()
	setButtons()
		
func getCardUISpot() -> Control:
	return CardUISpot

func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	onUpdateModulate()

func onLockPressed() -> void:
	setLock(!lock_state)
	lock_slot.emit(deck_slot, lock_state)
		
func onUpdateModulate() -> void:
	var new_modulate := (Color(0.5, 0.5, 0.5) if is_mouse_in_ui else Color.WHITE) if !lock_state else LOCKED_MODULATE
	DeckSlotUITexture.modulate = new_modulate
	CardUISpot.modulate = new_modulate

func onExitButtonPressed() -> void:
	remove_deck_card.emit(CardUI, deck_slot)
	CardUI = null
	setButtons()
	
func setButtons() -> void:
	LockIcon.visible = CardUI == null
	#if CardUI != null:
		#ExitButton.setDisabled(CardUI.Card.info.rarity == Game.Rarities.CHAMPION)
		
func setDeckSlot(_deck_slot: DeckSlot) -> void:
	deck_slot = _deck_slot
	setLock(deck_slot.is_locked)
		
func setLock(state: bool) -> void:
	LockIcon.texture = LOCK_CLOSED_TX if state else LOCK_OPEN_TX
	LockIcon.CLICK_NOISE = lock_unlock_sfx if state else lock_lock_sfx
	lock_state = state
	onUpdateModulate()
	
func getLockState() -> bool:
	return lock_state
	
func setMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	LockIcon.mouse_filter = _mouse_filter
	DeckSlotUITexture.mouse_filter = _mouse_filter
	
func setBackgroundMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	DeckSlotUITexture.mouse_filter = _mouse_filter
	
func setLockMouseFilter(_mouse_filter: Control.MouseFilter) -> void:
	LockIcon.mouse_filter = _mouse_filter
