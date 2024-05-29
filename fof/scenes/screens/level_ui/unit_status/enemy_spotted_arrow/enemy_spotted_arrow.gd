extends Control

func setInfo(Unit: UnitGD) -> void:
	$ArtMini.texture = load("res://assets/base_game/cards/cards/" + Unit.base_card.folder_name + "/art_mini.png")
