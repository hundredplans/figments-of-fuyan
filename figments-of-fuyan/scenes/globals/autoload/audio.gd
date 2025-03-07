extends Node

@onready var MusicPlayer: AudioStreamPlayer = %MusicPlayer

func onPlayMusic(stream: AudioStreamWAV) -> void:
	if Helper.admin_datastore.NO_MUSIC: return
	MusicPlayer.stream = stream
	MusicPlayer.play()
