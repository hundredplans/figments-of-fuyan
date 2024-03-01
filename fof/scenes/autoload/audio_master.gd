extends Node

var ID_TO_HOVER_SFX: Dictionary = {
	1: "FightHover",
	2: "EliteFightHover",
	3: "MinibossHover",
	4: "BossHover",
	5: "EncounterHover",
	6: "ShopHover",
}

@onready var music_stream: AudioStreamPlayer = $MusicStream
@onready var sfx_container: Node = $SFXContainer
var all_sfx: Array = Array(DirAccess.get_files_at("res://assets/sounds/")).filter(func(x: String): return !x.ends_with(".import"))

func play_sfx(sfx: String, volume_absolute: int = 0, early_cutoff: float = 0) -> AudioStreamPlayer:
	if !sfx.is_empty():
		if sfx_container.get_children().all(is_playing_sfx.bind(sfx)):
			for child in sfx_container.get_children():
				if !child.playing:
					child.playing_sfx = sfx
					var random_sfx: Array = all_sfx.filter(func(x: String): return x.begins_with(sfx))
					if random_sfx.size() > 0:
						child.stream = load("res://assets/sounds/" + random_sfx[randi() % random_sfx.size()])
						child.volume_db = volume_absolute
						child.play()
						if early_cutoff > 0:
							get_tree().create_timer(early_cutoff).timeout.connect(on_cutoff_sfx.bind(child))
						else: return child
					return null
	return null
	
func on_cutoff_sfx(stream_player: AudioStreamPlayer) -> void:
	stream_player.stop()
	stream_player.finished.emit()
	
func is_playing_sfx(player: AudioStreamPlayer, sfx: String) -> bool:
	return player.playing_sfx != sfx

func play_music(music: AudioStreamWAV) -> void:
	music_stream.stream = music
	$MusicStream.play()
