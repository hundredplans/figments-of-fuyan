class_name ChangeShillingsAction extends Action

var shillings: int
func _init(_shillings: int) -> void:
	super()
	shillings = _shillings
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Game.get_tree().get_nodes_in_group("SaveFilesGD")[0].onUpdateShillings(shillings)
