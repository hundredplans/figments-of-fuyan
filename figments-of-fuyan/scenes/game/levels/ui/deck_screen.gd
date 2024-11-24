extends Control

signal selected
@onready var DeckCards: Container = %DeckCards

var SelectedCardUI: Control
var selectable: bool
func setInfo(_selectable: bool = false) -> void:
	selectable = _selectable
	for Card in get_tree().get_nodes_in_group("DeckCardsGD"):
		var CardUI: Control = Card.onCreateCardUI(DeckCards, selectable)
		Card.setInspectable(true, self)
		if selectable: CardUI.pressed.connect(onSelected)

func _on_quit_button_pressed() -> void:
	queue_free()
	
func onSelected(CardUI: Control) -> void:
	SelectedCardUI = CardUI
	selected.emit(CardUI.Card)
	queue_free()

func onDisableCards(filter: Callable) -> void:
	for child in DeckCards.get_children().filter(filter):
		child.setDisabled(true)
