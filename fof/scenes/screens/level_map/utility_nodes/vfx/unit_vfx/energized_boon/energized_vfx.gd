extends UnitVFXBase

var Random: RandomGD
@onready var timer: Timer = $BootRareTimer
@onready var AniPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	AniPlayer.play("BootIdle")
	
func onBootRareTimerTimeout() -> void:
	AniPlayer.play("BootRare")
	timer.start(Random.RNG.randi_range(16, 32))
	
func onAniFinished(ani_name: String) -> void:
	if ani_name == "BootRare": AniPlayer.play("BootIdle")
	
