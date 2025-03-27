class_name BountyKills extends Resource

const DUELIST_KILL_MULTIPLIER: int = 2
@export var kills: int # Duels count as 2 
@export var last_claimed_kills: int

func onIncrementBountyKills(duelist_kill: bool) -> void:
	kills += 1 * (DUELIST_KILL_MULTIPLIER if duelist_kill else 1)

func getKills() -> int:
	return kills
	
func getLastClaimedKills() -> int:
	return last_claimed_kills
	
func setLastClaimedKills(_last_claimed_kills: int) -> void:
	last_claimed_kills = _last_claimed_kills 
