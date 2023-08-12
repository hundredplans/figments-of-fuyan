extends Node

func call_method(node: Node, method: String, args: Array) -> bool:
	if node.has_method(method): 
		node.call(method, args)
		return true
	return false

func on_enter_screen(screen: Control) -> void:
	get_parent().get_node("Main/Screens").add_child(screen)
	if screen.has_method("on_enter_screen"): screen.on_enter_screen()

func play_method_on_animation_end(animation_name: String, animation_player: AnimationPlayer, method: Callable, args: Array) -> void:
	var animation: Animation = animation_player.get_animation(animation_name)
	animation.add_track(Animation.TYPE_METHOD)
	
	animation.track_insert_key(animation.get_track_count(),animation.length,method.bind(args),1)
	animation_player.play(animation_name)
