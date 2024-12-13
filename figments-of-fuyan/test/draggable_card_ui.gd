extends Control

func _ready():
	var parent := Node3D.new()
	add_child(parent)
	var card_data := SavedDataCard.new(3, true)
	Game.setCardDataFromInfo(card_data, Helper.getFofInfoID(CardInfo, card_data.id))
	var Card: CardGD = SavedData.onLoadModel(card_data, parent)
	var CardUI: Control = Card.onCreateCardUI(self, true, true, self)
	CardUI.position = Vector2(200, 200)
