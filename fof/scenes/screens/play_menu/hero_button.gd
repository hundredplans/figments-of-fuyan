extends Control

signal pressed
@export var hero_card: HeroCardGD
var can_press: bool = false
var is_disabled: bool = false

func _ready() -> void:
	$Background/Inside.color = hero_card.accent_color
	$Background/HeroNameBackground.color = hero_card.primary_color
	$HeroDescription.text = hero_card.description
	
	var GameCard: GameCardGD = preload("res://assets/base_game/cards/game_card/game_card.tscn").instantiate()
	GameCard.set_info(hero_card.base_cards[0])
	GameCard.position = Vector2(-4, 650)
	add_child(GameCard)
	
	$HeroName.text = GameCard.base_card.name
	$HeroTexture.texture = load("res://assets/base_game/cards/cards/" + GameCard.base_card.folder_name + "/art_pop.png")

func _on_mouse_entered(): modulate = Helper.DARK_GREY; can_press = true
func _on_mouse_exited(): modulate = Helper.BASE; can_press = false
func _input(_event: InputEvent) -> void: if can_press and Input.is_action_just_pressed("LeftClick") and !is_disabled: pressed.emit(hero_card)

func setDisable() -> void:
	is_disabled = true
