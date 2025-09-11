class_name SavedDataActionWrapper extends SavedData

@export var actions: Array
@export var chosen_index: int

func _init(_id: int = 1, _first_init: bool = false, _public_id: int = 0, _actions: Array = [], _chosen_index: int = -1) -> void:
	super(_id, _first_init, _public_id)
	actions = _actions
	chosen_index = _chosen_index

func getInfoType() -> GDScript: return ActionWrapperInfo

func hasType(type: GDScript) -> bool:
	return actions.any(func(x: Action): return is_instance_of(x, type))
	
func getType(type: GDScript) -> Array:
	return actions.filter(func(x: Action): return is_instance_of(x, type))
