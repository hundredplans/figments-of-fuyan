extends Control

var Card: CardGD
var CardUI: TbcUI

func setInfo(_Card: CardGD, is_start: bool) -> void:
	Card = _Card
	CardUI = Card.onCreateCardUI(self, !is_start, !is_start, !is_start, false)

func getCard() -> CardGD: return Card
func getCardUI() -> TbcUI: return CardUI
