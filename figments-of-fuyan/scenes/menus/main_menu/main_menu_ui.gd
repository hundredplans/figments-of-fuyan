extends Control

signal mouse_in_ui
signal load_game

@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var StartBackround: Control = %StartBackground

@export var main_menu_music: AudioStream

var World: Node3D

func onFirstLoad() -> void:
	AniPlayer.play("FirstLoad")

func _ready() -> void:
	Audio.onPlayMusic(main_menu_music)

#region Mouse In UI
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
#endregion
