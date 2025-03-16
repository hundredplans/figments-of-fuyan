class_name ActionWrapper extends FofGD

var actions: Array
	
func onSave() -> SavedData:
	for action: Action in actions: action.onSave()
	return SavedDataActionWrapper.new(1, false, public_id, actions)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	actions = data.actions
	for action: Action in actions: action.onLoad()
	
func setActions(_actions: Variant = null) -> void:
	if _actions is Array: actions = _actions
	elif _actions is Action: actions = [_actions]
	
	for action: Action in actions: action.owner = self

func hasType(type: GDScript) -> bool:
	return actions.any(func(x: Action): return is_instance_of(x, type))
	
func getType(type: GDScript) -> Array:
	return actions.filter(func(x: Action): return is_instance_of(x, type))
	
func setForType(type: GDScript, value: Variant, property_name: String) -> void:
	var filtered_actions: Array = getType(type)
	for action: Action in filtered_actions:
		action[property_name] = value
		
func getActions() -> Array:
	return actions
	
func onUse() -> void:
	onPushAction(actions)
	
