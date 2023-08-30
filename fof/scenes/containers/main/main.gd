extends Node
@onready var screens: Control = $Screens
@onready var world: Node3D = $World
const main_menu_path: String = "res://scenes/screens/main_menu/main_menu.tscn"
var screen_change_animation_active: bool = false
var screen_history: Array = []
		
func _ready() -> void:
	for helper_signal in [
	["add_screen_history", on_add_screen_history], \
	["screen_change_animation_state", func(x: bool): screen_change_animation_active = x],
	]:
		get_parent().get_node("/root/Helper")[helper_signal[0]].connect(helper_signal[1])
	on_load_screen(preload(main_menu_path).instantiate())

func sim_pressed(): call_deferred("on_sim_pressed")
func on_sim_pressed():
	for child in get_tree().get_root().get_children(): child.queue_free()
	get_tree().get_root().add_child(preload("res://test/simulation/screens/main/main.tscn").instantiate())
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		on_trigger_screen_history()
func on_load_screen(screen: Control) -> void:
	match screens.get_children().size():
		0: 
			Helper.on_enter_screen(screen)
		1:
			var child: Control = screens.get_child(0)
			Helper.on_exit_screen(screen, child)
		_: print_debug("You have too many screens"); screen.queue_free()	
func on_connect_screen_signals(screen: Control) -> void:
	if "screen_change_signals" in screen:
		for sig_info in screen.screen_change_signals:
			sig_info[0].connect(on_load_screen.bind(load(sig_info[1]).instantiate()))
func on_add_screen_history(load_path: String) -> void:
	screen_history.append(load_path)
func on_trigger_screen_history() -> void:
	if !screen_change_animation_active and screen_history.size() > 1:
		screen_history.resize(screen_history.size() - 1)
		var path: String = screen_history[screen_history.size() - 1]
		on_load_screen(load(path).instantiate())
		screen_history.resize(screen_history.size() - 1)
