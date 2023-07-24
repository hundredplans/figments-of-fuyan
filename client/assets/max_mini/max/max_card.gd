extends Node3D

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

func create_card(card: Dictionary, card_back_convert: Dictionary, aliased_cards: Dictionary, card_preload: Dictionary, _uid: int):
	uid = _uid
	cid = card.cid
	create_card_art(card, aliased_cards)
	create_card_back(1, card_back_convert)
	create_card_text(card, card_preload)
	create_card_stats(card)
	
func create_card_text(card: Dictionary, card_preload: Dictionary) -> void:
	$TextViewport/Name/Name.text = card_preload[str(card.cid)].name
	$TextViewport/Clan/Clan.text = card_preload[str(card.cid)].clan
	$TextViewport/Text/Text.text = card_preload[str(card.cid)].text
	
	$TextViewport/Name/Name["theme_override_font_sizes/normal_font_size"] = card_preload[str(card.cid)].name_size
	$TextViewport/Name/Name["theme_override_font_sizes/bold_font_size"] = card_preload[str(card.cid)].name_size
	$TextViewport/Clan/Clan["theme_override_font_sizes/normal_font_size"] = card_preload[str(card.cid)].clan_size
	$TextViewport/Clan/Clan["theme_override_font_sizes/bold_font_size"] = card_preload[str(card.cid)].clan_size
	$TextViewport/Text/Text["theme_override_font_sizes/normal_font_size"] = card_preload[str(card.cid)].text_size
	$TextViewport/Text/Text["theme_override_font_sizes/bold_font_size"] = card_preload[str(card.cid)].text_size
	
func create_card_art(card: Dictionary, aliased_cards: Dictionary):
	
	var base: String = "g" if card.clan == "e" and card.type == "s" else card.rarity
	var baseImage: Image = load("res://assets/max_mini/max/base/%s.png" % base)
	
	var shadow: String = "aCoconut" if card.cid == 1 or card.cid == 9 else card.clan
	var shadowImage: Image = load("res://assets/max_mini/max/shadow/%s.png" % shadow)

	var stats: String = "s0" if card.type == "s" and card.type == "s" else card.type
	var statsImage: Image = load("res://assets/max_mini/max/stats/%s.png" % stats)
	
	var heromark: String = "res://assets/max_mini/max/hero_mark/%s.png" % card.clan
	if FileAccess.file_exists(heromark):
		var heromarkImage: Image = load(heromark)
		baseImage.blend_rect(heromarkImage, size_rect, Vector2(0, 0))
	
	baseImage.blend_rect(statsImage, size_rect, Vector2(0, 0))
	baseImage.blend_rect(shadowImage, size_rect, card_art_positions.shadow)
	$Art.texture = ImageTexture.create_from_image(baseImage)
	
	var artmaxImage: Image = load("res://assets/cards/%s/art_max.png" % card.cid)
	if card.cid in aliased_cards.cids: $ArtMax.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	$ArtMax.texture = ImageTexture.create_from_image(artmaxImage)
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
