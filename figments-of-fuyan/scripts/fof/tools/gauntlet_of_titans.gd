extends ToolGD

const TIER_ONE_ATTACK: int = -1
const TIER_TWO_ATTACK: int = -1
const TIER_THREE_ATTACK: int = -1
const TIER_FOUR_ATTACK: int = -1

const TIER_ONE_MAX_HP: int = 2
const TIER_TWO_MAX_HP: int = 3
const TIER_THREE_MAX_HP: int = 4
const TIER_FOUR_MAX_HP: int = 5

func onToolEquipped() -> void:
	super()
	
func onToolHolderAwakened() -> void:
	super()
	var stat_action := StatAction.new(StatInfo.new(Card,\
		[Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH],\
		[getTierAttack(), getTierMaxHp(), getTierMaxHp()]))
	onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolUnequipped() -> void:
	super()
	var stat_action := StatAction.new(StatInfo.new(Card,\
		[Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH],\
		[-getTierAttack(), -getTierMaxHp(), -getTierMaxHp()]))
	onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	
	var current_attack_buff: int = getTierAttack(tier)
	var current_health_buff: int = getTierMaxHp(tier)
	var old_attack_buff: int = getTierAttack(old_tier)
	var old_health_buff: int = getTierMaxHp(old_tier)
	var new_attack: int = current_attack_buff - old_attack_buff
	var new_health: int = current_health_buff - old_health_buff
	
	var stat_action := StatAction.new(StatInfo.new(Card,\
		[Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH],\
		[new_attack, new_health, new_health]))
	onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolAction(action: StatAction) -> void:
	onPushAction(action)
	
func getTierMaxHp(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_MAX_HP
		2: return TIER_TWO_MAX_HP
		3: return TIER_THREE_MAX_HP
		4: return TIER_FOUR_MAX_HP
	return 0
	
func getTierAttack(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
