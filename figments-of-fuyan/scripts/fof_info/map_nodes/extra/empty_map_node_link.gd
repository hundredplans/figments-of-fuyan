class_name EmptyMapNodeLink extends Resource

@export var empty_map_node: EmptyMapNode
@export var is_holy: bool

func _init(_empty_map_node: EmptyMapNode = null, _is_holy: bool = false) -> void:
	empty_map_node = _empty_map_node
	is_holy = _is_holy
