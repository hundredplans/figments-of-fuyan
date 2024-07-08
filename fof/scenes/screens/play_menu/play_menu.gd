extends Control

signal screen_change_sig

@onready var SeedSetter: LineEdit = $SeedSetter
var gseed: int = 0
func _ready() -> void:
	for hero_button in $SelectHero.get_children():
		hero_button.pressed.connect(on_select_hero)

func on_select_hero(HeroCard: HeroCardGD) -> void:
	for hero_button in $SelectHero.get_children(): hero_button.setDisable()
	if SeedSetter.text == "": gseed = randi()
	else: gseed = SeedSetter.text.hash()
	
	seed(gseed)
	Helper.onStartNewGame(HeroCard.hero_id, gseed)
	
	screen_change_sig.emit("res://scenes/screens/map_menu/map_menu.tscn")

func _on_seed_setter_text_submitted(__: String): SeedSetter.release_focus()
