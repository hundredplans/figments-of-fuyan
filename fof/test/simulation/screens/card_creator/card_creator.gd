extends Control
var all_cards: Array = []
var max_page: float = 0
var current_page: int = 0
var max_cards_on_page: float = 30
var load_cards_extra: bool = false

var current_name: String
func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		queue_free()

func _ready() -> void:
	theme = preload("res://test/simulation/assets/fonts/roboto32.tres")
	$Card/RaritySelect.select(0)
	_on_rarity_select_item_selected(0)
	var file_names: PackedStringArray = DirAccess.open("res://test/simulation/assets/sprites/units").get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".import"))
	all_cards = Array(file_names).map(func(x: String): return int(x.replace(".png.import", "")))
	all_cards.sort()
	all_cards = all_cards.map(func(x: int): return str(x) + ".png")
		
	max_page = ceil(float(file_names.size()) / max_cards_on_page) - 1
	load_cards()

func load_cards():
	for child in $SpriteList.get_children(): child.free()
	for i in range(current_page * max_cards_on_page, (current_page + 1) * max_cards_on_page):
		if i < all_cards.size():
			var sprite := TextureButton.new()
			sprite.texture_normal = load("res://test/simulation/assets/sprites/units/%s" % all_cards[i])
			$SpriteList.add_child(sprite)
			sprite.pressed.connect(on_art_max_pressed.bind(all_cards[i]))
	
	var x: int = 0
	var y: int = 0
	for child in $SpriteList.get_children():
		child.position.x += x
		child.position.y += y
		x += 140
		if x >= 700:
			x = 0
			y += 140

func on_art_max_pressed(file: String):
	$Card/CardArt.texture = load("res://test/simulation/assets/sprites/units/%s" % file)

func _on_save_card_pressed():
	var rpath = $Card/CardArt.texture.resource_path
	var tex = rpath.right(rpath.length() - rpath.rfind("/") - 1)
	var file := FileAccess.open("user://savefofle/cards/%s.txt" % $Card/Name.get_text(), FileAccess.WRITE)
	var accum: String = $Card/Name.get_text() + "\n"
	accum += ($Card/Text.text.replace("\n", "")) + "\n"
	accum += tex + "\n"
	
	for child in [$Card/Att, $Card/Hp, $Card/Spd, $Card/Energy]:
		accum += child.text + "\n"
	
	accum += str($Card/RaritySelect.selected) + "\n"
	file.store_string(accum)
	file = null

func _on_left_pressed():
	if current_page > 0:
		current_page -= 1
		load_cards()
	
func _on_right_pressed():
	if current_page < max_page:
		current_page += 1
		load_cards()

func _on_load_card_pressed():
	var loadcard = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	loadcard.card_selected.connect(on_card_selected)
	add_child(loadcard)
	
func on_card_selected(card_name: String) -> Control:
	var path: String = "user://savefofle/cards/%s" % card_name
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		var card_info: Array = file.get_as_text().split("\n")
		
		$Card/Name.text = card_info[0]
		$Card/Text.text = card_info[1]
		$Card/Att.text = card_info[3]
		$Card/Hp.text = card_info[4]
		$Card/Spd.text = card_info[5]
		$Card/Energy.text = card_info[6]
	
		var rarity: int = 0
		if card_info.size() > 7: rarity = int(card_info[7])
		$Card/RaritySelect.select(rarity)
		_on_rarity_select_item_selected(rarity)
		on_art_max_pressed(card_info[2])
		
		if load_cards_extra:
			var card: Control = preload("res://test/simulation/screens/select_level/card.tscn").instantiate()
			card.card_path = card_name
			card.default_state = card_info.duplicate(true)
			var area: Area2D = preload("res://test/simulation/screens/create_level/mouse_blocker.tscn").instantiate()
			card.add_child(area)
			card._on_default_state_pressed()
			card.on_team_buttons_modulate()
			add_card_to_card_zone(card)
			return card
	return null
	
func add_card_to_card_zone(card: Control) -> void:
	card.position = Vector2(randi_range(0, 1600), randi_range(0, 800))
	$CardZone.add_child(card)

func _on_rarity_select_item_selected(rarity: int):
	match rarity:
		0: $Card/In.color = Color(0.43,0.43,0.43,1)
		1: $Card/In.color = Color(0.31, 0.478, 0.439,1)
		2: $Card/In.color = Color(0.966, 0.697, 0.253,1)
		3: $Card/In.color = Color(0.639, 0.075, 0.722,1)
		4: $Card/In.color = Color(0.773, 0.031, 0.141, 1)
		5: $Card/In.color = Color(0.374, 0.6, 1, 1)
		6: $Card/In.color = Color(0.196, 0.196, 0.196, 1)

func _on_load_cards_pressed(): 
	load_cards_extra = !load_cards_extra
	match load_cards_extra:
		false: $LoadCards.modulate = Color(1,1,1,1)
		true: $LoadCards.modulate = Color(1,0,0,1)
