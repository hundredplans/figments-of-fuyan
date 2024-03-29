extends Node3D
signal escape

@onready var CompileCollisionPoints: Node3D = %CompileCollisionPoints
@onready var Model: Node3D
var path: String

func _ready() -> void:
	CompileCollisionPoints.packed_object = load(path.left(-4) + ".tscn")
	CompileCollisionPoints.onInstantiatePackedObject()
	Model = CompileCollisionPoints.TileObject

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):
		onEscape()

func onEscape() -> void:
	escape.emit()
	queue_free()
