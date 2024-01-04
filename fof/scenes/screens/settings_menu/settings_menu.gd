extends Control
var card_positions: Array = [Vector2(1344, 200), Vector2(278, 200), Vector2(1066, 140), Vector2(406, 140), Vector2(660, 90)]
var card_scales: Array = [Vector2(0.5, 0.5), Vector2(0.5, 0.5), Vector2(0.75, 0.75), Vector2(0.75, 0.75), Vector2.ONE]
var card_order: Array = Helper.return_file_contents("user://save/settings/settings_order.txt").split("\n", false)
var cards_are_moving: bool = false
var card_areas: Array = []

func _queue_free() -> void:
	var contents: String = "%s\n%s\n%s\n%s\n%s" % $CardSorter.get_children().map(func(x: Control): return x.name)
	Helper.write_to_file("user://save/settings/", "settings_order", ".txt", contents)
	Helper.settings_loaded = false
				
func _ready() -> void:
	Helper.settings_loaded = true
	for child in $CardAreas.get_children():
		var rsize: Vector2 = child.get_rect().size
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
		settings_card.get_node("Settings/UtilityMenu/ResetButton").pressed.connect(on_reset_button_pressed.bind(card_name))
		
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
			settings_card.get_node("Settings/UtilityMenu").visible = true
		i += 1

func on_center_selected_card(i: int) -> void:
	if i < 4 and !cards_are_moving:
		cards_are_moving = true
		var directions: Array = ["left", "right"]
		var direction: int = 0 if i in [1,3] else 1
		
		var center_card: Control = get_card(card_order[4])
		var side_card: Control = get_card(card_order[i])
		
		var length: float = side_card.get_node("MoveCard").get_animation("move_card_left").length
		var extra_length: float = (length * 0.5) if i in [0, 1] else 0.0
		length += extra_length
		
		var between_card: Control
		if extra_length > 0:
			between_card = get_card(card_order[i + 2])
			between_card.z_index = 3
			var tween: Tween = between_card.create_tween()
			tween.tween_callback(func(): between_card.z_index = i + 2).set_delay(length)
		
		var scales: Array = [card_scales[i], card_scales[4]]
		var positions: Array = [card_positions[i], card_positions[4]]
		var j: int = 0
		
		side_card.get_node("Settings/UtilityMenu").visible = true
		center_card.get_node("Settings/UtilityMenu").visible = false
		
		for card in [center_card, side_card]:
			var move_child_position: Array = [i, 4]
			var methods: Array = [card.on_load_back_card, card.on_load_front_card]
			card.get_node("MoveCard").speed_scale = 0.75 if extra_length > 0 else 1.0
			
			match j:
				0: card.get_node("MoveCard").play_backwards("move_card_" + directions[direction])
				1: card.get_node("MoveCard").play("move_card_" + directions[direction])
			
			var tweens: Array = [card.create_tween(), card.create_tween(), card.create_tween(), card.create_tween()]
			tweens[0].tween_property(card, "scale", scales[j], length)
			tweens[1].tween_property(card, "position", positions[j], length)
			tweens[2].tween_callback(on_card_finished_moving.bind(card, move_child_position[j])).set_delay(length + 0.02)
			tweens[3].tween_callback(on_card_move_halfway.bind(methods[j], card, move_child_position[j])).set_delay(length * 0.5)
			j += 1
		
		var top_value: String = card_order[4]
		card_order[4] = card_order[i]
		card_order[i] = top_value
		AudioMaster.play_sfx("page_flip")

func on_card_move_halfway(method: Callable, card: Control, i: int) -> void:
	method.call()
	card.z_index = i

func on_card_finished_moving(card: Control, i: int) -> void:
	cards_are_moving = false
	card.get_parent().move_child(card, i)

func get_card(setting: String) -> Control:
	for child in $CardSorter.get_children(): if setting == child.setting: return child
	return null

func on_reset_button_pressed(card_name: String) -> void:
	var data: String = Helper.return_file_contents("user://save/settings/default/" + card_name + ".txt")
	if data:
		Helper.write_to_file("user://save/settings/current/", card_name, ".txt", data, false)
		
		Settings.on_trigger_setting(card_name + ".txt")
		var card: Control = get_card(card_name)
		
		var loaded_new_card: Control = load("res://scenes/screens/settings_menu/setting_options/settings_" + card_name.to_lower() + ".tscn").instantiate()
		loaded_new_card.setting = card_name
		var old_loaded_card: Control = card.get_node("Settings/LoadedSetting/Settings" + card_name)
		
		var nodes: Array = Helper.flatten(old_loaded_card.get_children()\
		.map(func(x: Control): return x.get_children()), false)
		
		for info in Settings.settings_info[card_name]:
			for node in nodes:
				if node.name == info[0]:
					node.default = info[1]
					
		old_loaded_card.free()
		card.get_node("Settings/LoadedSetting").add_child(loaded_new_card)
		card.on_reload_page(0)
