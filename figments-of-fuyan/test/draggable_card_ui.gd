extends Control

func _ready():
	for i in range(3, 5):
		var parent := Node3D.new()
		var card_data := SavedDataCard.new(i, true)
		Game.setCardDataFromInfo(card_data, Helper.getFofInfoID(CardInfo, card_data.id))
		var Card: CardGD = SavedData.onLoadModel(card_data, parent)
		var CardUI: Control = Card.onCreateCardUI(%Cont, true, true, true)
	
