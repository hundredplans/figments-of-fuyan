extends Node

@onready var MusicPlayer: AudioStreamPlayer = %MusicPlayer
var is_mute: bool

func onPlayMusic(stream: AudioStream = null) -> void:
	if Helper.admin_datastore.NO_MUSIC: return
	MusicPlayer.stream = stream
	MusicPlayer.play()

func onMute() -> void:
	is_mute = !is_mute
	MusicPlayer.volume_db = -100 if is_mute else -12

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MuteMusic"):
		onMute()
		
