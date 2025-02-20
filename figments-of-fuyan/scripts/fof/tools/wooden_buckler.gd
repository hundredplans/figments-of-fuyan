extends ToolGD

var buckler_charges: int
var armor_turns_left: int

const ARMOR_TURN_DEFAULT_TURNS: int = 2
const ARMOR_TRAIT_ID: int = 1
const ARMOR_VALUE: int = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if Card != null and Card.isValidRevenge(action) and buckler_charges > 0:
			onPushAction(ToolActivatedAction.new(self, action))
	
func onCardTurnPassed() -> void:
	armor_turns_left = max(armor_turns_left - 1, 0)
	if armor_turns_left == 0:
		onPushAction(RemoveOverworldTraitAction.new(Card, ARMOR_TRAIT_ID, OverworldTrait.AddedBy.BUCKLER))
	
func onToolAction(_action: StatAction) -> void:
	var trait_data := SavedDataArmor.new(ARMOR_TRAIT_ID, true, 0)
	trait_data.armor = ARMOR_VALUE
	armor_turns_left = ARMOR_TURN_DEFAULT_TURNS
	buckler_charges -= 1
	onPushAction(AddOverworldTraitAction.new(Card, OverworldTrait.new(trait_data, OverworldTrait.AddedBy.BUCKLER, true), true))
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()
	onPushAction(RemoveOverworldTraitAction.new(Card, ARMOR_TRAIT_ID, OverworldTrait.AddedBy.BUCKLER))

func onToolHolderAwakened() -> void:
	super()
	onResetCharges()
	
func onToolAscended(state: bool) -> void:
	super(state)
	onResetCharges()
	
func getDescription() -> String:
	return Helper.getDescriptionNumeric(super(), [buckler_charges], [["REVENGE ", "[" + str(getDefaultCharges()) + "]"]])

func onResetCharges() -> void:
	buckler_charges = getDefaultCharges()
	
func getDefaultCharges() -> int:
	return 1 if !ascended else 2
