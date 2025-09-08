extends Control

signal selected
@onready var DeckCards: Container = %DeckCards

var max_select_amount: int
var selected_cards: Array
var selectable: bool
var valid_selection: Callable # Used when you have to choose more than one card

var SelectedCardUI: Control

func setInfo(_selectable: bool = false, _max_select_amount: int = 1, _valid_selection := Callable()) -> void:
	selectable = _selectable
	max_select_amount = _max_select_amount
	valid_selection = _valid_selection
	for Card: CardGD in get_tree().get_nodes_in_group("DeckCardsGD"):
		var CardUI: Control = Card.onCreateCardUI(DeckCards, selectable, false, false, true)
		if selectable: CardUI.pressed.connect(onSelected)

func _on_quit_button_pressed() -> void:
	queue_free()
	
func onSelected(CardUI: Control) -> void:
	if CardUI.Card in selected_cards:
		selected_cards.erase(CardUI.Card)
		CardUI.onSelected(false)
	else:
		selected_cards.append(CardUI.Card)
		CardUI.onSelected(true)
	
	if !selected_cards.is_empty() and selected_cards.size() == max_select_amount \
	and (max_select_amount == 1 or (valid_selection == Callable() or valid_selection.call(selected_cards))):
		SelectedCardUI = CardUI
		selected.emit(selected_cards[0] if max_select_amount == 1 else selected_cards)
		queue_free()

func onDisableCards(filter: Callable) -> void:
	if filter == Callable(): return
	for child in DeckCards.get_children().filter(filter):
		child.setDisabled(true)
