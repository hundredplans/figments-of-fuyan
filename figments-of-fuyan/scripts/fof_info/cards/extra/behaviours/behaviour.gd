class_name Behaviour extends Resource

func getCombatTiles(_Card: CardGD, _tiles: Array, _attackables: Array, _allies: Array) -> Dictionary:
	return {}
	
func getOutOfCombatTiles(_Card: CardGD, _tiles: Array, _allies: Array, _enemies: Array) -> Dictionary:
	return {}

func isOutOfCombatBehaviour() -> bool:
	return false

func isCombatBehaviour() -> bool:
	return false
