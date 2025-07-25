class_name AddBoonAction extends Action

var Boon: BoonGD
var id: int
var tier: int

func _init(_id: int = 0, _tier: int = 1) -> void:
	super()
	id = _id
	tier = _tier
	
func onPreAction() -> void:
	onCheckFail()
	
func onPostAction() -> void:
	var boon_info: BoonInfo = Helper.getFofInfoID(BoonInfo, id)
	var saved_data_boon: SavedDataBoon = boon_info.saved_data.new(id, true, 0)
	saved_data_boon.tier = tier
	
	Boon = SavedData.onLoadModel(saved_data_boon, Game.getSaveFile())
	Game.getSaveFile().getBoons().append(Boon)
	
	Boon.onBoonAdded()

func getLogInfo() -> Array:
	var boon_info: BoonInfo = Helper.getFofInfoID(BoonInfo, id)
	return ["Boon: " + boon_info.name]

func onCheckFail() -> void:
	var existing_boons: Array = Game.getSaveFile().getBoons().filter(func(x: BoonGD): return x.info.id == id)
	if existing_boons.is_empty(): return
	
	#var ExistingBoon: BoonGD = existing_boons[0]
	#if !ExistingBoon.ascended:
		#onPushAction(ChangeBoonAscenscionAction.new(ExistingBoon, true))
	onFailAction()
