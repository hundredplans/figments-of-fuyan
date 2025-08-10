extends Node

enum {BACKGROUND, SHOP, MAIN_MENU, COCONUT_SPRINGS_BOSS}

@export var background_one_music: AudioStreamMP3
@export var background_two_music: AudioStreamMP3
@export var shop_music: AudioStreamMP3
@export var main_menu_music: AudioStreamMP3
@export var coconut_springs_boss_music: AudioStreamMP3

@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var MusicPlayer: AudioStreamPlayer = %MusicPlayer
@onready var SFXPlayers: Node = %SFXPlayers

var current_enum_value: int = -1 # Start as -1 so its not invalid
var is_mute: bool

func getMusicFromEnum(enum_value: int) -> AudioStream:
	match enum_value:
		BACKGROUND: return [background_one_music, background_two_music].pick_random()
		SHOP: return shop_music
		COCONUT_SPRINGS_BOSS: return coconut_springs_boss_music
		MAIN_MENU: return main_menu_music
	return null

func onPlayMusic(enum_value: int) -> void:
	if enum_value == current_enum_value and MusicPlayer.is_playing(): return
	current_enum_value = enum_value
	if Helper.admin_datastore.NO_MUSIC: return
	
	if MusicPlayer.playing:
		AniPlayer.play("MusicFadeOut")
		await AniPlayer.animation_finished
	
	var stream: AudioStream = getMusicFromEnum(enum_value)
	MusicPlayer.stream = stream
	MusicPlayer.play()
	
	AniPlayer.play("MusicFadeIn")

func onSoundEffect(stream: AudioStream, allow_repeat: bool = true) -> void:
	if !allow_repeat and SFXPlayers.get_children().any(func(x: AudioStreamPlayer): return x.stream == stream): return
	var SFXPlayer := AudioStreamPlayer.new()
	SFXPlayer.volume_db = 0
	SFXPlayer.autoplay = true
	SFXPlayer.stream = stream
	SFXPlayers.add_child(SFXPlayer)
	await SFXPlayer.finished
	SFXPlayer.queue_free()
	
func onMusicFinished() -> void:
	onPlayMusic(BACKGROUND)

func onMute() -> void:
	is_mute = !is_mute
	MusicPlayer.volume_db = -100 if is_mute else -12

func _process(_delta: float) -> void: pass
	#if Input.is_action_just_pressed("MuteMusic"):
		#onMute()
		
