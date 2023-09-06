extends Node
@onready var music_stream: AudioStreamPlayer = $MusicStream
@onready var sfx_container: Node = $SFXContainer

var vl_volume_multiplier: int = 100
var master_volume_multiplier: int = 100
var music_volume_multiplier: int = 100
var sfx_volume_multiplier: int = 100

func play_sfx(sfx: AudioStreamWAV, volume := 0) -> void:
	for child in sfx_container.get_children():
		if !child.playing:
			child.stream = sfx
			child.volume_db = volume
			child.play()
			return

func play_music(music: AudioStreamWAV) -> void:
	music_stream.stream = music
	$MusicStream.play()
