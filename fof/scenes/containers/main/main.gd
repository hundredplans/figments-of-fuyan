extends Node
@onready var screens: Control = $Screens
@onready var world: Node3D = $World

func _ready() -> void:
	screens.get_node("MainMenu").editor_menu_pressed.connect(on_load_screen.bind(preload("res://scenes/screens/editor_menu/editor_menu.tscn").instantiate()))

func sim_pressed(): call_deferred("on_sim_pressed")
func on_sim_pressed():
	for child in get_tree().get_root().get_children(): child.queue_free()
	get_tree().get_root().add_child(preload("res://test/simulation/screens/main/main.tscn").instantiate())

func on_load_screen(screen: Control) -> void:
	match screens.get_children().size():
		1:
			var child: Control = screens.get_child(0)
			if !Helper.call_method(child, "on_exit_screen", [screen]):
				child.queue_free()
				Helper.on_enter_screen(screen)
		_: print_debug("You have too many screens")
		
