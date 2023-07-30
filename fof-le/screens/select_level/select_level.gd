extends Node2D

const tile_size: int = 60
const tile_x_offset: int = 30
const tile_y_offset: int = 50
const tile_amount: int = 588
const tile_rows: int = 28
const vision_range: int = 1
const circle_vision_range: int = 240

var active_card: Control
var active_cards: Array = [[], []]
var move_unit: Array = []

var enable_vision_team_zero: bool = false
var enable_vision_team_one: bool = false

@onready var tile_default: PackedScene = preload("res://assets/map/tile/tile.tscn")
func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		queue_free()

func _ready() -> void:
	refresh_vision()
	modulate_team_buttons()
	$LoadLevel.load_level.connect(on_load_level)

func on_load_level(level_name: String) -> void:
	for child in $Tiles.get_children(): 
		child.free()

	var x: int = 0
	var y: int = 0
	var trigger_offset: int = 0
	for i in range(tile_amount):
		var tile: Node2D = tile_default.instantiate()
		$Tiles.add_child(tile)
		tile.get_node("Area2D").mouse_entered.connect(tile._on_allow_change_in_level_editor)
		tile.create_unit.connect(on_create_unit)
		tile.destroy_unit.connect(on_destroy_unit)
		tile.click_unit.connect(on_click_unit)
		tile.move_unit.connect(on_move_unit)
		if x >= tile_rows:
			x = 0
			y += 1
			trigger_offset = 1 - trigger_offset
			
		tile.position.x += x * tile_size + (trigger_offset * tile_x_offset)
		tile.position.y += y * tile_y_offset
		x += 1
		tile.tile_position = Vector2(x, y)
	
	var lvl_path: String = "user://save/levels/%s" % level_name
	var file := FileAccess.open(lvl_path, FileAccess.READ)
	var tiles: Array = []
	for tile_info in file.get_as_text().split("\n"):
		var tii: Array = tile_info.split(",")
		if tii.size() == 5:
			tiles.append([Vector2(tii[0].to_int(), tii[1].to_int()), tii[2].to_int(), tii[3], tii[4].to_int()])
			
	for tile_info in tiles:
		for tile in $Tiles.get_children():
			if tile.tile_position == tile_info[0]:
				tile._on_simulation_inside_pressed(tile_info)
				
	for tile in $Tiles.get_children():
		if tile.tile_state == 0: tile.queue_free()

	active_cards = [[], []]
	refresh_vision()

func _on_load_level_button_pressed():
	var loadlvl: Node2D = preload("res://screens/create_level/load_level.tscn").instantiate()
	loadlvl.load_level.connect(on_load_level)
	add_child(loadlvl)

func _on_load_cards_button_pressed():
	var loadcard: Node2D = preload("res://screens/card_creator/load_card.tscn").instantiate()
	loadcard.card_selected.connect(on_card_selected)
	add_child(loadcard)

func on_card_selected(card_name: String):
	var file := FileAccess.open("user://save/cards/%s" % card_name, FileAccess.READ)
	var card_info: Array = file.get_as_text().split("\n")
	var card: Control = preload("res://screens/select_level/card.tscn").instantiate()
	card.get_node("DragDrag").pressed.connect(on_art_max_selected.bind([card_info[2], card]))
	add_card_to_card_zone(card)
	card.get_node("Name").text = card_info[0]
	card.get_node("Text").text = card_info[1]
	card.get_node("ArtMax").texture = load("res://assets/sprites/%s" % card_info[2])
	card.get_node("Att").text = card_info[3]
	card.get_node("Hp").text = card_info[4]
	card.get_node("Spd").text = card_info[5]
	card.get_node("Energy").text = card_info[6]

func add_card_to_card_zone(card: Control) -> void:
	card.position = Vector2(randi_range(0, 1600), randi_range(0, 700))
	$CardZone.add_child(card)

func on_art_max_selected(card_info: Array) -> void:
	$ActiveArt.texture = load("res://assets/sprites/%s" % card_info[0])
	active_card = card_info[1]

