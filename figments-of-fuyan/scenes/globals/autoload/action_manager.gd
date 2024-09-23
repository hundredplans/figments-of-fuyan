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
	if active_action == null and !actions.is_empty():
		action_playing.emit(true)
		active_action = actions.pop_front()
		onDebugAction(active_action)
		
		active_action.onPreAction()
		if !active_action.failed:
			process_action.emit(active_action)
			active_action.onPostAction()
			active_action.post = true
			
			if active_action.getDelay() > 0:
				await get_tree().create_timer(active_action.getDelay()).timeout
			
			process_action.emit(active_action)
		
		active_action = null
		onActionChain()
		return
	action_playing.emit(false)
	
func onForceAction(action: Action) -> void:
	# Forced actions can't have a delay
	onDebugAction(action)
	action.onPreAction()
	if !action.failed:
		process_action.emit(action)
		action.onPostAction()
		action.post = true
		process_action.emit(action)

func onDebugAction(action: Action) -> void:
	past_actions_debug.append(active_action)
	var path: String = action.get_script().resource_path
	print(path.get_slice("/", path.get_slice_count("/") - 1))
