extends Control

const history_max_size: int = 256
const tile_size: int = 60
const tile_x_offset: int = 30
const tile_y_offset: int = 50
const tile_amount: int = 800
const tile_rows: int = 34

var keep_visibility_disabled: bool = false
var end_turn_multiplier: int = 1
var loaded_level: String
var always_reveal: bool = false
var unit_selected: Array
var multimode: bool = false
var history: Array = []
var active_card: Control
var active_cards: Array = [[], []]
var always_visible_tiles: Array = []
var always_disable_visibility: Array = []
var always_solo_visibility: Array = []

@onready var tile_default: PackedScene = preload("res://test/simulation/assets/map/tile/tile.tscn")
func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		queue_free()
		
	if Input.is_action_just_pressed("HistoryGoBack"):
		on_history_go_back()

func _ready() -> void:
	_on_load_level_button_pressed()
	theme = preload("res://test/simulation/assets/fonts/roboto32.tres")
	refresh_vision()

func create_tile() -> Node2D:
	var tile: Node2D = tile_default.instantiate()
	tile.get_node("Area2D").mouse_entered.connect(tile._on_allow_change_in_select_level)
	tile.create_unit.connect(on_create_unit)
	tile.destroy_unit.connect(on_destroy_unit)
	tile.click_unit.connect(on_click_unit)
	tile.move_unit.connect(on_move_unit)
	tile.visibility_update.connect(on_update_visibility)
	tile.disable_visible.connect(on_disable_visible)
	tile.solo_visible.connect(on_solo_visible)
	tile.change_tile_state.connect(on_tile_change_tile_state)
	tile.change_tile_item.connect(on_change_tile_item)
	tile.unit_clicked.connect(on_unit_clicked)
	return tile

func on_unit_clicked(tile: Node2D) -> void:
	match unit_selected:
		[]: on_click_unit(tile)
		_: on_move_unit(tile)

func on_change_tile_item(tile: Node2D, tile_item: String) -> void:
	match tile.get_node("In/TileItem").texture:
		null: 
			match tile_item.length():
				0: tile.get_node("In/TileItem").texture = load("res://test/simulation/assets/sprites/%s" % tile_item)
				_: tile.get_node("In/TileItem").texture = null
		_: tile.get_node("In/TileItem").texture = null

	tile = get_multi_tile(tile)
	if tile:
		match tile.get_node("In/TileItem").texture:
			null:
				match tile_item.length():
					0: tile.get_node("In/TileItem").texture = load("res://test/simulation/assets/sprites/%s" % tile_item)
					_: tile.get_node("In/TileItem").texture = null
			_: tile.get_node("In/TileItem").texture = null

func on_tile_change_tile_state(tile_info: Array, tile: Node2D) -> void:
	var tx: Texture2D = load("res://test/simulation/assets/map/tile/%s.png" % tile_info[1])
	tile.get_node("In/Inside").texture = tx
	tile._on_simulation_inside_pressed(tile_info)
	
	var multi_tile: Node2D = get_multi_tile(tile)
	if multi_tile:
		multi_tile.get_node("In/Inside").texture = tx
		multi_tile._on_simulation_inside_pressed(tile_info)
	
	refresh_vision()

