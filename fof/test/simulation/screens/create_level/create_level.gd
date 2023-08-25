extends Control

var no_paint: bool = false
var nono_zone: int = 0
var active_arrow_state: int = 0
var active_tile_state: int = 0
var active_tile_item: String
const tile_size: int = 60
const tile_x_offset: int = 30
const tile_y_offset: int = 50
var touched_tiles: Array = []

var current_page: int = 0
var max_page: int = 0
var max_cards_on_page: int = 6
var all_cards: Array
const tile_amount: int = 800
const tile_rows: int = 34
@onready var tile_default: PackedScene = preload("res://test/simulation/assets/map/tile/tile.tscn")

func _ready():
	theme = preload("res://test/simulation/assets/fonts/roboto32.tres")
	var x: int = 0
	var y: int = 0
	var trigger_offset: int = 0
	for i in range(tile_amount):
		var tile: Node2D = tile_default.instantiate()
		$FakeTiles.add_child(tile)
		tile.get_node("Area2D").mouse_entered.connect(tile._on_area_2d_mouse_entered)
		if x >= tile_rows:
			x = 0
			y += 1
			trigger_offset = 1 - trigger_offset
			
		tile.position.x += x * tile_size + (trigger_offset * tile_x_offset)
		tile.position.y += y * tile_y_offset
		x += 1
		tile.tile_position = Vector2(x, y)
	
	var file_names: PackedStringArray = DirAccess.open("res://test/simulation/assets/trinkets").get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".import"))
	for file in file_names:
		all_cards.append(file.replace(".import", ""))
	
	max_page = ceil(float(file_names.size()) / max_cards_on_page) - 1
	on_load_cards()
	
func on_load_cards():
	for child in $AddItem/Sprites.get_children(): child.free()
	for i in range(current_page * max_cards_on_page, (current_page + 1) * max_cards_on_page):
		if i < all_cards.size():
			var sprite := TextureButton.new()
			sprite.texture_normal = load("res://test/simulation/assets/trinkets/%s" % all_cards[i])
			$AddItem/Sprites.add_child(sprite)
			sprite.pressed.connect(on_art_max_pressed.bind(all_cards[i]))
		
	var y: int = 0
	for child in $AddItem/Sprites.get_children():
		child.position.y += y
		y += 140
		
func on_art_max_pressed(item_name: String):
	active_tile_item = item_name
	$AddItem/ClearSelection.modulate = Color(1,0,0,1)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		queue_free()
		
	if Input.is_action_just_released("LeftClick"): touched_tiles.clear()

	if Input.is_action_pressed("RightClick"):
		on_choose_tile_settings()
		
	if Input.is_action_just_released("RightClick"):
		if has_node("ChooseTileSettings"):
			get_node("ChooseTileSettings").queue_free()
			
	if Input.is_action_just_pressed("Fill"):
		on_fill_tiles()

func on_fill_tiles():
	var fill_tile: Node2D
	
	for child in $FakeTiles.get_children():
		if Geometry2D.is_point_in_polygon(child.global_position - get_viewport().get_mouse_position(), child.get_node("Area2D/CollisionPolygon2D").polygon):
			fill_tile = child
			break
			
	if fill_tile:
		$Raycast.position = fill_tile.global_position
		for child in $FakeTiles.get_children():
			if child.tile_state != fill_tile.tile_state:
				child.get_node("Area2D").collision_layer = 8
			
		for child in $FakeTiles.get_children():
			$Raycast.target_position = child.global_position - $Raycast.position
			$Raycast.force_raycast_update()
			if !$Raycast.is_colliding():
				child.tile_state = active_tile_state
				child.get_node("In/Inside").texture = load("res://test/simulation/assets/map/tile/%s.png" % child.tile_state)

		for child in $FakeTiles.get_children():
			child.get_node("Area2D").collision_layer = 1
			
func on_choose_tile_settings():
	if !has_node("ChooseTileSettings"):
		var choose_tile_settings: Node2D = preload("res://test/simulation/screens/create_level/choose_tile_settings.tscn").instantiate()
		add_child(choose_tile_settings)
		choose_tile_settings.position = get_viewport().get_mouse_position()

func _on_clear_tiles_pressed():
	active_tile_state = 0
	active_arrow_state = 0
	nono_zone = 0
	_on_clear_selection_pressed()
	for tile in $FakeTiles.get_children():
		tile._on_level_editor_inside_pressed()

func _on_down_pressed():
	if current_page > 0:
		current_page -= 1
		on_load_cards()

func _on_up_pressed():
	if current_page < max_page:
		current_page += 1
		on_load_cards()

func _on_clear_selection_pressed():
	active_tile_item = ""
	$AddItem/ClearSelection.modulate = Color(1,1,1,1)

func _on_load_level_pressed():
	active_tile_state = 0
	active_arrow_state = 0
	var levelloader = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	levelloader.load_state = 1
	add_child(levelloader)
	levelloader.level_selected.connect(on_load_level)
	levelloader.tree_exited.connect(func(): nono_zone = 0)
	nono_zone = 2
	
