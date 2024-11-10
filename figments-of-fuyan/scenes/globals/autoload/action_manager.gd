class_name ActionManagerGD extends Node

signal process_action
signal action_playing

var active_action: Action
var actions: Array = []
var past_actions_debug: Array = []

func onPushAction(action: Action) -> void:
	actions.push_front(action)
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
	
	if active_action.getDelay() > 0:
		await get_tree().create_timer(active_action.getDelay()).timeout
	
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
	past_actions_debug.append(active_action)
	var path: String = action.get_script().resource_path
	print(path.get_slice("/", path.get_slice_count("/") - 1))
	var logs: Array = action.getLogInfo()
	if action.failed: logs.append("FAILED")
	
	for log_info in logs:
		print("	" + log_info)
	
func onDebugActionNames() -> void:
	print("Debug Action Names: ")
	for action in actions:
		var path: String = action.get_script().resource_path
		print(path.get_slice("/", path.get_slice_count("/") - 1))
	print()
	
var is_action_playing: bool
func onActionPlaying(state: bool) -> void:
	if state != is_action_playing:
		is_action_playing = state
		action_playing.emit(state)

func onRemoveMoveAndAttackActions(Card: CardGD):
	actions = actions.filter(func(x: Action):
			return !((x is MoveToTileAction and x.Card == Card) or (x is AttackAction and x.Attacker == Card)))
		
