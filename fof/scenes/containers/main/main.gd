extends Node

@export var SettingCog: TextureButton
@export var BackArrow: TextureButton

@onready var MoveScreen: AnimationPlayer = $UI/MoveScreen
@onready var Screens: Control = $UI/Screens
@onready var World: Node3D = $World
@onready var WorldEnv: WorldEnvironment = $World/WorldEnvironment

@onready var MoveLibrary: AnimationLibrary = $UI/MoveScreen.get_animation_library("")

const main_menu_path: String = "res://scenes/screens/main_menu/main_menu.tscn"
var fileloader_state: int = 0
var screen_change_animation_active: bool = false
var screen_history: Array = []
var move_screen_switch_length: Dictionary = {
	"MainMenu": 0.5,
}

func on_user_quit() -> void:
	Settings.update_settings_file_info()
	get_tree().quit()
	
const move_screen_name_to_path: Dictionary = {
	"MainMenu": "res://scenes/screens/main_menu/move_screen.tres",
}
	
func _ready() -> void:
	$UI/CardUI.set_info(Helper.id_to_dict(150, "Card"))
	Helper.main = self
	load_general_world()
	$UI.z_index = 10
	for screen in Screens.get_children(): screen.free()
	BackArrow.visible = false
	SettingCog.visible = false
	
	SettingCog.pressed.connect(func(): AudioMaster.play_sfx("hard_click"))
	Helper.create_button_clickmask(BackArrow)
	Helper.create_button_clickmask(SettingCog)
	on_setup_screen(preload("res://scenes/screens/main_menu/main_menu.tscn").instantiate())
	
	var modified_time: int = Settings.clear_backup_files_array[Settings.clear_backup_files]
	if modified_time > 1:
		for file in Helper.return_file_names_recursive("user://save/temp"):
			if FileAccess.get_modified_time(file) < Time.get_unix_time_from_system() - modified_time:
				DirAccess.remove_absolute(file)
	
func on_menu_transition(screen: Control, old_screen: Control, is_enter: bool) -> void:
	on_setup_screen(screen)
	if old_screen.has_method("on_move_screen_setup"):
		old_screen.on_move_screen_setup(screen.name)
	on_screen_change_animation_state(true)
	screen.visible = false
	var screen_path: String = "res://scenes/ui_general/move_screen.tres"
	if move_screen_name_to_path.has(old_screen.name): screen_path = move_screen_name_to_path[old_screen.name]
	MoveLibrary.add_animation(old_screen.name, load(screen_path))
	if is_enter:
		MoveScreen.play(old_screen.name)
		screen_history.append(old_screen.scene_file_path)
	else: MoveScreen.play_backwards(old_screen.name)
	
	var length: float = 0.3
	if move_screen_switch_length.has(old_screen.name): length = move_screen_switch_length[old_screen.name]
	Helper.on_timer_end(on_move_screen_switch, [screen], length)
	
	if length == 0.3:
		await get_tree().create_timer(length).timeout
		old_screen.visible = false
	
func on_change_screen_visible_delay(screen: Control) -> void: screen.visible = true
	
func on_menu_button_pressed(i: Variant) -> void:
	match typeof(i):
		TYPE_CALLABLE: i.call()
		TYPE_STRING: on_load_screen(i, true)
	
func _on_move_screen_animation_finished(animation_name: String):
	var screen: Control = Screens.get_child(1)
	if screen.has_method("_queue_free"): screen._queue_free()
	screen.queue_free()
	
	MoveScreen.current_animation = ""
	MoveLibrary.remove_animation(animation_name)
	on_screen_change_animation_state(false)

func on_move_screen_switch(screen: Control) -> void:
	screen.visible = true
	if screen.has_method("on_move_screen_switch"):
		screen.on_move_screen_switch.call()

