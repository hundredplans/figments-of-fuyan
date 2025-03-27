extends ToolGD

const ARMOR_TURN_DEFAULT_TURNS: int = 2
const ARMOR_TRAIT_ID: int = 1
const ARMOR_VALUE: int = 1

func onFofInit() -> void:
	onRegularReset()

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if Card != null and Card.isValidRevenge(action) and charges > 0:
			onPushAction(ToolActivatedAction.new(self, action))
	
func onToolAction(_action: StatAction) -> void:
	var trait_data := SavedDataArmor.new(ARMOR_TRAIT_ID, true, 0)
	trait_data.armor = ARMOR_VALUE
	
	var overworld_trait := OverworldTrait.new(trait_data, OverworldTrait.AddedBy.BUCKLER, true, ARMOR_TURN_DEFAULT_TURNS)
	var actions: Array = [AddOverworldTraitAction.new(Card, overworld_trait, true), ChangeToolChargesAction.new(self, -1)]
	onPushAction(actions)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()

func onToolHolderAwakened() -> void:
	super()
	
func onToolAscended(state: bool) -> void:
	super(state)
	onResetCharges()
	
func getDescription() -> String:
	return Helper.getDescriptionNumeric(super(), [charges], [["REVENGE ", "[" + str(getDefaultCharges()) + "]"]])
	
func getDefaultCharges() -> int:
	return 1 if !ascended else 2
