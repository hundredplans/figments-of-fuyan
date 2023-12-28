extends Control

@onready var SeedSetter: LineEdit = $SeedSetter
var gseed: int = 0
func _ready() -> void:
	for hero_button in $SelectHero.get_children():
		hero_button.pressed.connect(on_select_hero)

func on_select_hero(hid: int) -> void:
	if SeedSetter.text == "": gseed = randi()
	else: gseed = SeedSetter.text.hash()
	
	seed(gseed)
	print(gseed)
	Helper.on_load_game_state(hid, gseed)
	queue_free()

func _on_seed_setter_text_submitted(__: String): SeedSetter.release_focus()
