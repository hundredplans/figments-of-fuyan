extends Control

@export var card_id: int

func _ready():
	var card: Dictionary = Helper.id_to_dict(card_id, "Card")
	if !card.is_empty():
		$ArtCompile.texture = load("res://assets/base_game/cards/" + card.bgfn + "/art_pop.png")
