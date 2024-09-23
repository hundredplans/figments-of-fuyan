class_name GainShillingsDatastore extends MapEffectDatastore

const id: int = 2
@export var shillings: int

func getSavedData() -> SavedDataMapEffect:
	return SavedDataMapEffectGainShillings.new(id, false, shillings)
