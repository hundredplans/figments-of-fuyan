extends Control

var CardDisplayed: GameCardGD
func onDisplayCard(GameCard: GameCardGD) -> void:
	GameCard.scale = Vector2(2, 2)
	GameCard.is_hover = false
	
	if CardDisplayed != null: CardDisplayed.queue_free()
	CardDisplayed = GameCard
	
	add_child(GameCard)
	GameCard.position += Vector2(30, -10)
