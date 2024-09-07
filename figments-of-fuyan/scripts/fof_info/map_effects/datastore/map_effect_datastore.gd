class_name MapEffectDatastore extends Resource

@export var randomise: bool
func onCheckRandomise() -> void:
	if randomise: call("onRandomise")
