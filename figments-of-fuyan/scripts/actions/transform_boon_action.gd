class_name TransformBoonAction extends Action

var Boon: BoonGD
var new_boon_id: int
var all: Array

func _init(_Boon: BoonGD = null) -> void:
	super()
	Boon = _Boon
	
func onPreAction() -> void:
	if Boon == null: onFailAction(); return
	var existing_boon_ids: Array = Game.getSaveFile().getBoons().map(func(x: BoonGD): return x.info.id)
	all = Helper.getFofInfoArray(BoonInfo)
	all = all.filter(func(x: FofInfo): return x != Boon.info and x.rarity == Boon.getRarity()\
		and x.id not in existing_boon_ids)
	if all.is_empty(): onFailAction(); return
	
func onPostAction() -> void:
	var new_info: FofInfo = all.pick_random()
	var remove_boon_action := RemoveBoonAction.new(Boon.info.id)
	new_boon_id = new_info.id
	var add_boon_action := AddBoonAction.new(new_boon_id, Boon.getTier())
	if !forced: onPushAction([remove_boon_action, add_boon_action])
	else: onForceAction(remove_boon_action); onForceAction(add_boon_action)

func getBoon() -> BoonGD: return Boon
func getNewBoon() -> BoonGD: return Game.getSaveFile().getBoon(new_boon_id)
	
