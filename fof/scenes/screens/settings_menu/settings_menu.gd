extends Control
var card_positions: Array = [Vector2(1344, 200), Vector2(278, 200), Vector2(1066, 140), Vector2(406, 140), Vector2(660, 90)]
var card_scales: Array = [Vector2(0.5, 0.5), Vector2(0.5, 0.5), Vector2(0.75, 0.75), Vector2(0.75, 0.75), Vector2.ONE]
var card_order: Array = ["Audio", "Preferences", "Graphics", "Controls", "Video"]

const tween_speed: float = 0.3

var cards_are_moving: bool = false
var card_areas: Array = []

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		if !cards_are_moving:
			var i: int = 0
			for rect in card_areas:
				if rect.has_point(get_viewport().get_mouse_position()):
					on_center_selected_card(i)
					break
				i += 1
func _ready() -> void:
	var i: int = 0
	
	for child in $CardAreas.get_children().map(func(x: Area2D): return x.get_node("CollisionShape2D")):
		var rsize: Vector2 = child.shape.get_rect().size
		card_areas.append(Rect2(child.get_parent().position - rsize / 2, rsize))
	
	for card_name in card_order:
		var load_card: Control
		if i == card_order.size() - 1:
			load_card = preload("res://scenes/screens/settings_menu/front_settings_card.tscn").instantiate()
		else: 
			load_card = preload("res://scenes/screens/settings_menu/back_settings_card.tscn").instantiate()
			
		load_card.position = card_positions[i]
		load_card.scale = card_scales[i]
		
		load_card.on_load_setting_card(card_name)
		$CardSorter.add_child(load_card)
		i += 1

func on_center_selected_card(i: int) -> void:
	cards_are_moving = true
	var center_card: Control = $CardSorter.get_node(card_order[4])
	var side_card: Control = $CardSorter.get_node(card_order[i])
	
	var j: int = 0
	for k in [$CardSorter.get_node(card_order[4]), $CardSorter.get_node(card_order[i])]:
		var n: int = i if j == 0 else 4
		var scale_tween: Tween = k.create_tween()
		var move_tween: Tween = k.create_tween()
		
		scale_tween.tween_property(k, "scale", card_scales[n], tween_speed)
		move_tween.tween_property(k, "position", card_positions[n], tween_speed)
		
		
		j += 1

	center_card.get_parent().move_child(center_card, side_card.get_index())
	center_card.get_parent().move_child(side_card, 4)

	var top_value: String = card_order[4]
	card_order[4] = card_order[i]
	card_order[i] = top_value
	
