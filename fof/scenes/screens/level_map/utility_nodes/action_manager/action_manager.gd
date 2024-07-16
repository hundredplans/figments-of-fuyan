class_name ActionManagerGD
extends Node

var Vision: VisionGD
var LevelMap: LevelMapGD
var Combat: CombatGD
var SpectateCamera: SpectateCameraGD
var AIManager: AIManagerGD
var PlayerManager: PlayerManagerGD
var Tiles: TilesGD
var LevelUI: LevelUIGD

var unit_actions: Array = []
enum {
	MOVE_UNIT, # 0
	MOVE_FINISH, # 1
	ATTACK, # 2
	HURT, # 3
	DEATH, # 4
	DELAY, # 5
	ARG_DELAY, # 6
}

enum {
	APPEND,
	PUSH,
	APPEND_MF,
	AFTER_HURT,
}

var ENUM_TO_STRING: Dictionary = {
	0: "MOVE_UNIT",
	1: "MOVE_FINISH",
	2: "ATTACK",
	3: "HURT",
	4: "DEATH",
	5: "DELAY",
	6: "ARG_DELAY",
}

func onEnemyDiscovered() -> void:
	var remove_actions: Array = []
	for action in unit_actions:
		if action.type in [MOVE_UNIT, ATTACK]:
			remove_actions.append(action)
	for action in remove_actions: unit_actions.erase(action)

func onAddAction(action: ActionGD, type: int = 0) -> void:
	match type:
		APPEND: onAppendAction(action)
		PUSH: onPushAction(action)
		APPEND_MF: onAppendMoveFinishAction(action)
		AFTER_HURT: onAfterHurtAction(action)
	
func onUnitActionsToString() -> void:
	print(unit_actions.map(func(x: ActionGD): return ENUM_TO_STRING[x.type]))

func onAfterHurtAction(action: ActionGD) -> void:
	for i in range(unit_actions.size() - 1, -1, -1):
		if unit_actions[i].type == ATTACK:
			unit_actions.insert(i + 1, action)
			return
	unit_actions.append(action)
	if !is_triggered: onTriggerNextAction(action)

func onAppendAction(action: ActionGD) -> void:
	if !action.has_method("onCondition") or action.onCondition():
		unit_actions.append(action)
		await get_tree().process_frame
		if !is_triggered: onTriggerNextAction(action)

func onPushAction(action: ActionGD) -> void:
	if !action.has_method("onCondition") or action.onCondition():
		unit_actions.push_front(action)
		await get_tree().process_frame
		if !is_triggered: onTriggerNextAction(action)

func onAppendMoveFinishAction(action: MoveFinishActionGD) -> void:
	for i in range(unit_actions.size() - 1, -1, -1):
		if unit_actions[i].type in [MOVE_UNIT, ATTACK]:
			unit_actions.insert(i + 1, action)
			return
	unit_actions.append(action)
	if !is_triggered: onTriggerNextAction(action)

var is_triggered: bool = false
func onTriggerNextAction(action: ActionGD) -> void:
	is_triggered = true
	if action.delay.start_delay > 0 and action.is_visible: await get_tree().create_timer(action.delay.start_delay).timeout
	
	if LevelMap.game_phase == "PlayerPhase": PlayerManager.onUnitMode()
	if LevelMap.game_phase != "AIPhase":
		LevelMap.setInputLock(LevelMap.UNIT_ACTION)
		
	Vision.on_vision_mode_set(0)
	action.onTrigger()
	
	if action.delay.delay > 0 and action.is_visible: await get_tree().create_timer(action.delay.delay).timeout
	
	unit_actions.erase(action)
	Combat.onRecalculateTargetAbilities()
	if action.has_method("onAfterTrigger"): await action.onAfterTrigger()
	if action.delay.end_delay > 0 and action.is_visible: await get_tree().create_timer(action.delay.end_delay).timeout
		
	is_triggered = false
	if !(unit_actions.is_empty()): onTriggerNextAction(unit_actions[0])
	elif LevelMap.game_phase == "AIPhase": AIManager.onMoveNextAIUnit()
	else:
		var Unit: UnitGD = PlayerManager.getUnitSelected()
		LevelMap.setInputLock(LevelMap.UNIT_ACTION_DISABLE, true)
		PlayerManager.onUnitMode(Unit, true)
		
		if Unit != null and Unit.speed == 0 and Unit.team == 0:
			onCreateIncentiviseAction(Unit)

func onDeath(Unit: UnitGD) -> void:
	unit_actions = unit_actions.filter(func(x: ActionGD): return x.Unit != Unit)

func onCreateIncentiviseAction(Unit: UnitGD) -> void:
	if LevelMap.game_phase == "PlayerPhase":
		LevelUI.onIncentivisePassTurn(Unit)
