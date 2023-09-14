extends Node

var book_font_size: int = 0
var clear_backup_files: int = 0
var default_camera_speed_multiplier: int = 1
var autoskip_turn: bool = false
var close_fileloader: int = 256
var notify_rewards: int = 0
const clear_backup_files_array: Array = [0, 86400, 259200, 604800, 2592000, 1]

var settings_info: Dictionary = {
	"Audio": [],
	"Controls": [],
	"Graphics": [],
	"Preferences": [],
	"Video": [],
}

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
	close_fileloader = i
func set_notifyrewards(i: int):
	notify_rewards = i
func set_clearbackupfiles(i: int):
	clear_backup_files = i
func set_bookfontsize(i: int):
	book_font_size = i

func set_mastervolume(i: int):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(i * 0.01))
func set_sfxvolume(i: int):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(i * 0.01))
func set_musicvolume(i: int):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(i * 0.01))
func set_vlvolume(i: int): 
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("VL"), linear_to_db(i * 0.01))
