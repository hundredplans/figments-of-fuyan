extends BoonGD

const POINTS_TO_UPGRADE: int = 4
const ELITE_FIGHT_POINTS: int = 2
const REGULAR_FIGHT_POINTS: int = 1

var current_points: int = 0
var max_kills: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Damager is CardGD and action.Damager.isAlly(0) and action.Damager.isValidRampage(action)\
		and charges > 0 and action.Damager.info.id != 1:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onLevelEnded(is_win: bool) -> void:
	super(is_win)
	var level: LevelGD = Game.getArea().active_level
	if level == null or level.isEpic(): return
	
	current_points += REGULAR_FIGHT_POINTS if !level.isElite() else ELITE_FIGHT_POINTS
	if current_points >= POINTS_TO_UPGRADE:
		current_points = 0
		max_kills += 1
		onResetCharges()
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return Helper.getDescription(super(), [charges])

func onBoon(action: Action = null) -> void:
	onPushAction(ChangeBoonChargesAction.new(self, -1))
	onPushAction(StatAction.new(StatInfo.new(action.Damager, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [1, 1])))

func onBoonAdded() -> void:
	super()
	
func getDisabled() -> bool:
	return charges == 0
	
func getDefaultCharges() -> int:
	return max_kills
	
func onSave() -> SavedDataBoon:
	ability_save['max_kills'] = max_kills
	ability_save['current_points'] = current_points
	return super()
