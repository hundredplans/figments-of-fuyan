class_name ActionManagerGD extends Node

signal process_action
signal action_playing

var active_action: Action
var actions: Array = []
var is_game_closing: bool
@onready var DelayTimer: Timer = %DelayTimer

func onPushAction(action: Action) -> void:
	actions.push_front(action)
	onActionChain()
	
func onPushAfterAction(new_actions: Array, after_action: Action) -> void:
	var index: int = actions.find(after_action)
	for action in new_actions:
		actions.insert(index + 1, action)
		
	onActionChain()
	
func onAppendAction(action: Action) -> void:
	actions.append(action)
	onActionChain()
	
func onActionChain() -> void:
	if active_action != null or actions.is_empty(): return
	
	onActionPlaying(true)
	active_action = actions.pop_front()
	onDebugAction(active_action)
	
	active_action.onPreAction()
	if active_action.failed: onFinishActionChain(); return
	
	process_action.emit(active_action)
	
	if active_action.failed: onFinishActionChain(); return
	active_action.onPostAction()
	active_action.post = true
	
	if active_action.getDelay() > 0 and !is_game_closing:
		DelayTimer.wait_time = active_action.getDelay()
		DelayTimer.start()
		await DelayTimer.timeout
	
	process_action.emit(active_action)

	onFinishActionChain()
	
func onFinishActionChain() -> void:
	active_action = null
	if actions.is_empty(): onActionPlaying(false)
	onActionChain()
	
func onForceAction(action: Action) -> void:
	# Forced actions can't have a delay
	onDebugAction(action)
	action.onPreAction()
	if action.failed: return
	process_action.emit(action)
	if action.failed: return
	action.onPostAction()
	action.post = true
	process_action.emit(action)

func onDebugAction(action: Action) -> void:
	pass
	#var path: String = action.get_script().resource_path
	#print(path.get_slice("/", path.get_slice_count("/") - 1))
	#var logs: Array = action.getLogInfo()
	#if action.failed: logs.append("FAILED")
	#
	#for log_info in logs:
		#print("	" + log_info)
	
	print(([action] + actions).map(func(x: Action):
		var path: String = x.get_script().resource_path
		return path.get_slice("/", path.get_slice_count("/") - 1)))
	
func onDebugActionNames() -> void:
	pass
	#print("Debug Action Names: ")
	#for action in actions:
		#var path: String = action.get_script().resource_path
		#print(path.get_slice("/", path.get_slice_count("/") - 1))
	#print()
	
var is_action_playing: bool
func onActionPlaying(state: bool) -> void:
	if state != is_action_playing:
		is_action_playing = state
		action_playing.emit(state)

func onRemoveMoveAndAttackActions(Card: CardGD):
	actions = actions.filter(func(x: Action):
			return !((x is MoveToTileAction and x.Card == Card) or (x is AttackAction and x.Attacker == Card)))
		
func onFindFirstAction(type: GDScript) -> Action:
	var valid_actions: Array = actions.filter(func(x: Action): return is_instance_of(x, type))
	return valid_actions[0] if !valid_actions.is_empty() else null
	
func onFindAnyFirstAction() -> Action:
	return null if actions.is_empty() else actions[0]
	
func onFindNextAction(action: Action) -> Action:
	var index: int = actions.find(action)
	if index == -1 or index == actions.size() - 1: return null
	return actions[index + 1]

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		onGameClosing()
	
func onGameClosing() -> void: # This should save all the actions at a point in time and place in save file instead
	is_game_closing = true
	DelayTimer.stop()
	DelayTimer.timeout.emit()