func on_load_level(level_name: String) -> void:
	loaded_level = level_name
	print(loaded_level)
	for child in $CardZone.get_children():
		if child.team == 1:
			child.free()
			
	for child in $Tiles.get_children(): child.free()
	if multimode: for child in $DualTiles.get_children(): child.free()

	var x: int = 0
	var y: int = 0
	var trigger_offset: int = 0
	for i in range(tile_amount):
		var tile: Node2D = create_tile()
		var dual_tile: Node2D
		$Tiles.add_child(tile)
		if multimode:
			dual_tile = create_tile()
			$DualTiles.add_child(dual_tile)
			
		if x >= tile_rows:
			x = 0
			y += 1
			trigger_offset = 1 - trigger_offset
			
		if multimode:
			dual_tile.position.x += x * tile_size + (trigger_offset * tile_x_offset)
			dual_tile.position.y += y * tile_y_offset
			
		tile.position.x += x * tile_size + (trigger_offset * tile_x_offset)
		tile.position.y += y * tile_y_offset
		x += 1
		tile.tile_position = Vector2(x, y)
		if multimode:
			dual_tile.tile_position = Vector2(x, y)
	
	var lvl_path: String = "user://savefofle/levels/%s" % level_name
	var file := FileAccess.open(lvl_path, FileAccess.READ)
	var tiles: Array = []
	var splitter: Array = file.get_as_text().split("\n")
	var i: int = 1
	var cards: Array = []
	
	active_cards = [[], []]
	for tile_info in splitter:
		if i != splitter.size():
			var tii: Array = tile_info.split(",")
			if tii.size() >= 5:
				tiles.append([Vector2(tii[0].to_int(), tii[1].to_int()), tii[2].to_int(), tii[3], tii[4].to_int()])
				if tii.size() == 6:
					tiles[tiles.size() - 1].append(tii[5])
			i += 1
		else:
			for card_info in tile_info.split("~"):
				if card_info:
					var card_intel: Array = card_info.split("|")
					var card = on_card_selected(card_intel[0] + ".txt")
					if card:
						cards.append(card)
						if int(card_intel[1]) < 1: card._on_downscaled_pressed()
						var xy: int = 0
						if multimode: xy += 1920
						card.position = Vector2(int(card_intel[2]) + xy, int(card_intel[3]))
						card.team = int(card_intel[4])
						card.on_team_buttons_modulate()
						if card_intel.size() > 5:
							if card_intel[5]: card.get_node("AuraSelected/AuraArt").texture = load(card_intel[5])
			
	for tile_info in tiles:
		for tile in $Tiles.get_children():
			if tile.tile_position == tile_info[0]:
				tile._on_simulation_inside_pressed(tile_info)
				break
				
		if multimode:
			for tile in $DualTiles.get_children():
				if tile.tile_position == tile_info[0]:
					tile._on_simulation_inside_pressed(tile_info)
					if tile_info.size() == 5:
						for card in cards:
							var split: Array = tile_info[4].split("/")
							if split[split.size() - 1].left(-4) == card.get_node("Name").text:
								active_card = card
								on_create_unit(tile, false)
								cards.erase(card)
								break
					break
	for tile in $Tiles.get_children():
		if tile.tile_state == 0: tile.free()
		
	if multimode:
		for tile in $DualTiles.get_children():
			if tile.tile_state == 0: tile.free()
	
	active_card = null
	refresh_vision()

func _on_load_level_button_pressed():
	var loadlvl: Control = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	loadlvl.load_state = 1
	if multimode: loadlvl.position.x += 1920
	loadlvl.level_selected.connect(on_load_level)
	add_child(loadlvl)

func _on_load_cards_button_pressed():
	var loadcard: Control = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	if multimode: loadcard.position.x += 1920
	loadcard.card_selected.connect(on_card_selected)
	add_child(loadcard)

func on_card_selected(card_name: String) -> Control:
	var path: String = "user://savefofle/cards/%s" % card_name
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		var card_info: Array = file.get_as_text().split("\n")
		var card: Control = preload("res://test/simulation/screens/select_level/card.tscn").instantiate()
		card.card_path = card_name
		card.drag_drag_pressed.connect(on_art_max_selected)
		card.refresh_vision.connect(refresh_vision)
		add_card_to_card_zone(card)
		
		card.default_state = card_info.duplicate(true)
		card._on_default_state_pressed()
		refresh_vision()
		return card
	return null

func add_card_to_card_zone(card: Control) -> void:
	var x: int = 1600
	var minrange: int = 0
	if multimode: x += 1920; minrange += 1920
	card.position = Vector2(randi_range(minrange, x), randi_range(0, 700))
	$CardZone.add_child(card)

