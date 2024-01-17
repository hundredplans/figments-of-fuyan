extends Control

signal pressed
@export var Heroes: Node
@export var hid: int
var can_press: bool = false

func _ready() -> void:
	$Background/Inside.color = Heroes.hid_accent_color[hid]
	$Background/HeroNameBackground.color = Heroes.hid_primary_color[hid]
	$HeroDescription.text = Heroes.hid_description[hid]
	
	var card: Control = preload("res://assets/base_game/cards/card_ui/card_ui.tscn").instantiate()
	card.Heroes = Heroes
	card.set_info(Helper.id_to_dict(Heroes.hid_to_base(hid), "Card"))
	card.position = Vector2(17, 700)
	add_child(card)
	
	$HeroName.text = card.info.sname
	$HeroTexture.texture = load(card.get_node("Art/ArtMax").texture.resource_path)

func _on_mouse_entered(): modulate = Helper.DARK_GREY; can_press = true
func _on_mouse_exited(): modulate = Helper.BASE; can_press = false
func _input(_event: InputEvent) -> void: if can_press and Input.is_action_just_pressed("LeftClick"): pressed.emit(hid)
