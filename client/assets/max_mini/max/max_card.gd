extends Node3D

const max_lines: Dictionary = {
	"Text": 5, 
	"Clan": 1,
	"Name": 1,
}
const size_rect := Rect2i(0, 0, 150, 300)
var uid: int = 0
var cid: int = 0

var card_art_positions: Dictionary = {
	"shadow": Vector2(15, 160),
	"artmax": Vector2(14, 8),
}

var card_stats_positions: Dictionary = {
	"u": {"a": Vector2(-0.512, 0.05), "h": Vector2(0.513,0.07), "s": Vector2(0.55, 1.34), "e": Vector2(-0.55, 1.32)},
	"s": {"e": Vector2(-0.55, 1.32)},
	"t": {"a": Vector2(-0.512, 0.05), "h": Vector2(0.513,0.07), "r": Vector2(0.55, 1.34), "e": Vector2(-0.55, 1.32)},
	"w": {"h": Vector2(0.513,0.07), "d": Vector2(0.55, 1.34), "e": Vector2(-0.55, 1.32)},
	"p": {"h": Vector2(0.513,0.07), "p": Vector2(0.55, 1.34), "e": Vector2(-0.55, 1.32)},
	"r": {"b": Vector2(-0.55, 1.32), "o": Vector2(0.55, 1.34)},
	"c": {"h": Vector2(-0.55, 1.32)},
}

func create_card(card: Dictionary, clan_convert: Dictionary, card_back_convert: Dictionary, _uid: int):
	uid = _uid
	cid = card.cid
	create_card_art(card)
	create_card_back(1, card_back_convert)
	create_card_text(card, clan_convert)
	create_card_stats(card)
	call_deferred("change_text_size")
	
func create_card_art(card: Dictionary):
	
	var base: String = "g" if card.clan == "e" and card.type == "s" else card.rarity
	var baseImage: Image = load("res://assets/max_mini/max/base/%s.png" % base)
	
	var shadow: String = "aCoconut" if card.cid == 1 or card.cid == 9 else card.clan
	var shadowImage: Image = load("res://assets/max_mini/max/shadow/%s.png" % shadow)

	var stats: String = "s0" if card.type == "s" and card.type == "s" else card.type
	var statsImage: Image = load("res://assets/max_mini/max/stats/%s.png" % stats)
	
	var artmaxImage: Image = load("res://assets/cards/%s/art_max.png" % card.cid)
	artmaxImage.convert(Image.FORMAT_RGBA8)
	
	var heromark: String = "res://assets/max_mini/max/hero_mark/%s.png" % card.clan
	if FileAccess.file_exists(heromark):
		var heromarkImage: Image = load(heromark)
		baseImage.blend_rect(heromarkImage, size_rect, Vector2(0, 0))
	
	baseImage.blend_rect(artmaxImage, size_rect, card_art_positions.artmax)
	baseImage.blend_rect(statsImage, size_rect, Vector2(0, 0))
	baseImage.blend_rect(shadowImage, size_rect, card_art_positions.shadow)
	var imageTx := ImageTexture.create_from_image(baseImage)
	$Art.texture = imageTx
func create_card_text(card: Dictionary, clan_convert: Dictionary) -> void:
	$TextViewport/Clan.text = clan_convert[card.clan]
	$TextViewport/Text.text = card.text
	$TextViewport/Name.text = card.name
func create_card_back(card_back_id: int, card_back_convert: Dictionary):
	for child in get_children(): if child.name == "card_back": child.queue_free()
	var card_back: Node3D = load(card_back_convert[str(card_back_id)]).instantiate()
	add_child(card_back)
func create_card_stats(card: Dictionary) -> void:
	for pos in card_stats_positions[card.type]:
		if card.has(pos):
			var label: Label3D = load("res://assets/max_mini/max/stats/stats_label.tscn").instantiate()
			label.name = pos
			label.text = str(int(card[pos]))
			label.position.x = card_stats_positions[card.type][pos].x
			label.position.y = card_stats_positions[card.type][pos].y
			$Stats.add_child(label)
func change_text_size():
	var restart: bool = false
	for lab in $TextViewport.get_children():
		if lab.get_line_count() > max_lines[lab.name]:
			lab.set_label_settings(load("res://assets/max_mini/max/text/%s.tres" % str(int(lab.label_settings.font_size) -2)))
			restart = true
	
	if restart: call_deferred("change_text_size")
