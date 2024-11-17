extends Control

const SPIN_SPEED: float = 10
@onready var ToolIcon: TextureRect = %ToolIcon
@onready var AscendedShine: TextureRect = %AscendedShine

func setInfo(icon: ImageTexture, ascended: bool = false) -> void:
	visible = icon != null
	ToolIcon.texture = icon
	AscendedShine.visible = ascended

func _process(delta: float) -> void:
	if AscendedShine.visible:
		AscendedShine.rotation_degrees += delta * SPIN_SPEED
