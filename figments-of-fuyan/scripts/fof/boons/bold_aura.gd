extends BoonGD

var max_kills: int
var kills_remaining: int

func onFofInit() -> void:
	max_kills = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Damager is CardGD and action.Damager.isAlly(0) and kills_remaining > 0 and action.Damager.info.id != 1:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onUpdateAscenscion() -> void:
	super()

func getDescription() -> String:
	return Helper.getDescription(super(), [kills_remaining])

func onBoon(action: Action = null) -> void:
	kills_remaining -= 1
	onPushAction(StatAction.new(StatInfo.new(action.Damager, Game.Stats.MAX_HEALTH, 1)))

func onBoonAdded() -> void:
	kills_remaining = max_kills
	
func getCharges() -> int:
	return kills_remaining
	
func getDisabled() -> bool:
	return kills_remaining == 0
	
func onSave() -> SavedDataBoon:
	ability_save['max_kills'] = max_kills
	ability_save['kills_remaining'] = kills_remaining
	return super()
