extends ToolGD

const TIER_ONE_SPEED_DIFF: int = 1
const TIER_TWO_SPEED_DIFF: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if !is_queued_for_deletion() and action.post:
		if action is StatAction and action.hasCard(Card) and isValidSpeedAction(action):
			var stat_action := StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, getSpeedFromAction(action), 0, false, true, true))
			onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolUnequipped() -> void:
	super()
	var speed_diff: int = -TIER_ONE_SPEED_DIFF if tier == 1 else -TIER_TWO_SPEED_DIFF
	var stat_action := StatAction.new(StatInfo.new(Card, [Game.Stats.MAX_SPEED, Game.Stats.ATTACK], [speed_diff, Card.max_speed - Card.speed + speed_diff]))
	stat_action.owner = self
	onPushAction(stat_action)

func onToolHolderAwakened() -> void: # Unit awakens
	super()
	var speed_diff: int = 1 if tier == 1 else 2
	var stat_action := StatAction.new(StatInfo.new(Card, [Game.Stats.MAX_SPEED, Game.Stats.ATTACK], [speed_diff, Card.speed - Card.attack]))
	stat_action.owner = self
	onPushAction(ToolActivatedAction.new(self, stat_action))

func onRetiered(tier: int) -> void:
	super(tier)
	
	if is_queued_for_deletion(): return # Necessary when you retier using console
	var stat_action := StatAction.new(StatInfo.new(Card, Game.Stats.MAX_SPEED, 1 if tier == 1 else -1, 0, false, true))
	onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolAction(stat_action: StatAction) -> void:
	onPushAction(stat_action)
	
func onCardTurnPassed() -> void:
	super()
	
func onReset(override: bool = false) -> void:
	super(override)
	
func getSpeedFromAction(stat_action: StatAction) -> int:
	var total_speed: int = 0
	for stat_info: StatInfo in stat_action.stat_infos.filter(func(x: StatInfo): return x.Card == Card):
		for i in range(stat_info.types.size()):
			if stat_info.types[i] == Game.Stats.SPEED and stat_info.values[i] != 0:
				total_speed += stat_info.values[i]
	return total_speed

func isValidSpeedAction(stat_action: StatAction) -> bool:
	return getSpeedFromAction(stat_action) != 0
