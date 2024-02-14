extends Node

var ID_TO_HOVER_SFX: Dictionary = {
	1: "fight_hover",
	2: "elite_fight_hover",
	3: "miniboss_hover",
	4: "boss_hover",
	5: "encounter_hover",
	6: "shop_hover",
}

@onready var music_stream: AudioStreamPlayer = $MusicStream
@onready var sfx_container: Node = $SFXContainer
@onready var sfx_library: Dictionary = {
	"confirm_default": [preload("res://assets/sounds/confirmation/confirm_default.wav"), -10],
	"unconfirm_default": [preload("res://assets/sounds/confirmation/unconfirm_default.wav"), -10],
	"lock_open": [preload("res://scenes/editor/edit_file_name/lock_button/lock_open_sfx.wav"), -15],
	"lock_closed": [preload("res://scenes/editor/edit_file_name/lock_button/lock_closed_sfx.wav"), 0],
	"hard_click": [preload("res://assets/UI/setting_cog/click.wav"), -10],
	"mouse_click": [preload("res://scenes/screens/main_menu/equipped_theme/0/click.wav"), 0],
	"page_flip": [preload("res://scenes/screens/settings_menu/card_flip.wav"), 0],
	"woosh": [preload("res://scenes/ui_general/arrow/woosh.wav"), 0],
	"sand_walk": [preload("res://assets/sounds/walk/sand_walk.wav"), 0],
	"water_walk": [preload("res://assets/sounds/walk/water_walk.wav"), 0],
	"fight_hover": [preload("res://assets/env/area_map/map_nodes/1.wav"), -10],
	"elite_fight_hover": [preload("res://assets/env/area_map/map_nodes/2.wav"), 0],
	"miniboss_hover": [preload("res://assets/env/area_map/map_nodes/3.wav"), 0],
	"boss_hover": [preload("res://assets/env/area_map/map_nodes/4.wav"), 0],
	"encounter_hover": [preload("res://assets/env/area_map/map_nodes/5.wav"), 0],
	"shop_hover": [preload("res://assets/env/area_map/map_nodes/6.wav"), 0],
	"charge_deep": [preload("res://assets/sounds/arrive/charge_deep.wav"), 0],
}

func play_sfx(sfx: String, volume_offset: int = 0, early_cutoff: float = 0) -> AudioStreamPlayer:
	if sfx_container.get_children().all(is_playing_sfx.bind(sfx)):
		for child in sfx_container.get_children():
			if !child.playing:
				child.playing_sfx = sfx
				child.stream = sfx_library[sfx][0]
				child.volume_db = sfx_library[sfx][1] + volume_offset
				child.play()
				if early_cutoff > 0:
					get_tree().create_timer(early_cutoff).timeout.connect(on_cutoff_sfx.bind(child))
				else: return child
	return null
	
func on_cutoff_sfx(stream_player: AudioStreamPlayer) -> void:
	stream_player.stop()
	stream_player.finished.emit()
	
func is_playing_sfx(player: AudioStreamPlayer, sfx: String) -> bool:
	return player.playing_sfx != sfx

func play_music(music: AudioStreamWAV) -> void:
	music_stream.stream = music
	$MusicStream.play()
