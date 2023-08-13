extends Node
signal add_screen_history
signal screen_change_animation_state

func call_method(node: Node, method: String, args: Array) -> bool:
	if node.has_method(method):
		node.call(method, args)
		return true
	return false

func on_exit_screen(screen: Control, old_screen: Control):
	play_method_on_animation_end("move_screen", old_screen.get_node("MoveScreen"), on_exit_screen_animation_finished, [screen, old_screen], false)
	screen_change_animation_state.emit(true)

func on_exit_screen_animation_finished(screen: Control, old_screen: Control) -> void:
	on_enter_screen(screen)
	old_screen.queue_free()

func on_enter_screen(screen: Control) -> void:
	get_parent().get_node("Main/Screens").add_child(screen)
	play_method_on_animation_end("move_screen", screen.get_node("MoveScreen"), on_enter_screen_animation_finished, [], true)
	
	add_screen_history.emit(screen.scene_file_path)
	screen_change_animation_state.emit(true)

func on_enter_screen_animation_finished() -> void:
	screen_change_animation_state.emit(false)

func play_method_on_animation_end(animation_name: String, animation_player: AnimationPlayer, method: Callable, args: Array, backwards: bool) -> void:
	var animation: Animation = animation_player.get_animation(animation_name)
	var track_index: int = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track_index, get_path())
	var length: float = animation.length
	if backwards: length = 0
	animation.track_insert_key(track_index, length, {"method": method.get_method(), "args": args})
	
	match backwards:
		false: animation_player.play(animation_name)
		true: animation_player.play_backwards(animation_name)
