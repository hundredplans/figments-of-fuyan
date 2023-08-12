extends Control
var load_card_path: String = "user://savefofle/cards"
var load_level_path: String = "user://savefofle/levels"

func _on_enter_level_editor_pressed():
	add_child(preload("res://test/simulation/screens/create_level/create_level.tscn").instantiate())
	$Buttons.visible = false

func _on_enter_card_creator_pressed():
	add_child(preload("res://test/simulation/screens/card_creator/card_creator.tscn").instantiate())
	$Buttons.visible = false
	
func _process(_delta: float):
	if Input.is_action_just_pressed("Escape"):
		$Buttons.visible = !$Buttons.visible

func _on_select_level_pressed():
	add_child(preload("res://test/simulation/screens/select_level/select_level.tscn").instantiate())
	$Buttons.visible = false

func _ready():
	theme = preload("res://test/simulation/assets/fonts/roboto32.tres")
	if !DirAccess.dir_exists_absolute("user://savefofle/cards"):
		DirAccess.make_dir_recursive_absolute("user://savefofle/cards")
		
	if !DirAccess.dir_exists_absolute("user://savefofle/levels"):
		DirAccess.make_dir_recursive_absolute("user://savefofle/levels")
