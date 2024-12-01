class_name RemoveBoonAction extends Action

var id: int
func _init(_id: int = 0) -> void:
	super()
	id = _id
	
func onPreAction() -> void:
	if id not in Game.get_tree().get_nodes_in_group("BoonsGD").map(func(x: BoonGD): return x.info.id):
		onFailAction()
	
func onPostAction() -> void:
	var Boon: BoonGD = Game.get_tree().get_nodes_in_group("BoonsGD").filter(func(x: BoonGD): return x.info.id == id)[0]
	Game.save_file.onRemoveBoon(Boon)
	Boon.onClear()

func getDelay() -> float:
	return super()

func getLogInfo() -> Array:
	var boon_info: BoonInfo = Helper.getFofInfoID(BoonInfo, id)
	if boon_info != null:
		return ["Boon: " + boon_info.name]
	return ["Boon: Invalid"]
