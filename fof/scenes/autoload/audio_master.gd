extends Node
@onready var music_stream: AudioStreamPlayer = $MusicStream
@onready var sfx_container: Node = $SFXContainer

var loop_sfx: Array = ["sand_walk"]

@onready var sfx_library: Dictionary = {
	"confirm_default": [preload("res://assets/sounds/confirmation/confirm_default.wav"), -10],
	"unconfirm_default": [preload("res://assets/sounds/confirmation/unconfirm_default.wav"), -10],
	"lock_open": [preload("res://scenes/editor/edit_file_name/lock_button/lock_open_sfx.wav"), -15],
	"lock_closed": [preload("res://scenes/editor/edit_file_name/lock_button/lock_closed_sfx.wav"), 0],
	"hard_click": [preload("res://assets/UI/setting_cog/click.wav"), -10],
	"mouse_click": [preload("res://scenes/screens/main_menu/equipped_theme/0/click.wav"), 0],
	"page_flip": [preload("res://scenes/screens/settings_menu/card_flip.wav"), 0],
	"woosh": [preload("res://scenes/ui_general/arrow/woosh.wav"), 0],
	"sand_walk": [preload("res://assets/sounds/walk/sand_walk.wav"), 0]
}

func _ready() -> void:
	for sfx in sfx_library:
		if sfx in loop_sfx:
			sfx_library[sfx][0].loop_mode = AudioStreamWAV.LOOP_FORWARD
			sfx_library[sfx][0].loop_end = sfx_library[sfx][0].data.size()

func play_sfx(sfx: String, volume_offset: int = 0, early_cutoff: float = 0) -> void:
	for child in sfx_container.get_children():
		if !child.playing:
			child.stream = sfx_library[sfx][0]
			child.volume_db = sfx_library[sfx][1] + volume_offset
			child.play()
			if early_cutoff > 0:
				await get_tree().create_timer(early_cutoff).timeout
				child.stop()
			return

func play_music(music: AudioStreamWAV) -> void:
	music_stream.stream = music
	$MusicStream.play()
