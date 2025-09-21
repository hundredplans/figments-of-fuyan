extends Control

var Card: CardGD
var CardUI: TbcUI

func setInfo(_Card: CardGD, disabled: bool) -> void:
	Card = _Card
	CardUI = Card.onCreateCardUI(self, true, true, true, false)
	setDisabled(disabled)

func setDisabled(state: bool) -> void:
	CardUI.setDisabled(state)

func getCard() -> CardGD: return Card
func getCardUI() -> TbcUI: return CardUI
