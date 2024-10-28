class_name AddBoonAction extends Action

var Boon: BoonGD
var id: int
var ascended: bool
var load_into_level: bool

func _init(_id: int = 0, _ascended: bool = false, _load_into_level: bool = false) -> void:
	super()
	id = _id
	ascended = _ascended
	load_into_level = _load_into_level
	
func onPreAction() -> void:
	if !load_into_level:
		var ExistingBoon: Variant = Game.get_tree().get_nodes_in_group("BoonsGD").filter(func(x: BoonGD): return x.info.id == id)
		if !ExistingBoon.is_empty():
			ExistingBoon = ExistingBoon[0]
			onPushAction(ChangeBoonAscenscionAction.new(ExistingBoon, ascended))
			onFailAction()
			
		var boon_info: BoonInfo = Helper.getFofInfoID(BoonInfo, id)
		var saved_data_boon: SavedDataBoon = boon_info.saved_data.new(id, true, 0, ascended)
		Boon = SavedData.onLoadModel(saved_data_boon, Game.get_tree().get_nodes_in_group("SaveFilesGD")[0])
	else:
		Boon = Game.get_tree().get_nodes_in_group("BoonsGD").filter(func(x: BoonGD): return x.info.id == id)[0]
	
func onPostAction() -> void:
	Boon.onBoonAdded()

func getDelay() -> float:
	return super()

func getLogInfo() -> Array:
	var boon_info: BoonInfo = Helper.getFofInfoID(BoonInfo, id)
	return ["Boon: " + boon_info.name]
