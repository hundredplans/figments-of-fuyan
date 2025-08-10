class_name DeckSlot extends Resource

@export var card_public_id: int
@export var is_locked: bool

func isUsed() -> bool:
	return is_locked or card_public_id > 0
	
func isCardUsed() -> bool:
	return card_public_id > 0

func onAddCard(Card: CardGD) -> void:
	if card_public_id > 0:
		onRemoveCard()
	
	card_public_id = Card.public_id
	Card.onChangeCardPlace(Game.CardPlaces.DECK)
	is_locked = false
	
func getCardData() -> SavedDataCard:
	if card_public_id == 0: return null
	var Card: CardGD = Game.onFindPublicIDObject(card_public_id)
	if Card == null: return null
	
	return Card.onSave()

func onRemoveCard(send_to_stash: bool = true) -> void:
	var Card: CardGD = Game.onFindPublicIDObject(card_public_id)
	card_public_id = 0
	is_locked = false
	
	if send_to_stash: Card.onChangeCardPlace(Game.CardPlaces.STASH)
	else: Card.onClear()
		
	
func getCard() -> CardGD:
	if card_public_id == 0: return null
	var Card: CardGD = Game.onFindPublicIDObject(card_public_id)
	return Card
