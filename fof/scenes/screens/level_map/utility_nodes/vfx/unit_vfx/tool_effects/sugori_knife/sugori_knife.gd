extends UnitVFXBase

@onready var Dagger := $Dagger

@export var travel_time: float = 1.2
@export var bottom_pos: float = -0.2
@export var top_pos: float = 0.2
@export var ROTATION_SPEED: int = 300

func _process(delta: float) -> void:
	rotation_degrees.y += delta * ROTATION_SPEED

#func _ready() -> void:
	#var positions: Array = [bottom_pos, bottom_pos if randf() > 0.5 else bottom_pos, top_pos]
	#for i in range(Dagger.get_children().size()):
		#var dagger_model: Node3D = Dagger.get_child(i)
		#dagger_model.position.y = positions[i]
		#onTweenFinished(dagger_model)
#
#func onTweenFinished(dagger_model: Node3D) -> void:
	#var tween := create_tween()
	#tween.tween_property(dagger_model, "position:y", bottom_pos if position.y > 0 else top_pos, travel_time)
	#tween.finished.connect(onTweenFinished)
