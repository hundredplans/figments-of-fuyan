class_name Container3D
extends Node3D

@export var offset: float = 0.2
	
func on_sort_children() -> void:
	var children: Array = get_children().filter(func(x: Node3D): return !x.is_queued_for_deletion() and x.is_inside_tree())
	var start_offset: float = -((offset / 2) * (children.size() - 1))
	var x_offset: float = -0.1 if children.size() >= 2 else 0.0
	for i in range(children.size()):
		children[i].position.x = start_offset + (offset * i) + x_offset
		
# 1 = 0, 2 = -0.125, 3 = -0.25
