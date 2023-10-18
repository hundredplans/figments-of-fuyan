extends Control

const LENGTH: float = 0.43
var weight: float = 0
var original_position := Vector2.ZERO

var lerp_item: int = 0
@onready var AniItem: Sprite2D = $AnimationItem
@onready var screen_change: Array = [
["Play", ""],
["Simulation", get_parent().get_parent().get_parent().sim_pressed],
["EditorMenu", "res://scenes/screens/editor_menu/editor_menu.tscn"],
["SettingsMenu", "res://scenes/screens/settings_menu/settings_menu.tscn"],
["Fuyanopedia", "res://scenes/screens/fuyanopedia/fuyanopedia.tscn"],
["LevelEditor", "res://scenes/screens/level_editor/level_editor.tscn"],
["Quit", get_parent().get_parent().get_parent().on_user_quit],
]

func _ready() -> void:
	AniItem.visible = false

func on_move_screen_setup(btn_name: String) -> void:
	AniItem.visible = true
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
	