func on_load_level(level_name: String) -> void:
	$WorldName.text = level_name.left(-4)
	for child in $CardZone.get_children(): child.free()
	_on_clear_tiles_pressed()
	var lvl_path: String = "user://savefofle/levels/%s" % level_name
	var file := FileAccess.open(lvl_path, FileAccess.READ)
	var tiles: Array = []
	var splitter: Array = file.get_as_text().split("\n")
	var i: int = 1
	for tile_info in splitter:
		if i != splitter.size():
			var tii: Array = tile_info.split(",")
			if tii.size() == 5:
				tiles.append([Vector2(tii[0].to_int(), tii[1].to_int()), tii[2].to_int(), tii[3], tii[4].to_int()])
			i += 1
		else:
			for card_info in tile_info.split("~"):
				if card_info:
					var card_intel: Array = card_info.split("|")
					var card = on_card_selected(card_intel[0] + ".txt")
					if card:
						if int(card_intel[1]) < 1: card._on_downscaled_pressed()
						card.global_position = Vector2(int(card_intel[2]), int(card_intel[3]))
						card.team = int(card_intel[4])
						card.on_team_buttons_modulate()
						if card_intel[5]: card.get_node("AuraSelected/AuraArt").texture = load(card_intel[5])
			
	for tile_info in tiles:
		active_tile_state = tile_info[1]
		active_tile_item = tile_info[2]
		active_arrow_state = tile_info[3]
		for tile in $FakeTiles.get_children():
			if tile.tile_position == tile_info[0]:
				tile._on_level_editor_inside_pressed()
	
	active_arrow_state = 0
	active_tile_state = 4
	_on_clear_selection_pressed()
	file = null
	
func _on_save_level_button_text_submitted(text: String):
	if !(FileAccess.file_exists("user://savefofle/levels/%s.txt" % text)): save_level(text)
	else:
		var confirm_deletion_node: Control = preload("res://test/simulation/screens/load_stuff/confirm_deletion.tscn").instantiate()
		add_child(confirm_deletion_node)
		nono_zone = 2
		for child in confirm_deletion_node.get_node("Buttons").get_children():
			match child.name:
				"Yes": child.pressed.connect(save_level.bind(text)); child.pressed.connect(func(): confirm_deletion_node.queue_free(); nono_zone = 0)
				"No": child.pressed.connect(func(): confirm_deletion_node.queue_free(); nono_zone = 0)

func save_level(text: String) -> void:
	var file := FileAccess.open("user://savefofle/levels/%s.txt" % text, FileAccess.WRITE)
	var write_string: String = ""
	var card_names: Array = $CardZone.get_children()
	for tile in $FakeTiles.get_children():
		if tile.tile_state != 0:
			write_string += "%s,%s,%s,%s,%s\n" % [tile.tile_position.x, tile.tile_position.y, tile.tile_state, tile.tile_item, tile.arrow_state]
			
	for child in card_names:
		var aura_resource_path: String
		if child.get_node("AuraSelected/AuraArt").texture: aura_resource_path = child.get_node("AuraSelected/AuraArt").texture.resource_path
		write_string += "%s|%s|%s|%s|%s|%s~" % [child.card_path.left(-4), child.scale.x, child.global_position.x, child.global_position.y, child.team, aura_resource_path]
	
	file.store_string(write_string)
	file = null
func _on_nono_zone_mouse_entered(): if nono_zone == 0: nono_zone = 1
func _on_nono_zone_mouse_exited(): if nono_zone == 1: nono_zone = 0
func _on_load_card_pressed():
	var loadcard: Control = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	add_child(loadcard)
	loadcard.card_selected.connect(on_card_selected)
	loadcard.tree_exited.connect(func(): nono_zone = 0)
	nono_zone = 2
	
func on_card_selected(card_name: String) -> Control:
	var path: String = "user://savefofle/cards/%s" % card_name
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		var card_info: Array = file.get_as_text().split("\n")
		var card: Control = preload("res://test/simulation/screens/select_level/card.tscn").instantiate()
		card.card_path = card_name
		card.default_state = card_info.duplicate(true)
		var area: Area2D = preload("res://test/simulation/screens/create_level/mouse_blocker.tscn").instantiate()
		area.mouse_entered.connect(func(): nono_zone = 2)
		area.mouse_exited.connect(func(): nono_zone = 0)
		card.tree_exited.connect(func(): nono_zone = 0)
		card.add_child(area)
		card._on_default_state_pressed()
		card.on_team_buttons_modulate()
		add_card_to_card_zone(card)
		card.get_node("DragZone").mouse_entered.connect(_on_nono_zone_mouse_entered)
		card.get_node("DragZone").mouse_exited.connect(_on_nono_zone_mouse_exited)
		return card
	return null
	
func add_card_to_card_zone(card: Control) -> void:
	card.position = Vector2(randi_range(0, 1600), randi_range(0, 800))
	$CardZone.add_child(card)

func _on_no_paint_pressed(): 
	no_paint = !no_paint
	match no_paint:
		true: $NoPaint.modulate = Color(1,0,0,1)
		false: $NoPaint.modulate = Color(1,1,1,1)
