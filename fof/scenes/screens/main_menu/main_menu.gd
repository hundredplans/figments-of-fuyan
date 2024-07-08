extends Control

const LENGTH: float = 0.43
var weight: float = 0
var original_position := Vector2.ZERO

var lerp_item: int = 0
@onready var AniItem: Sprite2D = $AnimationItem
@onready var screen_change: Array = [
["PlayMenu", "res://scenes/screens/play_menu/play_menu.tscn"],
["Simulation", Helper.main.sim_pressed],
["EditorMenu", "res://scenes/screens/editor_menu/editor_menu.tscn"],
["SettingsMenu", "res://scenes/screens/settings_menu/settings_menu.tscn"],
["Fuyanopedia", "res://scenes/screens/fuyanopedia/fuyanopedia.tscn"],
["ContinueMenu", "res://scenes/screens/continue_menu/continue_menu.tscn"],
["Quit", Helper.main.on_user_quit],
]

func _ready() -> void:
	AniItem.visible = false
	var save_files_size: int = Array(DirAccess.get_files_at("user://save/save_files")).filter(func(x: String): return int(x[0]) in range(1, 6) and x.ends_with(".tres")).size()
	$MenuButtons/ContinueMenu/Button.disabled = save_files_size == 0
	$MenuButtons/PlayMenu/Button.disabled = save_files_size == 5
		
func on_move_screen_setup(btn_name: String) -> void:
	AniItem.visible = true
	
	if $MenuButtons.has_node(btn_name):
		var btn: Control = $MenuButtons.get_node(btn_name)
		btn.visible = false
		
		AniItem.flip_h = btn.flip_h
		if !AniItem.flip_h: AniItem.position = Vector2(btn.position.x - 116, btn.position.y - 435)
		else: AniItem.position = Vector2(btn.position.x - 1078, btn.position.y - 435)
		lerp_item = 1
	
func _process(delta: float) -> void:
	match lerp_item:
		1: lerp_item = 2; original_position = AniItem.position
		2:
			AniItem.position = lerp(original_position, Vector2(0, 0), weight)
			weight += clamp(remap(delta, 0, LENGTH, 0, 1), 0, 1)
	
