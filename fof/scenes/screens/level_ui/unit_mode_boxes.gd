extends VBoxContainer

@onready var container_one: HBoxContainer = $ContainerOne
@onready var container_two: HBoxContainer = $ContainerTwo

func _get_children() -> Array:
	var arr: Array = []
	for child in get_children():
		for grandchild in getValidChildren(child):
			arr.append(grandchild)
	return arr

func _add_child(node: Node) -> void:
	if getValidChildren(container_one).size() == getValidChildren(container_two).size(): container_one.add_child(node)
	else: container_two.add_child(node)

func getValidChildren(container: HBoxContainer) -> Array: return container.get_children().filter(func(x: Node): return !x.is_queued_for_deletion())
