extends Node

var equipped_theme: int = 0
var interact_button: int = 0
var level_size: int = 0
var hide_patch_notes_menu: int = 0
var open_patch_notes_menu: int = 0
var cards_can_delete_directory: int = 0
var auto_create_dir: int = 0
var confirm_file_delete: int = 0
var hide_menu_gui: int = 0
var book_font_size: int = 0
var clear_backup_files: int = 0
var default_camera_speed_multiplier: int = 1
var autoskip_turn: bool = false
var close_fileloader := Vector2i(0, return_max_mc_value("res://scenes/screens/settings_menu/mc_button_infos/close_fileloader.tres"))
var fileloader_opacity: int = 0

var level_editor_elevation: int = 0
var default_wall_height: int = 0
var elevation_fill: int = 0
var tile_walls: int = 0
var select_empty_tiles: int = 0
var lasso_select: int = 0
var highlight_empty_tiles: int = 0
var keep_rotation: int = 0

var notify_rewards: int = 0
var level_id: int = 0
const clear_backup_files_array: Array = [0, 86400, 259200, 604800, 2592000, 1]

var autopass_turn: int = 0
var autopass_unit_turn: int = 0
var autopass_handphase: int = 0

var settings_info: Dictionary = {
	"Audio": [],
	"Controls": [],
	"Graphics": [],
	"Preferences": [],
	"Video": [],
}

func return_max_mc_value(path: String) -> int:
	return int(pow(float(2), float(load(path).options.size())))

func update_settings_file_info() -> void:
	for setting in settings_info.keys():
		var contents: String = settings_info[setting].reduce(func(a: String, x: Array): return a + (x[0] + ": " + str(x[1]) + "\n"), "")
		Helper.write_to_file("user://save/settings/current/", setting, ".txt", contents)

func update_settings_info(i: int, setting: String, setting_name: String) -> void:
	if settings_info.has(setting):
		for child in settings_info[setting]:
			if child[0] == setting_name:
				child[1] = i
				break

func return_setting_file_info(file: String) -> Array:
	if !file.ends_with(".txt"): file = file + ".txt"
	var dir_path: String = "user://save/settings/current/"
	return Array(Helper.return_file_contents(dir_path + file).split("\n", false))\
	.map(func(x: String): var split: Array = x.split(":", false); return [split[0], int(split[1])])

func _init() -> void:
	for file in DirAccess.get_files_at("user://save/settings/current/"):
		on_trigger_setting(file)

func on_trigger_setting(file: String) -> void:
	var info: Array = return_setting_file_info(file)
	for setting in info:
		var method_name: String = "set_" + setting[0].to_lower()
		if has_method(method_name): call(method_name, setting[1])
	settings_info[file.left(-4)] = info

func set_fps(i: int):
	var setting_info: Array = [60, 120, 144, 240, 0]
	Engine.max_fps = setting_info[i]
func set_windowmode(i: int):
	var setting_info: Array = [DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	DisplayServer.window_set_mode(setting_info[i])
	
func set_resolution(i: int):
	var setting_info: Array = [Vector2i(1920, 1080)]
	DisplayServer.window_set_size(setting_info[i])
func set_vsync(i: int):
	var setting_info: Array = [DisplayServer.VSYNC_DISABLED, DisplayServer.VSYNC_ENABLED, DisplayServer.VSYNC_ADAPTIVE, DisplayServer.VSYNC_MAILBOX]
	DisplayServer.window_set_vsync_mode(setting_info[i])

func set_defaultcameraspeedmultiplier(i: int):
	var setting_info: Array = [0.5, 1, 2, 4]
	default_camera_speed_multiplier = setting_info[i]
func set_autoskipturn(i: int):
	var setting_info: Array = [false, true]
	autoskip_turn = setting_info[i]
func set_closefileloader(i: int):
	close_fileloader.x = i
func set_fileloaderopacity(i: int):
	fileloader_opacity = i
func set_hidemenugui(i: int):
	hide_menu_gui = i
func set_notifyrewards(i: int):
	notify_rewards = i
func set_clearbackupfiles(i: int):
	clear_backup_files = i
func set_bookfontsize(i: int):
	book_font_size = i
func set_confirmfiledelete(i: int):
	confirm_file_delete = i
func set_autocreatedir(i: int):
	auto_create_dir = i
func set_cardscandeletedirectory(i: int):
	cards_can_delete_directory = i
func set_hidepatchnotesmenu(i: int):
	hide_patch_notes_menu = i
func set_openpatchnotesmenu(i: int):
	open_patch_notes_menu = i
func set_levelsize(i: int):
	level_size = i
func set_interactbutton(i: int):
	interact_button = i
func set_leveleditorelevation(i: int):
	level_editor_elevation = i
func set_defaultwallheight(i: int):
	default_wall_height = i
func set_elevationfill(i: int):
	elevation_fill = i
func set_tilewalls(i: int):
	tile_walls = i
func set_highlightemptytiles(i: int):
	highlight_empty_tiles = i
func set_selectemptytiles(i: int):
	select_empty_tiles = i
func set_lassoselect(i: int):
	lasso_select = i
func set_keeprotation(i: int):
	keep_rotation = i
func set_levelid(i: int):
	level_id = i
func set_autopassturn(i: int):
	autopass_turn = i
func set_autopasshandphase(i: int):
	autopass_handphase = i
func set_autopassunitturn(i: int):
	autopass_unit_turn = i

func set_mastervolume(i: int):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(i * 0.01))
func set_sfxvolume(i: int):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(i * 0.01))
func set_musicvolume(i: int):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(i * 0.01))
func set_vlvolume(i: int): 
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("VL"), linear_to_db(i * 0.01))
