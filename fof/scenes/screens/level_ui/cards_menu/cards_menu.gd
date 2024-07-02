extends Control

var graveyard_cards: Array
var deck_cards: Array
@onready var DeckButton: Button = %DeckButton
@onready var GraveyardButton: Button = %GraveyardButton
@onready var CardsHolder: GridContainer = %CardsHolder

func setInfo(_graveyard_cards: Array, _deck_cards: Array) -> void:
	graveyard_cards = _graveyard_cards
	deck_cards = _deck_cards

func _on_exit_button_pressed():
	queue_free()

func onLoadGraveyard() -> void:
	GraveyardButton.disabled = true
	DeckButton.disabled = false
	
	for child in CardsHolder.get_children(): child.queue_free()
	for base_card in graveyard_cards:
		var GameCard: GameCardGD = preload("res://assets/base_game/cards/game_card/game_card.tscn").instantiate()
		GameCard.set_info(base_card)
		CardsHolder.add_child(GameCard)
		
	
func onLoadDeck() -> void:
	DeckButton.disabled = true
	GraveyardButton.disabled = false
	
	for child in CardsHolder.get_children(): child.queue_free()
	for deck_card in deck_cards:
		var GameCard: GameCardGD = preload("res://assets/base_game/cards/game_card/game_card.tscn").instantiate()
		GameCard.set_info(Helper.getCard(deck_card.id))
		CardsHolder.add_child(GameCard)
	
	
