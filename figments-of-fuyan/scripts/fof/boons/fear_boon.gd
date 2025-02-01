extends BoonGD

const DEFAULT_STUN_TURNS: int = 2
const ASCENDED_STUN_TURNS: int = 3

var turns_stunned_remaining: int
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangePhaseAction and Game.isAdvanceTurn(action.phase, 0) and turns_stunned_remaining > 0:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(_action: Action = null) -> void:
	turns_stunned_remaining -= 1

func onBoonAdded() -> void:
	onResetCharges()
	for EnemyCard in Game.getEnemyUnits(0):
		EnemyCard.onStun()
	
func getDisabled() -> bool:
	return turns_stunned_remaining == 0

func getCharges() -> int:
	return turns_stunned_remaining

func onResetCharges() -> void:
	turns_stunned_remaining = DEFAULT_STUN_TURNS if !ascended else ASCENDED_STUN_TURNS
