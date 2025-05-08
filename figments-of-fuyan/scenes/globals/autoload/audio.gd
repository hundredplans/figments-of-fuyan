extends Node

@onready var MusicPlayer: AudioStreamPlayer = %MusicPlayer
@onready var SFXPlayers: Node = %SFXPlayers

var is_mute: bool

func onPlayMusic(stream: AudioStream = null) -> void:
	if Helper.admin_datastore.NO_MUSIC: return
	MusicPlayer.stream = stream
	MusicPlayer.play()

func onSoundEffect(stream: AudioStream, allow_repeat: bool = true) -> void:
	if !allow_repeat and SFXPlayers.get_children().any(func(x: AudioStreamPlayer): return x.stream == stream): return
	
	var SFXPlayer := AudioStreamPlayer.new()
	SFXPlayer.volume_db = 0
	SFXPlayer.autoplay = true
	SFXPlayer.stream = stream
	SFXPlayers.add_child(SFXPlayer)
	await SFXPlayer.finished
	SFXPlayer.queue_free()

func onMute() -> void:
	is_mute = !is_mute
	MusicPlayer.volume_db = -100 if is_mute else -12

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MuteMusic"):
		onMute()
		
