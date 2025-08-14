extends ToolGD

const TIER_ONE_VISION_RANGE: int = 1
const TIER_TWO_VISION_RANGE: int = 2
const TIER_THREE_VISION_RANGE: int = 3
const TIER_FOUR_VISION_RANGE: int = 4

func onToolEquipped() -> void:
	super()
	var delta: int = getTierVisionRange()
	onPushAction(ToolActivatedAction.new(self, VisionRangeAction.new(Card, delta)))
	
func onToolUnequipped() -> void:
	super()
	var delta: int = -getTierVisionRange()
	onPushAction(ToolActivatedAction.new(self, VisionRangeAction.new(Card, delta)))
	
func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	var new_vision_range: int = getTierVisionRange(tier)
	var old_vision_range: int = getTierVisionRange(old_tier)
	var delta: int = new_vision_range - old_vision_range
	onPushAction(ToolActivatedAction.new(self, VisionRangeAction.new(Card, delta)))
	
func onToolAction(action: VisionRangeAction) -> void:
	onPushAction(action)

func getTierVisionRange(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_VISION_RANGE
		2: return TIER_TWO_VISION_RANGE
		3: return TIER_THREE_VISION_RANGE
		4: return TIER_FOUR_VISION_RANGE
	return 0
