extends Control

@onready var DeckCards: Container = %DeckCards

func _ready() -> void:
	for Card in get_tree().get_nodes_in_group("DeckCardsGD"):
		Card.onCreateCardUI(DeckCards)
		Card.setInspectable(true, self)

func _on_quit_button_pressed() -> void:
	queue_free()