func on_setup_screen(screen: Control) -> void:
	before_ready_connect_screen(screen)
	Screens.add_child(screen)
	Screens.move_child(screen, 0)
	after_ready_connect_screen(screen)
	if screen.get("screen_change"):
		for i in screen.screen_change:
			screen.get_node("MenuButtons/" + i[0]).pressed.connect(on_menu_button_pressed.bind(i[1]))
	
	if screen.get("screen_change_sig"): screen.screen_change_sig.connect(on_menu_button_pressed)

func before_ready_connect_screen(screen: Control):
	if screen.get("equip_sky"): screen.equip_sky.connect(on_equip_sky)
	match screen.name:
		"MapMenu", "LevelUI": screen.GameState = GameState
	
	match screen.name:
		"LevelEditor", "LoreBooksEditor", "ItemEditor", "MapMenu", "LevelUI": screen.load_world.connect(on_load_world)
	
	match screen.name:
		"TrinketEditor", "AreaEditor", "BoonEditor", "CardEditor", "LevelEditor", "MapEditor", "ToolEditor", "TaskEditor", "ChallengeEditor", "EncounterEditor": screen.fileloader_state.connect(on_change_fileloader_state)
	
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
		_: 
			if BackArrow.position.x > 1768: BackArrow.position.x = 1768
	get_viewport().warp_mouse(get_viewport().get_mouse_position())
	
func on_change_fileloader_state(i: int) -> void: fileloader_state = i


func on_screen_change_animation_state(x: bool) -> void:
	screen_change_animation_active = x
	BackArrow.disabled = x
	SettingCog.disabled = x

func sim_pressed(): call_deferred("on_sim_pressed")
func on_sim_pressed():
	for child in get_tree().get_root().get_children(): child.queue_free()
	var main: Control = preload("res://test/simulation/screens/main/main.tscn").instantiate()
	main.name = "SimulationMain"
	get_tree().get_root().add_child(main)
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		on_trigger_screen_history()
		
func on_load_screen(screen_name: String, is_enter: bool) -> void:
	if !screen_change_animation_active:
		fileloader_state = 0
		var screen: Control = load(screen_name).instantiate()
		on_menu_transition(screen, Screens.get_child(0), is_enter)

var RETURN_EXTRA: Array = [
	["play_menu.tscn", 2],
	["continue_menu.tscn", 2],
	["map_menu.tscn", 3],
]

func on_trigger_screen_history() -> void:
	match fileloader_state:
		0:
			if !screen_change_animation_active and screen_history.size() > 0:
				var path: String = screen_history[screen_history.size() - 1]
				for i in RETURN_EXTRA:
					if path.ends_with(i[0]):
						path = screen_history[screen_history.size() - i[1]]
						on_load_screen(path, false)
						screen_history.resize(screen_history.size() - i[1])
						return
				
				on_load_screen(path, false)
				screen_history.resize(screen_history.size() - 1)
					
		2: Screens.get_child(0).get_node("FileLoader").on_exit_button_pressed.call()
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: on_user_quit()
func _on_setting_cog_pressed():
	on_load_screen("res://scenes/screens/settings_menu/settings_menu.tscn", true)
	
func on_load_world(world: Node3D) -> void:
	if world == null: load_general_world()
	elif $World/General.get_child_count() > 0: $World/General.get_child(0).queue_free()
	
	for child in World.get_node("Scene").get_children(): child.queue_free()
	if world != null:
		World.get_node("Scene").add_child(world)

func load_general_world() -> void:
	$World/General.add_child(load("res://assets/env/main_menu/" + str(Settings.equipped_theme) + ".tscn").instantiate())
	on_equip_sky(Settings.equipped_theme, true)

func on_equip_sky(value: int, is_theme: bool) -> void:
	if is_theme: WorldEnv.environment = load("res://scenes/world/equipped_theme/" + str(value) + "/env.tres")
	else: WorldEnv.environment = load("res://assets/base_game/areas/" + Helper.id_to_bgfn(value, "Area") + "/env.tres")

var GameState: Node
