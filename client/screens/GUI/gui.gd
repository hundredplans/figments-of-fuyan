extends Control
var currently_stepping_back: bool = false
var animation_status: int = 0
var back_history: Array = []
signal lobby_item_selected
signal exit_door_exit_game

var current_gui_selected: StringName
func _ready():
	$BackArrow.visible = false
func load_gui(path: String) -> Control:
	
	for child in $MainScreen.get_children():
		child.queue_free()
		
	var gui_screen: Control = load(path).instantiate()
	$MainScreen.add_child(gui_screen)
	current_gui_selected = $MainScreen.get_child(0).name
	return gui_screen
func load_lobby_gui(path: String) -> void:
	var lobby_gui: Control = load(path).instantiate()
	add_child(lobby_gui)
	lobby_gui.lobby_item_selected.connect(func(item_id):  lobby_item_selected.emit(item_id))	
func _on_back_arrow_pressed():
	on_go_back_step()
func _process(_delta: float):
	if Input.is_action_just_pressed("InputBackMenu") and animation_status < 1:
		on_go_back_step()
		
func on_go_back_step() -> void:
	if back_history.size():
		if !currently_stepping_back:
			currently_stepping_back = true
			back_history[0][0].call([back_history[0][1], func(): currently_stepping_back = false; $BackArrow.disabled = false])
			back_history.remove_at(0)
			if !back_history.size():
				remove_main_screen()
	
	if !back_history.size():
		$BackArrow.visible = false
func add_to_back_history(item: Array):
	back_history.append(item)
	$BackArrow.visible = true
func change_animation_status(status: int):
	
	match status:
		0: $BackArrow.disabled = false; animation_status = 0
		1: $BackArrow.disabled = true; animation_status = 1
		2: $BackArrow.disabled = true; $BackArrow.visible = false; animation_status = 1

func currency_holder_status(status: int):
	match status:
		0: $CurrencyHolder.visible = false
		1: $CurrencyHolder.visible = true

func on_lobby_camera_travel_main_menu_finished():
	get_node("LobbyMapGui").on_lobby_camera_travel_main_menu_finished()
	currency_holder_status(1)
	
func on_lobby_camera_travel_item_finished(path: String):
	var item_gui: Control = load_gui(path)
	call("on_" + item_gui.name + "_init", item_gui)
	
func remove_main_screen():
	for child in $MainScreen.get_children():
		child.queue_free()

func on_ExitDoorGUI_init(screen: Control):
	screen.go_back_step_from_child.connect(on_go_back_step)
	screen.exit_door_exit_game.connect(func(path): change_animation_status(2); exit_door_exit_game.emit(path))
func on_PlayMenuGUI_init(_screen: Control):
	currency_holder_status(1)
func on_SettingsGUI_init(_screen: Control): pass
func on_NewsGUI_init(_screen: Control): pass
func on_DeckManagerGUI_init(_screen: Control): pass

func on_lobby_camera_travel_item_started(_item_id: int, _direction: bool):
	currency_holder_status(0)