func on_art_max_selected(card_info: Array) -> void:
	if card_info[1].team == 0 and !$DualMonitorMode/ActiveArt.texture or card_info[1].team == 1 and !$ActiveArt.texture:
		active_card = card_info[1]
		if multimode:
			match card_info[1].team:
				1: $DualMonitorMode/ActiveArt.texture = load("res://test/simulation/assets/sprites/units/%s" % card_info[0])
				0: $ActiveArt.texture = load("res://test/simulation/assets/sprites/units/%s" % card_info[0])
		else: $ActiveArt.texture = load("res://test/simulation/assets/sprites/units/%s" % card_info[0])

func on_create_unit(tile: Node2D, alter_history: bool) -> void:
	active_cards[active_card.team].append([tile, active_card])
	if alter_history: add_to_history(["DESTROY", tile])
	var tx: Texture2D = load(active_card.get_node("ArtMax").texture.resource_path)
	tile.get_node("In/Unit").texture = tx
	
	var multi_tile: Node2D = get_multi_tile(tile)
	if multi_tile: multi_tile.get_node("In/Unit").texture = tx
	if keep_visibility_disabled: on_disable_visible(tile)
		
	refresh_vision()
	
	unit_selected = []
	active_card = null
	$ActiveArt.texture = null
	if multimode: $DualMonitorMode/ActiveArt.texture = null

func get_multi_tile(tile: Node2D) -> Node2D:
	if multimode:
		match tile.get_parent().name:
			"DualTiles":
				var found_tile: Array = $Tiles.get_children().filter(func(x: Node2D): return tile.tile_position == x.tile_position)
				if found_tile.size() > 0: return found_tile[0]
			"Tiles":
				var found_tile: Array = $DualTiles.get_children().filter(func(x: Node2D): return tile.tile_position == x.tile_position)
				if found_tile.size() > 0: return found_tile[0]
		
	return null

func on_destroy_unit(tile: Node2D, alter_history: bool) -> void:
	for team in active_cards:
		for i in range(team.size() - 1, -1, -1):
			if team[i][0] == tile:
				var is_always_visible: bool = false
				if tile.always_visible: 
					always_visible_tiles.erase(tile)
					tile.always_visible = false
					is_always_visible = true
					
				if tile.disable_visibility:
					always_disable_visibility.erase(tile)
					tile.disable_visibility = false
					
				if tile.solo_visibility:
					always_solo_visibility.erase(tile)
					tile.solo_visibility = false
					
				team.remove_at(i)
				tile.get_node("In/Unit").texture = null
				var multi_tile: Node2D = get_multi_tile(tile)
				if multi_tile:
					multi_tile.get_node("In/Unit").texture = null
					if is_always_visible:
						always_visible_tiles.erase(multi_tile)
						multi_tile.always_visible = false
				
				if alter_history: add_to_history(["CREATE", tile, active_card])
	refresh_vision()

func refresh_vision() -> void:
	for tile in $Tiles.get_children():
		tile.get_node("In").visible = true
		
	for tile in $DualTiles.get_children():
		tile.get_node("In").visible = true
		
	for card in $CardZone.get_children():
		card.visible = true
		
	if !always_reveal:
		var visible_tiles: Array = []
		visible_tiles += refresh_vision_for_team(0)
		visible_tiles += refresh_vision_for_team(1)
		
		for tile in $Tiles.get_children() + $DualTiles.get_children():
			tile.get_node("In").visible = false
			if tile not in visible_tiles and tile in always_visible_tiles: visible_tiles.append(tile)
			if tile.tile_state == 12: tile.get_node("In").visible = true
			if tile.tile_state == 11 and tile.get_node("In/Unit").texture: tile.get_node("In").visible = true
			
		for tile in $DualTiles.get_children():
			if tile.tile_state == 6: tile.get_node("In").visible = true
			
		for tile in $Tiles.get_children():
			if tile.tile_state == 5: tile.get_node("In").visible = true
			
		for tile in visible_tiles: tile.get_node("In").visible = true
			
