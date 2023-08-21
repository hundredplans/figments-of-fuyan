extends Control

var card_positions: Array = [Vector2(260, 200), Vector2(360, 140), Vector2(660, 90)]
var card_scales: Array = [0.5, 0.75, 1]
var card_order: Array = ["Audio", "Preferences", "Graphics", "Controls", "Video"]

func _ready() -> void:
	var i: int = 0
	for card_name in card_order:
		var load_card: Control
		if i == card_order.size() - 1: load_card = preload("res://scenes/screens/settings_menu/front_settings_card.tscn").instantiate()
		else: load_card = preload("res://scenes/screens/settings_menu/back_settings_card.tscn").instantiate()
		
		var ipos: int = floor(float(i) / 2)
		var right_side: int = 0
		match i:
			0: right_side = card_positions[2].x + card_positions[1].x
			2: right_side = card_positions[2].x
		load_card.position = Vector2(card_positions[ipos].x + right_side, card_positions[ipos].y)
		load_card.scale = Vector2(card_scales[ipos], card_scales[ipos])
		
		load_card.on_load_setting_card(card_name)
		$CardSorter.add_child(load_card)
		i += 1
