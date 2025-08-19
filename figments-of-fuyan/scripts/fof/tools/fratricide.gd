extends ToolGD

const TIER_ONE_ATTACK: int = 0
const TIER_TWO_ATTACK: int = 1
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 3

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is AttackAction and Card == action.Attacker:
			onForceAction(ToolActivatedAction.new(self, action))
			
func onToolAction(action: AttackAction) -> void:
	var defenders: Array = action.Defenders.duplicate()
	var team: int = Card.getTeam()
	for AdjacentTile: TileGD in Game.getAdjacentTiles(Card.getTile()):
		var EnemyCard: CardGD = Game.getEnemyFieldCard(AdjacentTile, team)
		if EnemyCard == null or EnemyCard in defenders: continue
		defenders.append(EnemyCard)
	action.setDefenders(defenders)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, -getTierAttack())))

func onToolHolderAwakened() -> void: # Unit awakens
	super()
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, getTierAttack())))
	
func onToolHolderDeath() -> void: # Unit dies
	super()
	
func onCardTurnPassed() -> void:
	super()
	
func onReset(override: bool = false) -> void: # Level ends
	super(override)

func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	
	var value: int = getTierAttack() - getTierAttack(old_tier)
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, value)))

func getTierAttack(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
