extends BoonGD

const DEFAULT_STUN_TURNS: int = 2
const ASCENDED_STUN_TURNS: int = 3

var used_stun: bool
	
func onBoon(__: Action) -> void:
	var turns: int = getStunTurns()
	for EnemyCard in Game.getEnemyUnits(0):
		EnemyCard.onStun(turns)
	used_stun = true

func getDescription() -> String:
	return super()

func onBoonAdded() -> void:
	super()
	onResetCharges()
	onPushAction(BoonActivatedAction.new(self, null))
	
func getStunTurns() -> int:
	return DEFAULT_STUN_TURNS if !ascended else ASCENDED_STUN_TURNS

func getDisabled() -> bool:
	return used_stun

func getCharges() -> int:
	return getStunTurns()

func onResetCharges() -> void:
	used_stun = false

func onSave() -> SavedDataBoon:
	ability_save['used_stun'] = used_stun
	return super()
