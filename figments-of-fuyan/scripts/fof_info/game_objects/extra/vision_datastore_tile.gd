class_name VisionDatastoreTile extends VisionDatastore

@export var last_seen_by_enemy: int
func onResetLastSeenByEnemy() -> void:
	last_seen_by_enemy = 0
	
func onIncrementLastSeenByEnemy() -> void:
	last_seen_by_enemy += 1
