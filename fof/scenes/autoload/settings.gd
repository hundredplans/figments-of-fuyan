extends Node

var default_camera_speed_multiplier: int = 1
var autoskip_turn: bool = false
var close_fileloader: int = 256
var notify_rewards: int = 0

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
		call("on_load_" + (file.left(-4)).to_lower(), return_setting_file_info(file))
		
func on_load_video(info: Array) -> void:
	for setting in info:
		var method_name: String = "set_" + setting[0].to_lower()
		if has_method(method_name): call(method_name, setting[1])
	settings_info["Video"] = info
	
func on_load_audio(info: Array) -> void:
	settings_info["Audio"] = info
	
func on_load_preferences(info: Array) -> void:
	for setting in info:
		var method_name: String = "set_" + setting[0].to_lower()
		if has_method(method_name): call(method_name, setting[1])
	settings_info["Preferences"] = info
	
func on_load_controls(info: Array) -> void:
	settings_info["Controls"] = info
	
func on_load_graphics(info: Array) -> void:
	settings_info["Graphics"] = info

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
