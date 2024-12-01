extends Control

signal taken
signal mouse_signal

@onready var CardsContainer: HBoxContainer = %CardsContainer

var save_file: SaveFileGD
func setInfo(cards: Array, _save_file: SaveFileGD) -> void:
	save_file = _save_file
	for Card in cards:
		var CardUI: Control = Card.onCreateCardUI(CardsContainer, true)
		CardUI.mouse_in_ui.connect(onMouseInUI)
		CardUI.pressed.connect(onCardPressed)

var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	
func onCardPressed(CardUI: Control) -> void:
	var Card: CardGD = CardUI.Card
	Game.onAddToDeck(Card)
	queue_free()
	taken.emit(Card)
