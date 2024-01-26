extends Control
var info: Dictionary

signal pressed
var is_hover: bool = false
@export var show_tool: bool = true
var Heroes: HeroesGD
@export var Art: Control
@export var Text: Control
@export var Stats: Control

func set_info(_info: Dictionary) -> void:
	info = _info
	for stat in ["a", "h", "s", "e"]:
		Stats.get_node(Helper.stat_ai_dict[stat] + "/Label").text = str(info[stat])
	
	Text.get_node("Text").text = info["text"]
	$TextProcessing.on_apply_text_processing(info["text"], Text.get_node("Text"))
	Text.get_node("Name").text = info["sname"]
	
	var hero_bgfn: String = info.bgfn if info.r != 7 else Helper.id_to_dict(Heroes.id_to_base(info.id), "Card").bgfn
	var texture_path: String = "res://assets/base_game/cards/card_ui/default_art_max.png"
	var card_texture_path: String = "res://assets/base_game/cards/" + hero_bgfn + "/art_max.png"
	if FileAccess.file_exists(card_texture_path):
		texture_path = card_texture_path
	Art.get_node("ArtMax").texture = load(texture_path)
	
	var front_card: TextureButton = Art.get_node("FrontCard")
	front_card.texture_normal = load("res://assets/base_game/cards/card_ui/rarity/" + str(info.r) + ".png")
	$Art/BlackCard.texture = ImageTexture.create_from_image(load("res://assets/base_game/cards/card_ui/rarity/" + str(info.r) + "_image.png"))
	
	$Stats/Tool.visible = show_tool
	Helper.create_button_clickmask(front_card)
	if !is_hover: front_card.mouse_filter = MOUSE_FILTER_PASS

func set_tool(_tool_id: int) -> void:
	pass

func _on_front_card_mouse_entered(): if is_hover: modulate = Helper.LIGHT_GREY
func _on_front_card_mouse_exited(): if is_hover: modulate = Helper.BASE
func _on_front_card_pressed(): pressed.emit()

func on_set_disabled(state: bool) -> void:
	$Art/FrontCard.disabled = state
	modulate = Helper.BASE if !state else Helper.DARK_GREY
	is_hover = !state
