class_name MapNodeFinishedAction extends Action

var map_node: MapNodeGD
func _init(_map_node: MapNodeGD) -> void:
	super()
	map_node = _map_node
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass
