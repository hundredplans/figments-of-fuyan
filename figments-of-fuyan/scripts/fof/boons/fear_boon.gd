extends BoonGD

const DEFAULT_STUN_TURNS: int = 2

func onAdvanceTurn(team: int) -> void:
	super(team)
	if team == 1 and charges > 0:
		onPushAction(ChangeBoonChargesAction.new(self, -1))
	
func onBoon(__: Action) -> void:
	var turns: int = getDefaultCharges()
	for EnemyCard in Game.getEnemyUnits(0):
		EnemyCard.onStun(turns)

func onBoonAdded() -> void:
	super()
	
func onLevelStarted() -> void:
	super()
	onPushAction(BoonActivatedAction.new(self, null))
	
func getDefaultCharges() -> int:
	return 2 if tier == 1 else 3

func getDisabled() -> bool:
	return charges == 0
