extends BoonGD

const DEFAULT_STUN_TURNS: int = 2
const ASCENDED_STUN_TURNS: int = 3

func onAdvanceTurn(team: int) -> void:
	super(team)
	if team == 1 and charges > 0:
		onPushAction(ChangeBoonChargesAction.new(self, -1))
	
func onBoon(__: Action) -> void:
	var turns: int = getDefaultCharges()
	for EnemyCard in Game.getEnemyUnits(0):
		EnemyCard.onStun(turns)

func getDescription() -> String:
	return super()

func onBoonAdded() -> void:
	super()
	
func onLevelStarted() -> void:
	super()
	onPushAction(BoonActivatedAction.new(self, null))
	
func getDefaultCharges() -> int:
	return DEFAULT_STUN_TURNS if !ascended else ASCENDED_STUN_TURNS

func getDisabled() -> bool:
	return charges == 0
