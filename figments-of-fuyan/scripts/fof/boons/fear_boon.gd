extends BoonGD

const DEFAULT_STUN_TURNS: int = 2
const ASCENDED_STUN_TURNS: int = 3

var stun_turns: int
var used_stun: bool
	
func onAdvanceTurn(team: int) -> void:
	super(team)
	if team == 1:
		stun_turns = max(stun_turns - 1, 0)
		onPushAction(BoonActivatedAction.new(self, null))
	
func onBoon(__: Action) -> void:
	if used_stun: return # Exists so charges get updated each turn
	var turns: int = getDefaultStunTurns()
	for EnemyCard in Game.getEnemyUnits(0):
		EnemyCard.onStun(turns)
	used_stun = true

func getDescription() -> String:
	return super()

func onBoonAdded() -> void:
	super()
	
func onLevelStarted() -> void:
	super()
	onResetCharges()
	onPushAction(BoonActivatedAction.new(self, null))
	
func getDefaultStunTurns() -> int:
	return DEFAULT_STUN_TURNS if !ascended else ASCENDED_STUN_TURNS

func getDisabled() -> bool:
	return stun_turns == 0

func getCharges() -> int:
	return stun_turns
	
func onResetCharges() -> void:
	used_stun = false
	stun_turns = getDefaultStunTurns()

func onSave() -> SavedDataBoon:
	ability_save['used_stun'] = used_stun
	ability_save['stun_turns'] = stun_turns
	return super()