func refresh_vision_for_team(team: int) -> Array:
	if team == 1 and multimode or team == 0:
		var occupied_tiles: Array = []
		var visible_tiles: Array = []
		var find_tiles_func: Callable = func(xy: Node2D, xyt: Vector2): \
		if abs(xyt.x - xy.global_position.x) == 300 and xyt.y == xy.global_position.y: return true\
		else: return sqrt(pow(xyt.x - xy.global_position.x, 2) + pow(xyt.y - xy.global_position.y, 2)) < 295
		occupied_tiles = active_cards[team].map(func(x: Array): return x[0])
			
		if always_solo_visibility.size() > 0:
			occupied_tiles = occupied_tiles.filter(func(x: Node2D): return x in always_solo_visibility)
		
		for tile in occupied_tiles:
			if is_instance_valid(tile) and tile.is_inside_tree():
				var xyt: Vector2 = tile.global_position
				if tile not in visible_tiles: visible_tiles.append(tile)
				if tile not in always_disable_visibility:
					var found_tiles: Array = []
					$Raycast.global_position = Vector2(xyt.x, xyt.y)
					match team:
						0: found_tiles = $Tiles.get_children().filter(find_tiles_func.bind(xyt))
						1: found_tiles = $DualTiles.get_children().filter(find_tiles_func.bind(xyt))
						
					for found_tile in found_tiles:
						$Raycast.target_position = Vector2(found_tile.global_position.x, found_tile.global_position.y) - $Raycast.global_position
						$Raycast.force_raycast_update()
						if found_tile not in visible_tiles:
							match $Raycast.is_colliding():
								false: visible_tiles.append(found_tile)
								true: if $Raycast.get_collider().get_parent() == found_tile: visible_tiles.append(found_tile)
					
					if found_tiles:
						$Raycast.target_position = Vector2(found_tiles[0].global_position.x, found_tiles[0].global_position.y) - $Raycast.global_position
		return visible_tiles
	return []
			
func _refresh_vision_for_team(occupied_tiles: Array) -> Array:
	var visible_tiles: Array = []
	for tile in occupied_tiles:
		if tile.is_inside_tree():
			var xyt: Vector2 = tile.global_position
			var poses: Array = [xyt]
			for hk in poses:
				if tile not in visible_tiles: visible_tiles.append(tile)
				var found_tiles: Array = $Tiles.get_children().filter(func(xy: Node2D): \
				if abs(hk.x - xy.global_position.x) == 300 and hk.y == xy.global_position.y: return true\
				else: return sqrt(pow(hk.x - xy.global_position.x, 2) + pow(hk.y - xy.global_position.y, 2)) < 295)
				$Raycast.global_position = Vector2(hk.x, hk.y)
				for found_tile in found_tiles:
					$Raycast.target_position = Vector2(found_tile.global_position.x, found_tile.global_position.y) - $Raycast.global_position
					$Raycast.force_raycast_update()
					if found_tile not in visible_tiles:
						match $Raycast.is_colliding():
							false: visible_tiles.append(found_tile)
							true: if $Raycast.get_collider().get_parent() == found_tile: visible_tiles.append(found_tile)
					
				$Raycast.target_position = Vector2(found_tiles[0].global_position.x, found_tiles[0].global_position.y) - $Raycast.global_position
		
	return visible_tiles

func on_click_unit(tile: Node2D):
	for team in active_cards:
		for i in team:
			if i[0] == tile and i[1] != null:
				unit_selected = [i[1], tile]
				active_card = null
				var texture: Texture2D = load(i[1].get_node("ArtMax").texture.resource_path)
				if multimode: 
					match i[1].team:
						1: $DualMonitorMode/ActiveArt.texture = texture
						0: $ActiveArt.texture = texture
				else:
					$ActiveArt.texture = texture
				return

func on_move_unit(tile: Node2D):
	if unit_selected[0] != null:
		active_card = unit_selected[0]
		if unit_selected[1].always_visible: tile.always_visible = true; always_visible_tiles.append(tile)
		var multi_tile: Node2D = get_multi_tile(tile)
		if multi_tile:
			if unit_selected[1].always_visible:
				multi_tile.always_visible = true
				always_visible_tiles.append(multi_tile)
		on_destroy_unit(unit_selected[1], true)
		on_create_unit(tile, true)

func _on_draw_cards_pressed():
	var draw_cards: Control = preload("res://test/simulation/screens/select_level/draw_cards.tscn").instantiate()
	if multimode: draw_cards.position.x += 1920
	add_child(draw_cards)
	
