extends Control
var create_boons: bool = true
var all_cards: Array = []
var max_page: float = 0
var current_page: int = 0
var max_cards_on_page: float = 25

func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		queue_free()

func _ready() -> void:
	load_sprites()
	refresh_card()
	
func load_sprites() -> void:
	var path: String
	match create_boons:
		false: path = "res://test/simulation/assets/sprites/auras/"
		true: path = "res://test/simulation/assets/sprites/boons/"

	var file_names: PackedStringArray = DirAccess.open(path).get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".import"))
	all_cards = Array(file_names).map(func(x: String): return int(x.replace(".png.import", "")))
	all_cards.sort()
	all_cards = all_cards.map(func(x: int): return str(x) + ".png")
	current_page = 0
	max_page = ceil(float(file_names.size()) / max_cards_on_page) - 1
	load_cards()

func load_cards():
	var path: String
	match create_boons:
		false: path = "res://test/simulation/assets/sprites/auras/"
		true: path = "res://test/simulation/assets/sprites/boons/"
		
	for child in $CardZone/SpriteList.get_children(): child.free()
	for i in range(current_page * max_cards_on_page, (current_page + 1) * max_cards_on_page):
		if i < all_cards.size():
			var sprite := TextureButton.new()
			sprite.texture_normal = load(path + str(all_cards[i]))
			$CardZone/SpriteList.add_child(sprite)
			sprite.pressed.connect(on_art_max_pressed.bind(all_cards[i]))
	
	var x: int = 0
	var y: int = 0
	for child in $CardZone/SpriteList.get_children():
		child.position.x += x
		child.position.y += y
		x += 140
		if x >= 700:
			x = 0
			y += 140

func on_art_max_pressed(file: String) -> void:
	var path: String
	match create_boons:
		false: path = "res://test/simulation/assets/sprites/auras/"
		true: path = "res://test/simulation/assets/sprites/boons/"
	$CreateAuraBoon/ArtMax.texture = load(path + file)
	
func _on_auras_boon_swap_pressed():
	create_boons = !create_boons
	match create_boons:
		false: $AurasBoonSwap.text = "Auras"
		true: $AurasBoonSwap.text = "Boons"
	
	load_sprites()
	refresh_card()

func refresh_card() -> void:
	$CreateAuraBoon/ArtMax.texture = null
	$CreateAuraBoon/SelectRarity.select(0)
	_on_select_rarity_item_selected(0)
	$CreateAuraBoon/Name.text = ""
	$CreateAuraBoon/Text.text = ""

func _on_select_rarity_item_selected(rarity: int):
	match rarity:
		0: $CreateAuraBoon/Rarity.color = Color(0.43,0.43,0.43,1)
		1: $CreateAuraBoon/Rarity.color = Color(0.31, 0.478, 0.439,1)
		2: $CreateAuraBoon/Rarity.color = Color(0.966, 0.697, 0.253,1)
		3: $CreateAuraBoon/Rarity.color = Color(0.639, 0.075, 0.722,1)
		4: $CreateAuraBoon/Rarity.color = Color(0.773, 0.031, 0.141, 1)

func _on_left_pressed():
	if current_page > 0:
		current_page -= 1
		load_cards()
	
func _on_right_pressed():
	if current_page < max_page:
		current_page += 1
		load_cards()

func _on_load_auras_boons_pressed():
	pass # Replace with function body.

func _on_save_card_pressed():
	var path: String
	match create_boons:
		false: path = "user://savefofle/auras/"
		true: path = "user://savefofle/boons/"
		
	if $CreateAuraBoon/Name.text and $CreateAuraBoon/Text.text and $CreateAuraBoon/ArtMax.texture:
		var file := FileAccess.open(path + $CreateAuraBoon/Name.text, FileAccess.WRITE)
		var contents: String = "%s\n%s\n%s\n%s" % [$CreateAuraBoon/Name.text, $CreateAuraBoon/Text.text.replace("\n", ""), $CreateAuraBoon/ArtMax.texture.resource_path,str($CreateAuraBoon/SelectRarity.selected)]
		file.store_string(contents)
		file = null
