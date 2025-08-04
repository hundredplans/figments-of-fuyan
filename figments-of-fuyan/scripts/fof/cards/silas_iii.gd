extends CardGD

const TIER_ONE_DAMAGE: int = 1
const TIER_TWO_DAMAGE: int = 1
const TIER_THREE_DAMAGE: int = 1
const TIER_FOUR_DAMAGE: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action):
		onPushAction(RampageAction.new(self, action))
		
func onRampage(action: DeathAction) -> void:
	var enemies: Array = getVisibleFieldCardsEnemies()
	var damage_action := DamageAction.new(self, enemies, getTierDamage(), Game.DamageTypes.OTHER)
	var debuff_action := StatAction.new(enemies.map(func(x: CardGD):\
		return StatInfo.new(x, Game.Stats.MAX_SPEED, -1, 3)))
	var actions: Array = [damage_action, debuff_action]
	onPushAction(actions)

func getTierDamage() -> int:
	match tier:
		1: return TIER_ONE_DAMAGE
		2: return TIER_TWO_DAMAGE
		3: return TIER_THREE_DAMAGE
		4: return TIER_FOUR_DAMAGE
	return 0
