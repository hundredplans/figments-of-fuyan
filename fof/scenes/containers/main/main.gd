extends Node

@export var BackArrow: TextureButton
@onready var screens: Control = $Screens
@onready var world: Node3D = $World
const main_menu_path: String = "res://scenes/screens/main_menu/main_menu.tscn"
var fileloader_state: int = 0
var screen_change_animation_active: bool = false
var screen_history: Array = []
		
func on_user_quit() -> void:
	Settings.update_settings_file_info()
	
func _ready() -> void:
	Helper.create_button_clickmask(BackArrow)
	for helper_signal in [
	["add_screen_history", on_add_screen_history],
	["screen_change_animation_state", on_screen_change_animation_state],
	]:
		Helper[helper_signal[0]].connect(helper_signal[1])
	on_load_screen(main_menu_path)
	
	var modified_time: int = Settings.clear_backup_files_array[Settings.clear_backup_files]
	if modified_time > 1:
		for file in Helper.return_file_names_recursive("user://save/temp"):
			if FileAccess.get_modified_time(file) < Time.get_unix_time_from_system() - modified_time:
				DirAccess.remove_absolute(file)

func on_screen_change_animation_state(x: bool) -> void:
	screen_change_animation_active = x
	BackArrow.disabled = x

func sim_pressed(): call_deferred("on_sim_pressed")
func on_sim_pressed():
	for child in get_tree().get_root().get_children(): child.queue_free()
	get_tree().get_root().add_child(preload("res://test/simulation/screens/main/main.tscn").instantiate())
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		on_trigger_screen_history()
		
func on_load_screen(screen_name: String) -> void:
	if !screen_change_animation_active:
		var screen: Control = load(screen_name).instantiate()
		match screens.get_children().size():
			0: 
				Helper.on_enter_screen(screen)
			1:
				var child: Control = screens.get_child(0)
				Helper.on_exit_screen(screen, child)
			_: 
				print_debug("You have too many screens")
				for child in $Screens.get_children(): child.queue_free()
				Helper.on_enter_screen(screen)
				
func on_connect_screen_signals(screen: Control) -> void:
	if "screen_change_signals" in screen:
		for sig_info in screen.screen_change_signals:
			sig_info[0].connect(on_load_screen.bind(sig_info[1]))
			
	for sig in ["change_fileloader_state"]:
		if sig in screen:
			screen[sig].connect(get("on_" + sig))
			
	if screen.name == "MainMenu" or Settings.hide_back_arrow == 2 or screen.name == "LoreBooksEditor" and Settings.hide_back_arrow == 1:
		BackArrow.visible = false
	else:
		BackArrow.visible = true
			
func on_add_screen_history(load_path: String) -> void:
	screen_history.append(load_path)
	
func on_trigger_screen_history() -> void:
	match fileloader_state:
		0:
			if !screen_change_animation_active and screen_history.size() > 1:
				screen_history.resize(screen_history.size() - 1)
				var path: String = screen_history[screen_history.size() - 1]
				on_load_screen(path)
				screen_history.resize(screen_history.size() - 1)
		2: screens.get_child(0).get_node("FileLoader").on_exit_button_pressed.call()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: on_user_quit()

func on_change_fileloader_state(i: int) -> void:
	fileloader_state = i
