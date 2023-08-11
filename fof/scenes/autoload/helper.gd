extends Node

func call_method(node: Node, method: String, args: Array) -> bool:
	if node.has_method(method): 
		node.call(method, args)
		return true
	return false

func on_enter_screen(screen: Control) -> void:
	get_parent().get_node("Main/Screens").add_child(screen)
	if screen.has_method("on_enter_screen"): screen.on_enter_screen()
