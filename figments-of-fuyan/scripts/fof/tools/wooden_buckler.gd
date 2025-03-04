extends ToolGD

var buckler_charges: int

const ARMOR_TURN_DEFAULT_TURNS: int = 2
const ARMOR_TRAIT_ID: int = 1
const ARMOR_VALUE: int = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if Card != null and Card.isValidRevenge(action) and buckler_charges > 0:
			onPushAction(ToolActivatedAction.new(self, action))
	
func onToolAction(_action: StatAction) -> void:
	var trait_data := SavedDataArmor.new(ARMOR_TRAIT_ID, true, 0)
	trait_data.armor = ARMOR_VALUE
	buckler_charges -= 1
	
	var overworld_trait := OverworldTrait.new(trait_data, OverworldTrait.AddedBy.BUCKLER, true, ARMOR_TURN_DEFAULT_TURNS)
	onPushAction(AddOverworldTraitAction.new(Card, overworld_trait, true))
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()

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
