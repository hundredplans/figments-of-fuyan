extends Control

@onready var SearchText: LineEdit = %SearchText
@onready var CardSorter: GridContainer = %CardSorter
@onready var AreaSelector: OptionButton = %AreaSelector 
var area_id: int = 1
var search: String

func _ready(): onResetSearch()

func _on_area_selector_item_selected(index):
	area_id = int(AreaSelector.get_item_text(index))
	onResetSearch()
	
@onready var FileFinder: FileFinderGD = %FileFinder
func onResetSearch() -> void:
	for child in CardSorter.get_children(): child.queue_free()
	var base_cards: Array = FileFinder.onSearchCards(search, area_id)
	base_cards.sort_custom(func(x: Variant, y: Variant): return x.id < y.id)
	for base_card in base_cards:
		onCreateGameCard(base_card)

signal game_card_pressed
func onCreateGameCard(base_card: Resource) -> void:
	var GameCard: GameCardGD = preload("res://assets/base_game/cards/game_card/game_card.tscn").instantiate()
	
	GameCard.is_hover = true
	GameCard.pressed.connect(func(): game_card_pressed.emit(GameCard))
	GameCard.set_info(base_card)
	CardSorter.add_child(GameCard)

func _on_search_text_text_changed(new_text):
	search = new_text
	onResetSearch()
	
func setGameCardText(base_card: BaseCardGD) -> void:
	for child in CardSorter.get_children():
		if child.base_card.id == base_card.id:
			child.setText(child.base_card.text)
			break

