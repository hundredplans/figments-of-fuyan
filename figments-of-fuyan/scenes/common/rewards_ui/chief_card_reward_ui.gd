extends Control

signal pressed
const CARD_UI_POSITION := Vector2(197, 314)
var CardUI: Control
var taken: bool

func setInfo(Card: CardGD, taken: bool) -> void:
	CardUI = Card.onCreateCardUI(self, true)
	CardUI.scale = Vector2(2, 2)
	CardUI.position = CARD_UI_POSITION
	CardUI.pressed.connect(onCardUIPressed)
	setTaken(taken)

func onCardUIPressed(CardUI: Control) -> void:
	pressed.emit(CardUI.Card)

func setTaken(_taken: bool) -> void:
	taken = _taken
	CardUI.setDisabled(taken)
