extends Control

@onready var GraveyardAllies: Container = %GraveyardAllies
@onready var GraveyardEnemies: Container = %GraveyardEnemies

func _ready() -> void:
	for Card in get_tree().get_nodes_in_group("GraveyardCardsGD"):
		Card.onCreateCardUI(GraveyardAllies if Card.isAlly(0) else GraveyardEnemies)
		Card.setInspectable(true, self)

func _on_quit_button_pressed() -> void:
	queue_free()
