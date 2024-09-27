extends Control

@onready var GraveyardCards: Container = %GraveyardCards

func _ready() -> void:
	for Card in get_tree().get_nodes_in_group("GraveyardCardsGD"):
		Card.onCreateCardUI(GraveyardCards)
		Card.setInspectable(true, self)

func _on_quit_button_pressed() -> void:
	queue_free()
