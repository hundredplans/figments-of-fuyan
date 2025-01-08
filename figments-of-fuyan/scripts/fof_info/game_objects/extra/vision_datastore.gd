class_name VisionDatastore extends Resource

@export var level_visible: bool
@export var reveals: Array[RevealedDatastore]
@export var last_seen_by_enemy: int

func onResetLastSeenByEnemy() -> void:
	last_seen_by_enemy = 0
	
func isRevealed(team: int) -> bool: # Which team it is revealed to
	if reveals.is_empty(): return false
	
	for reveal_datastore in reveals:
		if reveal_datastore.team == -1 or reveal_datastore.team == team:
			return true
	
	return false
	
func onRevealed(revealed_datastore: RevealedDatastore) -> void:
	reveals.append(revealed_datastore)
	
func onRemoveReveal(revealed_id: int) -> void:
	for revealed_datastore in reveals:
		if revealed_datastore.revealed_id == revealed_id:
			reveals.erase(revealed_datastore)
			break
