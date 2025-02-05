extends Node3D

var AniPlayer: AnimationPlayer
const IDLE_RARE_MIN_TIME: int = 12
const IDLE_RARE_MAX_TIME: int = 80
@onready var IdleRareTimer: Timer = %IdleRareTimer

func _ready() -> void:
	AniPlayer = get_node("AnimationPlayer")
	AniPlayer.animation_finished.connect(onAnimationFinished)
	AniPlayer.playback_default_blend_time = 0.2
	onIdleRareTimerTimeout()
	AniPlayer.play("Idle")
	
func onAnimationFinished(_ani_name: String) -> void:
	AniPlayer.play("Idle")
	
func onIdleRareTimerTimeout() -> void:
	if AniPlayer.current_animation == "Idle":
		AniPlayer.play("IdleRare" + ("" if randf() > 0.5 else "2"))
	IdleRareTimer.start(randi_range(IDLE_RARE_MIN_TIME, IDLE_RARE_MAX_TIME))

func onBuy() -> void:
	AniPlayer.play("Purchase" + str(range(1, 4).pick_random()))
