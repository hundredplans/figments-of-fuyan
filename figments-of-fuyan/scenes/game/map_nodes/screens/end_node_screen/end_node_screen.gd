extends MapNodeScreen

@onready var AniPlayer: AnimationPlayer = %AniPlayer

func _ready() -> void:
	AniPlayer.play("Entrance")

func onEntranceFinished() -> void:
	Game.getSaveFile().onAreaFinished()
