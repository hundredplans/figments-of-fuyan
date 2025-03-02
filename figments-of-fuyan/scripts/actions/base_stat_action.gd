class_name BaseStatAction extends Action

var Card: CardGD
var types: Array
var values: Array

func _init(_Card: CardGD = null, _types: Variant = null, _values: Variant = null) -> void:
	super()
	
	Card = _Card
	if _types is Array: types = _types
	elif _types is int: types = [_types]
	
	if _values is Array: values = _values
	elif _values is int: values = [_values]
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass
