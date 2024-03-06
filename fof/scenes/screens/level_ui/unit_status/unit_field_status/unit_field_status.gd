extends Node3D

@onready var Gem: Sprite3D = %Gem
@onready var Background: Sprite3D = %Background

@onready var Attack: Label3D = %Attack
@onready var Health: Label3D = %Health
@onready var Speed: Label3D = %Speed

@onready var ArtMini: Sprite3D = %ArtMini

var SpectateCamera: Camera3D
var Heroes: HeroesGD
var Unit: UnitGD
func on_set_unit(_Unit: UnitGD) -> void:
	Unit = _Unit
	Gem.visible = Unit.team == 0
	Background.modulate = "00be00" if Unit.team == 0 else "c11e00"
	
	var hero_bgfn: String = Unit.base_card.bgfn if Unit.rarity != 7 else Helper.id_to_dict(Heroes.id_to_base(Unit.id), "Card").bgfn
	var card_texture_path: String = "res://assets/base_game/cards/" + hero_bgfn + "/art_mini.png"
	ArtMini.texture = load(card_texture_path)

func on_update_stats(att: int, hp: int, speed: int) -> void:
	Attack.text = str(att)
	Health.text = str(hp)
	Speed.text = str(speed)
	
func _process(_delta: float) -> void:
	if visible: look_at(SpectateCamera.global_position)
