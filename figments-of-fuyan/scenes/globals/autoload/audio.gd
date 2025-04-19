extends Node

@onready var MusicPlayer: AudioStreamPlayer = %MusicPlayer

func onPlayMusic(stream: AudioStream = null) -> void:
	if Helper.admin_datastore.NO_MUSIC: return
	MusicPlayer.stream = stream
	MusicPlayer.play()
