extends VBoxContainer

@onready var container_one: HBoxContainer = $ContainerOne
@onready var container_two: HBoxContainer = $ContainerTwo

func _get_children() -> Array:
	var arr: Array = []
	for child in get_children():
		for grandchild in child.get_children():
			arr.append(grandchild)
	return arr

func _add_child(node: Node) -> void:
	if container_one.get_child_count() == container_two.get_child_count(): container_one.add_child(node)
	else: container_two.add_child(node)
