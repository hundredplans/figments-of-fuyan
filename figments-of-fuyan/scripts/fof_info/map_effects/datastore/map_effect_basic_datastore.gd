class_name MapEffectBasicDatastore extends MapEffectDatastore

@export var id: int

func getSavedData() -> SavedDataMapEffect:
	return SavedDataMapEffect.new(id)
