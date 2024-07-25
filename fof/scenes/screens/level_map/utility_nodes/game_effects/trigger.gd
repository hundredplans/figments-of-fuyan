class_name TriggerGD
extends Resource

# Unit that has to trigger the action
var Unit: UnitGD
# Which effect this trigger belongs to
var GameFX: GameFXGD
# Type of trigger
var type: int
# Called when trigger activates
var callable: Callable
# Type of removal
var remove_type: int
# Assumed 0, when non-zero takes control of camera and goes back after delay
var delay: float
# Whether to use the bound arguments provided
var use_bound: bool
var trigger_info: TriggerInfoGD
enum {NULL, REMOVE_TRIGGER, REMOVE_FX, CHARGES}

# ON_HIT = After the attack, ON_ATTACK = Before dmg is dealt, ON_AFTER_ATTACK = Directly after dmg is dealt
# WHEN_STRUCK = Directly after taking dmg
enum {REMOVE, END_TURN, ON_HIT, NEXT_TURN, ON_ATTACK, ON_AFTER_ATTACK, HEAL, RAMPAGE, TURN_PASSED,
	REMOVE_ABILITY, AWAKEN, CARD_PLACED, END_TURN_GLOBAL, START_TURN_GLOBAL, WHEN_STRUCK, REVENGE, LAST_WILL,
	EQUIP_TOOL, UNEQUIP_TOOL, BEGIN_DEATH, STAT_CHANGE, MOVE, ENTER_VISION, EXIT_VISION, ADD_ABILITY}

func _init(_GameFX: GameFXGD = null, _Unit: UnitGD = null, _callable: Callable = Callable(), _type: int = -1, _remove_type: int = 2, _use_bound: bool = true, _delay: float = 0, _trigger_info: TriggerInfoGD = null):
	if _type == -1: push_error("Your trigger value is unset!")
	if type == 0 and remove_type == 2: push_error("Possible infinite recursion!")
	GameFX = _GameFX
	Unit = _Unit
	type = _type
	callable = _callable
	remove_type = _remove_type
	delay = _delay
	use_bound = _use_bound
	trigger_info = _trigger_info
