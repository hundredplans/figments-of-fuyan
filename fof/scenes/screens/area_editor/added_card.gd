extends Control
signal remove_card

func _on_remove_card_pressed(): remove_card.emit()
func change_art(bgfn: String) -> void:
	var texture_path: String = "res://assets/base_game/cards/card/default_art_max.png"
	var card_texture_path: String = "res://assets/base_game/cards/" + bgfn + "/art_max.png"
	if FileAccess.file_exists(card_texture_path):
		texture_path = card_texture_path
	$ArtMax.texture = load(texture_path)
