extends Node2D

@onready var Pivot: Node2D = %Pivot
@onready var ArtMini: Sprite2D = %ArtMini
var to: Vector3
var Camera: Camera3D
const DEATH_DELAY: float = 3
func setInfo(Unit: UnitGD, _Camera: Camera3D, _to: Vector3) -> void:
	ArtMini.texture = load("res://assets/base_game/cards/cards/" + Unit.base_card.folder_name + "/art_mini.png")
	Camera = _Camera
	to = _to

func _ready() -> void:
	position = Vector2(randi_range(200, 1600), 10)
	await get_tree().create_timer(DEATH_DELAY).timeout
	queue_free()

func _process(_delta: float) -> void:
	Pivot.look_at(Camera.unproject_position(to))
