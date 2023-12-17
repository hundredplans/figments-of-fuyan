extends Control
@onready var CS: CollisionShape2D = $Area2D/CollisionShape2D
signal queued
func _process(_delta: float):
	if Input.is_action_just_pressed("LeftClick") and !Input.is_action_just_pressed("ShiftLeftClick")\
	and !Rect2(CS.global_position - (CS.shape.size / 2), CS.shape.size).has_point(get_viewport().get_mouse_position()):
		queued.emit()
