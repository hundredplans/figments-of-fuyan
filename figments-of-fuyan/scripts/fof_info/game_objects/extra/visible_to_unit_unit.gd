class_name VisibleToUnitUnit extends VisibleToUnit

@export var by_tile: bool # Visible because the Tile under the unit is visible

func isVisibleToUnit() -> bool:
	return direct or by_tile

func setByTile(state: bool) -> void:
	by_tile = state
	
func setDirect(state: bool) -> void: # For debugging
	super(state)
