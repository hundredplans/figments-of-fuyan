extends Node2D
var all_cards: Array = []
var max_page: float = 0
var current_page: int = 0
var max_cards_on_page: float = 30

var current_name: String
func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		queue_free()

func _ready() -> void:
	var file_names: PackedStringArray = DirAccess.open("res://assets/sprites").get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".import"))
	for file in file_names:
		all_cards.append(file.replace(".import", ""))
		
	max_page = ceil(float(file_names.size()) / max_cards_on_page) - 1
	load_cards()

func load_cards():
	for child in $SpriteList.get_children(): child.free()
	for i in range(current_page * max_cards_on_page, (current_page + 1) * max_cards_on_page):
		if i < all_cards.size():
			var sprite := TextureButton.new()
			sprite.texture_normal = load("res://assets/sprites/%s" % all_cards[i])
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
	$Card/CardArt.texture = load("res://assets/sprites/%s" % file)

func _on_save_card_pressed():
	var rpath = $Card/CardArt.texture.resource_path
	var tex = rpath.right(rpath.length() - rpath.rfind("/") - 1)
	var file := FileAccess.open("user://save/cards/%s.txt" % $Card/Name.get_text(), FileAccess.WRITE)
	var accum: String = $Card/Name.get_text() + "\n"
	accum += ($Card/Text.text.replace("\n", "")) + "\n"
	accum += tex + "\n"
	
	for child in [$Card/Att, $Card/Hp, $Card/Spd, $Card/Energy]:
		accum += child.text + "\n"
	
	file.store_string(accum)
	file = null

func _on_name_text_changed(new_text):
	if new_text.length() > 2: $Card/SaveCard.disabled = false; current_name = new_text
	else: $Card/SaveCard.disabled = true

func _on_left_pressed():
	if current_page > 0:
		current_page -= 1
		load_cards()
	
func _on_right_pressed():
	if current_page < max_page:
		current_page += 1
		load_cards()

func _on_load_card_pressed():
	var loadcard = preload("res://screens/card_creator/load_card.tscn").instantiate()
	loadcard.card_selected.connect(on_card_selected)
	add_child(loadcard)

func on_card_selected(card_path: String) -> void:
	var file := FileAccess.open("user://save/cards/%s" % card_path, FileAccess.WRITE)
	var card_info: Array = file.get_as_text().split("\n")
	$Card/Name.text = card_info[0]
	$Card/Text.text = card_info[1]
	$Card/Att.text = card_info[3]
	$Card/Hp.text = card_info[4]
	$Card/Spd.text = card_info[5]
	$Card/Energy.text = card_info[6]
	on_art_max_pressed(card_info[2])
	file = null
