extends Node

@export var SettingCog: TextureButton
@export var BackArrow: TextureButton

@onready var MoveScreen: AnimationPlayer = $UI/MoveScreen
@onready var Screens: Control = $UI/Screens
@onready var World: Node3D = $World

const main_menu_path: String = "res://scenes/screens/main_menu/main_menu.tscn"
var fileloader_state: int = 0
var screen_change_animation_active: bool = false
var screen_history: Array = []
var move_screen_switch_length: Dictionary = {
	"MainMenu": 0.5,
	"EditorMenu": 0.25,
	"SettingsMenu": 0.25,
	"Fuyanopedia": 0.25,
	"LevelEditor": 0.25,
	"LoreBooksEditor": 0.25,
	"AreaEditor": 0.25,
	"CardEditor": 0.25,
}

func on_user_quit() -> void:
	Settings.update_settings_file_info()
	get_tree().quit()
	
func on_menu_transition(screen: Control, old_screen: Control, is_enter: bool) -> void:
	on_setup_screen(screen)
	if old_screen.has_method("on_move_screen_setup"):
		old_screen.on_move_screen_setup()
	on_screen_change_animation_state(true)
	screen.visible = false
	
	if is_enter:
		MoveScreen.play(old_screen.name)
		screen_history.append(old_screen.scene_file_path)
	else: MoveScreen.play_backwards(old_screen.name)
	Helper.on_timer_end(on_move_screen_switch, [screen], move_screen_switch_length[old_screen.name])
func on_menu_button_pressed(i: Variant) -> void:
	match typeof(i):
		TYPE_CALLABLE: i.call()
		TYPE_STRING: on_load_screen(i, true)
	
func _on_move_screen_animation_finished(__: String):
	var screen: Control = Screens.get_child(1)
	if screen.has_method("_queue_free"): screen._queue_free()
	screen.queue_free()
	on_screen_change_animation_state(false)

func on_move_screen_switch(screen: Control) -> void:
	screen.visible = true
	if screen.has_method("on_move_screen_switch"):
		screen.on_move_screen_switch.call()
	
#	var button: TextureButton = info.filter(func(x: Array): return x[1] == screen_file_path)[0][0]
#	button.get_parent().visible = false
#	AnimationItem.position = Vector2(button.position.x, button.position.y)
#	AnimationItem.flip_h = button.flip_h
#	if !backwards: MoveScreen.play("move_screen")
#	else: MoveScreen.play_backwards("move_screen")
#
#	if !is_enter:
#		MenuButtons.setup_buttons(screen.screen_change)
#		MenuButtons.get_node("Buttons").visible = false
#	else:
#		pass
#
#	MenuButtons.play_animation(screens[int(!is_enter)].scene_file_path, !is_enter)
#	Helper.on_timer_end(on_swap_screens, [screen, old_screen], 0.5 if is_enter else 0.1)
#	Helper.on_timer_end(on_swap_screens_animation_end, [screen], 0.6)
#
#func on_swap_screens_animation_end(screen: Control) -> void:
#	on_screen_change_animation_state(false)
#	for i in MenuButtons.info:
#		i[0].pressed.connect(on_load_screen.bind(i[1], true))
#
#func on_swap_screens(screen: Control, old_screen: Control) -> void:
#	if old_screen.has_method("_queue_free"): old_screen._queue_free()
#	old_screen.queue_free()
#
#	Screens.add_child(screen)
#	MenuButtons.setup_buttons(screen.screen_change)
#	MenuButtons.get_node("Buttons").visible = true
#	after_ready_connect_screen(screen)

func on_setup_screen(screen: Control) -> void:
	before_ready_connect_screen(screen)
	Screens.add_child(screen)
	Screens.move_child(screen, 0)
	after_ready_connect_screen(screen)
	if screen.get("screen_change"):
		for i in screen.screen_change:
			screen.get_node("MenuButtons/" + i[0]).pressed.connect(on_menu_button_pressed.bind(i[1]))

func before_ready_connect_screen(screen: Control):
	match screen.name:
		"LevelEditor": screen.load_world.connect(on_load_world)
	
func after_ready_connect_screen(screen: Control):
	if screen.name == "MainMenu" or Settings.hide_menu_gui == 2 or screen.name == "LoreBooksEditor" and Settings.hide_menu_gui == 1:
		BackArrow.visible = false
		SettingCog.visible = false
	else: 
		BackArrow.visible = true
		SettingCog.visible = true
		
	match screen.name:
		"SettingsMenu": 
			SettingCog.visible = false
			BackArrow.position.x += 70
		_: if BackArrow.position.x > 1768: BackArrow.position.x = 1768
	get_viewport().warp_mouse(get_viewport().get_mouse_position())
	
func _ready() -> void:
	
	$UI.z_index = 10
	for screen in Screens.get_children(): screen.free()
	BackArrow.visible = false
	SettingCog.visible = false
	
	SettingCog.pressed.connect(func(): AudioMaster.play_sfx(preload("res://assets/UI/setting_cog/click.wav"), -10))
	Helper.create_button_clickmask(BackArrow)
	Helper.create_button_clickmask(SettingCog)
	on_setup_screen(preload("res://scenes/screens/main_menu/main_menu.tscn").instantiate())
	
	var modified_time: int = Settings.clear_backup_files_array[Settings.clear_backup_files]
	if modified_time > 1:
		for file in Helper.return_file_names_recursive("user://save/temp"):
			if FileAccess.get_modified_time(file) < Time.get_unix_time_from_system() - modified_time:
				DirAccess.remove_absolute(file)

func on_screen_change_animation_state(x: bool) -> void:
	screen_change_animation_active = x
	BackArrow.disabled = x
	SettingCog.disabled = x

func sim_pressed(): call_deferred("on_sim_pressed")
func on_sim_pressed():
	for child in get_tree().get_root().get_children(): child.queue_free()
	get_tree().get_root().add_child(preload("res://test/simulation/screens/main/main.tscn").instantiate())
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		on_trigger_screen_history()
		
func on_load_screen(screen_name: String, is_enter: bool) -> void:
	if !screen_change_animation_active:
		fileloader_state = 0
		var screen: Control = load(screen_name).instantiate()
		on_menu_transition(screen, Screens.get_child(0), is_enter)
	
func on_trigger_screen_history() -> void:
	match fileloader_state:
		0:
			if !screen_change_animation_active and screen_history.size() > 0:
				var path: String = screen_history[screen_history.size() - 1]
				on_load_screen(path, false)
				screen_history.resize(screen_history.size() - 1)
		2: Screens.get_child(0).get_node("FileLoader").on_exit_button_pressed.call()
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: on_user_quit()
func _on_setting_cog_pressed():
	on_load_screen("res://scenes/screens/settings_menu/settings_menu.tscn", true)
func on_load_world(world: Node3D) -> void:
	$Background.visible = world == null
	for child in World.get_node("Scene").get_children(): child.queue_free()
	if world != null: World.get_node("Scene").add_child(world)