func on_history_go_back():
	if history.size() > 0:
		var hisinfo: Array = history.pop_back()
		match hisinfo[0]:
			"CREATE": 
				active_card = hisinfo[2]
				on_create_unit(hisinfo[1], false)
				
			"DESTROY": on_destroy_unit(hisinfo[1], false)
	
func add_to_history(hisinfo: Array) -> void:
	if history.size() > history_max_size: history.remove_at(0)
	history.append(hisinfo)

func _on_dual_monitor_mode_pressed():
	add_child(preload("res://test/simulation/screens/select_level/dual_monitor_mode.tscn").instantiate())
	multimode = true
	
	if loaded_level: on_load_level(loaded_level)
	else: _on_load_level_button_pressed()

func on_solo_visible(tile: Node2D):
	tile.solo_visibility = !tile.solo_visibility
	if tile not in always_solo_visibility: always_solo_visibility.append(tile)
	else: always_solo_visibility.erase(tile)
	refresh_vision()

func on_disable_visible(tile: Node2D):
	tile.disable_visibility = !tile.disable_visibility
	if tile not in always_disable_visibility: always_disable_visibility.append(tile)
	else: always_disable_visibility.erase(tile)
	
	var multi_tile: Node2D = get_multi_tile(tile)
	if multi_tile:
		multi_tile.disable_visibility = !multi_tile.disable_visibility
		if multi_tile not in always_disable_visibility: always_disable_visibility.append(multi_tile)
		else: always_disable_visibility.erase(multi_tile)
	
	refresh_vision()

func on_update_visibility(tile: Node2D):
	tile.always_visible = !tile.always_visible
	if tile not in always_visible_tiles: always_visible_tiles.append(tile)
	else: always_visible_tiles.erase(tile)
		
	var multi_tile: Node2D = get_multi_tile(tile)
	if multi_tile:
		multi_tile.always_visible = tile.always_visible
		if multi_tile not in always_visible_tiles: always_visible_tiles.append(multi_tile)
		else: always_visible_tiles.erase(multi_tile)
	
	refresh_vision()

func _on_number_generator_pressed():
	var number_generator: Control = preload("res://test/simulation/screens/select_level/number_generator.tscn").instantiate()
	number_generator.position = Vector2(1200, 700)
	add_child(number_generator)

func _on_shop_generator_pressed():
	var shop_generator: Control = preload("res://test/simulation/screens/select_level/shop_generator.tscn").instantiate()
	shop_generator.position = Vector2(500, 500)
	add_child(shop_generator)

func _on_add_boons_pressed():
	var loadcard: Control = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	loadcard.boon_selected.connect(on_boon_selected)
	loadcard.load_state = 3
	add_child(loadcard)

func on_boon_selected(boon_path: String) -> void:
	var file := FileAccess.open("user://savefofle/loaded_boons.txt", FileAccess.READ_WRITE)
	var text: String = file.get_as_text()
	if boon_path not in text.split("\n", false):
		file.store_string(text + boon_path + "\n")
	file = null

func _on_inventory_pressed():
	add_child(preload("res://test/simulation/screens/select_level/inventory.tscn").instantiate())

func _on_reveal_all_pressed(): 
	always_reveal = !always_reveal
	refresh_vision()

func _on_end_turn_pressed():
	$EndTurn.position.x += ($EndTurn.size.x) * end_turn_multiplier
	end_turn_multiplier *= -1

func _on_utility_menu_pressed():
	if !has_node("UtilityMenu"):
		var utility_menu: Control = preload("res://test/simulation/screens/select_level/utility_menu.tscn").instantiate()
		add_child(utility_menu)
		utility_menu.position = $Buttons/UtilityMenu.position + Vector2(-100, -150)
	else:
		get_node("UtilityMenu/UtilityPressed").play("utility_pressed_end")

func on_create_shop_pressed() -> void:
	var create_shop: Control = preload("res://test/simulation/screens/select_level/create_shop.tscn").instantiate()
	create_shop.position = Vector2(400, 176)
	add_child(create_shop)
