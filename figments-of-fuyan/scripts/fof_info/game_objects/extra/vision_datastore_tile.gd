class_name VisionDatastoreTile extends VisionDatastore

@export var last_seen_by_enemy: int = 10
func onResetLastSeenByEnemy() -> void:
	last_seen_by_enemy = 0
	
func onIncrementLastSeenByEnemy() -> void:
	last_seen_by_enemy += 1
	
func getLastSeenByEnemy() -> int:
	return last_seen_by_enemy
