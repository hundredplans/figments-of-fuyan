extends Sprite2D

@export var HYPERSPEED_MULTIPLIER: float = 10
@export var HYPERSPEED_TIME: float = 2
@export var ROTATION_SPEED: float = 0.6

func _process(_delta: float) -> void:
	rotation += _delta * ROTATION_SPEED

func on_hyperspeed() -> void:
	ROTATION_SPEED *= HYPERSPEED_MULTIPLIER
	await get_tree().create_timer(HYPERSPEED_TIME).timeout
	ROTATION_SPEED /= HYPERSPEED_MULTIPLIER
