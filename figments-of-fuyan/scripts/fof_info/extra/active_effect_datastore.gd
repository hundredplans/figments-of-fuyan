class_name ActiveEffectDatastore extends Resource

@export var name: String
@export_multiline var description: String
@export var max_charges: int = -1
@export var delay: float
@export var camera_type: CameraTypes

@export_storage var charges: int
@export_storage var used: bool

enum CameraTypes {KEEP, CYCLE}

var owner: FofGD

func getName() -> String:
	return name

func getDescription() -> String:
	return owner.getActiveEffectDescription(self, description)
	
func getMaxCharges() -> int:
	return max_charges

func getCharges() -> int:
	return charges
	
func isUsed() -> bool:
	return used
	
func getDefaultDisabled(Card: CardGD) -> bool:
	if owner == null: return true
	
	var dependant_disabled: bool = Game.isBoonInGame(12) and Card.isAlly(0) and owner is ToolGD
	var active_effect_disabled: bool = \
		owner.getActiveEffectDisabled(self, Card) if owner is IObjectGD\
		else owner.getActiveEffectDisabled(self)
		
	var no_charges: bool = getCharges() == 0
	var turn_passed: bool = Card.turn_state == Game.TurnStates.PASSED
	var is_not_mobile_and_active: bool = !Card.isMobile() and Card.turn_state == Game.TurnStates.ACTIVE and self is ActiveAbilityDatastore
	return active_effect_disabled or used or no_charges or is_not_mobile_and_active or turn_passed or dependant_disabled
	
