extends Node2D

func _on_enter_level_editor_pressed():
	add_child(preload("res://screens/create_level/create_level.tscn").instantiate())
	$Buttons.visible = false

func _on_enter_card_creator_pressed():
	add_child(preload("res://screens/card_creator/card_creator.tscn").instantiate())
	$Buttons.visible = false
	
func _process(_delta: float):
	if Input.is_action_just_pressed("Escape"):
		$Buttons.visible = !$Buttons.visible

func _on_select_level_pressed():
	add_child(preload("res://screens/select_level/select_level.tscn").instantiate())
	$Buttons.visible = false

func _ready():
			
	if !DirAccess.dir_exists_absolute("user://save/cards"):
		DirAccess.make_dir_recursive_absolute("user://save/cards")
		
	if !DirAccess.dir_exists_absolute("user://save/levels"):
		DirAccess.make_dir_recursive_absolute("user://save/levels")