func on_create_unit(tile: Node2D) -> void:
	if active_card.get_node("Team").text.is_valid_int():
		active_cards[active_card.get_node("Team").text.to_int()].append([tile, active_card])
		tile.get_node("Unit").texture = load(active_card.get_node("ArtMax").texture.resource_path)
	refresh_vision()

func on_destroy_unit(tile: Node2D) -> void:
	
	for team in active_cards:
		for i in range(team.size() - 1, -1, -1):
			if team[i][0] == tile:
				team.remove_at(i)
				tile.get_node("Unit").texture = null

	refresh_vision()

func modulate_team_buttons() -> void:
	
	match enable_vision_team_zero:
		true: $TeamZero.modulate = Color(1,0,0,1)
		false: $TeamZero.modulate = Color(1,1,1,1)
		
	match enable_vision_team_one:
		true: $TeamOne.modulate = Color(1,0,0,1)
		false: $TeamOne.modulate = Color(1,1,1,1)

func _on_team_zero_pressed():
	enable_vision_team_zero = !enable_vision_team_zero
	refresh_vision()
	modulate_team_buttons()

func _on_team_one_pressed():
	enable_vision_team_one = !enable_vision_team_one
	refresh_vision()
	modulate_team_buttons()

func refresh_vision() -> void:
	for tile in $Tiles.get_children():
		tile.visible = true
		
	if !(!enable_vision_team_zero and !enable_vision_team_one):
		var visible_tiles: Array = []
		if enable_vision_team_zero:
			visible_tiles += _refresh_vision_for_team(active_cards[0].map(func(x: Array): return x[0]))
			
		if enable_vision_team_one:
			visible_tiles += _refresh_vision_for_team(active_cards[1].map(func(x: Array): return x[0]))
			
		for tile in $Tiles.get_children():
			tile.visible = false
			if enable_vision_team_zero and tile.tile_state == 4: tile.visible = true
			if enable_vision_team_one and tile.tile_state == 5: tile.visible = true
			
		for tile in visible_tiles:
			tile.visible = true
			
	for card in $CardZone.get_children():
		match card.eye_mode:
			false: card.visible = false
			_: card.visible = true; continue
			
		if enable_vision_team_zero and card.get_node("Team").text == "0":
			card.visible = true
				
		if enable_vision_team_one and card.get_node("Team").text == "1":
			card.visible = true
			
func _refresh_vision_for_team(occupied_tiles: Array) -> Array:
	var visible_tiles: Array = []
	for tile in occupied_tiles:
		if tile not in visible_tiles: visible_tiles.append(tile)
		var hk: Vector2 = tile.position
		var found_tiles: Array = $Tiles.get_children().filter(func(xy: Node2D): return sqrt(pow(hk.x - xy.position.x, 2) + pow(hk.y - xy.position.y, 2)) <= 240)
		$Raycast.position = Vector2(hk.x + 95, hk.y)
		for found_tile in found_tiles:
			$Raycast.target_position = Vector2(found_tile.position.x + 95, found_tile.position.y) - $Raycast.position
			$Raycast.force_raycast_update()
			if found_tile not in visible_tiles:
				match $Raycast.is_colliding():
					false: visible_tiles.append(found_tile)
					true: if $Raycast.get_collider().get_parent() == found_tile: visible_tiles.append(found_tile)
			
		$Raycast.target_position = Vector2(found_tiles[0].position.x + 95, found_tiles[0].position.y) - $Raycast.position
	
	return visible_tiles

func on_click_unit(tile: Node2D):
	for team in active_cards:
		for i in team:
			if i[0] == tile:
				move_unit = i
				$ActiveUnit.texture = load(i[1].get_node("ArtMax").texture.resource_path)
				return

func on_move_unit(tile: Node2D):
	on_destroy_unit(move_unit[0])
	on_create_unit(tile)
	move_unit = []
	$ActiveUnit.texture = null
