extends Control
var card_positions: Array = [Vector2(1344, 200), Vector2(278, 200), Vector2(1066, 140), Vector2(406, 140), Vector2(660, 90)]
var card_scales: Array = [Vector2(0.5, 0.5), Vector2(0.5, 0.5), Vector2(0.75, 0.75), Vector2(0.75, 0.75), Vector2.ONE]
var card_order: Array = ["Audio", "Preferences", "Graphics", "Controls", "Video"]

const tween_speed: float = 0.4
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
	for child in $CardAreas.get_children().map(func(x: Area2D): return x.get_node("CollisionShape2D")):
		var rsize: Vector2 = child.shape.get_rect().size
		card_areas.append(Rect2(child.get_parent().position - rsize / 2, rsize))
	
	var directions: Array = ["left", "right"]
	var i: int = 0
	for card_name in card_order:
		var direction: int = 0 if i in [1,3] else 1
		var settings_card: Control = preload("res://scenes/screens/settings_menu/settings_card.tscn").instantiate()
		settings_card.position = card_positions[i]
		settings_card.scale = card_scales[i]
		$CardSorter.add_child(settings_card)
		settings_card.on_load_setting_card(card_name)
		settings_card.get_parent().move_child(settings_card, i)
		settings_card.z_index = i
		
		var animation: Animation = settings_card.get_node("MoveCard").get_animation("move_card_" + directions[direction])
		if i < 4:
			settings_card.get_node("Settings").rotation = animation.track_get_key_value(1, 0)
			settings_card.get_node("Settings").position = animation.track_get_key_value(2, 0)
		else:
			settings_card.on_load_front_card()
			settings_card.get_node("Background").texture = preload("res://scenes/screens/settings_menu/settings_assets/front0.png")
			settings_card.get_node("Settings").rotation = animation.track_get_key_value(1, animation.track_get_key_count(1) - 1)
			settings_card.get_node("Settings").position = animation.track_get_key_value(2, animation.track_get_key_count(2) - 1)
		i += 1
	

func on_center_selected_card(i: int) -> void:
	if i < 4:
		cards_are_moving = true
		var directions: Array = ["left", "right"]
		var direction: int = 0 if i in [1,3] else 1
		
		var center_card: Control = get_card(card_order[4])
		var side_card: Control = get_card(card_order[i])
		
		center_card.get_parent().move_child(center_card, i)
		side_card.get_parent().move_child(side_card, 4)
		center_card.z_index = i
		side_card.z_index = 4
		
		var length: float = side_card.get_node("MoveCard").get_animation("move_card_left").length
		var scales: Array = [card_scales[i], card_scales[4]]
		var positions: Array = [card_positions[i], card_positions[4]]
		var j: int = 0
		
		for card in [center_card, side_card]:
			var method: Callable = card.on_load_front_card if j == 1 else card.on_load_back_card
			match j:
				0: card.get_node("MoveCard").play_backwards("move_card_" + directions[direction])
				1: card.get_node("MoveCard").play("move_card_" + directions[direction])
			
			var tweens: Array = [card.create_tween(), card.create_tween(), card.create_tween(), card.create_tween()]
			tweens[0].tween_property(card, "scale", scales[j], length)
			tweens[1].tween_property(card, "position", positions[j], length)
			tweens[2].tween_callback(func(): cards_are_moving = false).set_delay(tween_speed + 0.02)
			tweens[3].tween_callback(method).set_delay(tween_speed / 2)
			j += 1
		
		var top_value: String = card_order[4]
		card_order[4] = card_order[i]
		card_order[i] = top_value
		AudioMaster.play_sfx(load("res://assets/sounds/animations/settings_menu/card_flip.wav"))

func get_card(setting: String) -> Control:
	for child in $CardSorter.get_children(): if setting == child.setting: return child
	return null
