extends Node3D
signal escape

@onready var PlayAnimation: Control = %PlayAnimation
@onready var CompileCollisionPoints: Node3D = %CompileCollisionPoints
@onready var Model: Node3D
var path: String
var AniPlayer: AnimationPlayer

func _ready() -> void:
	CompileCollisionPoints.packed_object = load(path.left(-4) + ".tscn")
	CompileCollisionPoints.onInstantiatePackedObject()
	Model = CompileCollisionPoints.TileObject
	AniPlayer = Model.get_node("AnimationPlayer")
	
	for ani in AniPlayer.get_animation_library("").get_animation_list():
		var btn := Button.new()
		btn.text = ani
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.theme = preload("res://assets/UI/roboto/roboto20.tres")
		btn.pressed.connect(on_play_model_animation.bind(ani))
		PlayAnimation.add_child(btn)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):
		onEscape()

func onEscape() -> void:
	escape.emit()
	queue_free()
	
func on_play_model_animation(ani: String) -> void:
	AniPlayer.play(ani)
