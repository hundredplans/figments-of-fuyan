class_name ActionManagerGD extends Node

signal pre_action
signal post_action

signal action_playing

var active_action: Action
var actions: Array = []
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
		
		pre_action.emit(active_action)
		active_action.onProcess()
		
		if active_action.getDelay() > 0:
			await get_tree().create_timer(active_action.getDelay()).timeout
		
		post_action.emit(active_action)
		
		active_action = null
		onActionChain()
		return
	action_playing.emit(false)
