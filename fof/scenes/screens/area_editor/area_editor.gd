extends Control
const TID: int = 1
const FILE_LOADER_NAME: String = "Area"
var world_difficulty: int = 1
var primary_color: Color = Color("000000")
var accent_color: Color = Color("ffffff")
var cards: Array
var tiles_allowed: Array

var primary_color_selected: bool = false
var choose_color := Color(0x00000000)

@onready var CardZone: Control = $AddedCards/CardZone

func _ready():
	on_reload_page(0)
	modulate_all()
	Helper.load_area_colors(self, primary_color, accent_color)
	var available_colors: Array = Helper.return_file_contents("res://static/screens/area_editor/available_colors.txt").split("\n", false)
	if available_colors.size() > 0:
		var primary_container: bool = false
		for container in [$Buttons/Colors/PrimaryColor/Colors, $Buttons/Colors/AccentColor/Colors]:
			primary_container = !primary_container
			var color_rect_size: int = floor(container.size.x / available_colors.size())
			var next_position: float = 0
			var i: int = 1
			for hexcolor in available_colors:
				if hexcolor.length() == 6:
					var color_rect := ColorRect.new()
					color_rect.color = Color(hexcolor)
					color_rect.size = Vector2(color_rect_size, container.size.y)
					if i == available_colors.size(): color_rect.size.x = container.size.x - next_position
					color_rect.position.x = next_position
					color_rect.mouse_entered.connect(func(): choose_color = hexcolor; primary_color_selected = primary_container)
					color_rect.mouse_exited.connect(func(): choose_color = 0x00000000)
					
					next_position = color_rect.size.x + color_rect.position.x
					container.add_child(color_rect)
					i += 1
				else: print_debug("Your: %s value is incorrectly formatted, are you perhaps using RGB values?" % hexcolor)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		if choose_color != Color(0x00000000):
			match primary_color_selected:
				true: primary_color = choose_color
				false: accent_color = choose_color
			Helper.load_area_colors(self, primary_color, accent_color)

func modulate_all() -> void:
	modulate_world_difficulty_buttons()
	
func modulate_world_difficulty_buttons() -> void:
	var i: int = 0
	for child in $Buttons/WorldDifficulty.get_children():
		if child as Button:
			i += 1
			if i == world_difficulty: child.modulate = Helper.RED
			else: child.modulate = Helper.BASE
	
func _on_world_difficulty_pressed(_world_difficulty: int): 
	world_difficulty = _world_difficulty
	modulate_world_difficulty_buttons()

func _on_save_area_pressed():
	var contents: String = "%s\n%s\n%s\n%s\n%s" % [str(primary_color), str(accent_color), str(world_difficulty), str(cards.map(func(x: Dictionary): return x.id)), tiles_allowed]
	var item_contents: Dictionary = Helper.write_to_base_game_file(FILE_LOADER_NAME, $Buttons/EditFileName, contents, TID)
	Helper.create_base_game_id_dir(item_contents, FILE_LOADER_NAME)
	
func _on_load_area_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready(FILE_LOADER_NAME)
	FileLoader.item_selected.connect(on_item_selected)
	add_child(FileLoader)
	
func on_item_selected(item_info: Dictionary) -> void:
	_on_world_difficulty_pressed(item_info.world)
	primary_color = item_info.pcolor
	accent_color = item_info.acolor
	Helper.load_area_colors(self, primary_color, accent_color)
	$Buttons/EditFileName.set_text(item_info.iname, item_info.sname)
	
	cards = item_info.cards.map(func(x: int): return Helper.id_to_dict(x, "Card"))
	on_reload_page(0)
		
func _on_add_cards_pressed():
	var FileLoader: Control = preload("res://scenes/editor/file_loader/file_loader.tscn").instantiate()
	FileLoader.on_ready("Card")
	FileLoader.item_selected.connect(on_add_card)
	add_child(FileLoader)
	
#func on_card_selected(card_info: Dictionary) -> void:
	#if card_info and !card_info.id in cards:
		#$AddedCards/Label.visible = false
		#var added_card: Control = preload("res://scenes/screens/area_editor/added_card.tscn").instantiate()
		#added_card.name = str(card_info.id)
		#added_card.remove_card.connect(on_remove_card)
		#added_card.change_art(card_info.bgfn)
		#CardZone.add_child(added_card)
		#cards.append(card_info.id)
		#on_sort_added_cards()
		##set_card_amount()
		
#func on_remove_card(btn: Control) -> void:
	#cards.erase(int(str(btn.name)))
	#if cards.is_empty(): $AddedCards/Label.visible = true
	#btn.queue_free()
	#on_sort_added_cards()
	#get_viewport().warp_mouse(get_viewport().get_mouse_position())
	#set_card_amount()
	
func on_sort_added_cards():
	var xy := Vector2(0, 20)
	for child in CardZone.get_children():
		if !child.is_queued_for_deletion():
			child.position = xy
			xy.x += 150
			if xy.x > 300:
				xy.y += 150
				xy.x = 0

func _queue_free() -> void:
	_on_save_area_pressed()

const MAX_PAGE_COUNT: int = 18
var page: int = 0

var _area_card: PackedScene = preload("res://scenes/screens/area_editor/added_card.tscn")
func on_reload_page(i: int) -> void:
	var max_page: int = floor(max(cards.size(), 1) / MAX_PAGE_COUNT)
	page = clamp(page + i, 0, max_page)
	$AddedCards/PageZone/PRLeftArrow.disabled = page == 0
	$AddedCards/PageZone/PRRightArrow.disabled = page == max_page
	
	for child in CardZone.get_children(): child.queue_free()
	for j in range(page * MAX_PAGE_COUNT, min((page + 1) * MAX_PAGE_COUNT, cards.size())):
		var area_card: Control = _area_card.instantiate()
		area_card.remove_card.connect(on_remove_card.bind(cards[j]))
		area_card.change_art(cards[j].bgfn)
		CardZone.add_child(area_card)
		
	on_sort_added_cards()
	$AddedCards/Label.visible = cards.size() == 0
	$AddedCards/Amount.visible = cards.size() > 0
	$AddedCards/Amount.text = str(cards.size())
	
func on_remove_card(card_info: Dictionary) -> void:
	cards.erase(card_info)
	on_reload_page(0)

func on_add_card(card_info: Dictionary) -> void:
	if !cards.any(func(x: Dictionary): return x.id == card_info.id):
		cards.append(card_info)
		on_reload_page(0)
