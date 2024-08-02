class_name BoonsGD
extends Node

var LevelUI: LevelUIGD

var all_boons: Array
func _ready() -> void:
	const DIR_PATH: String = "res://assets/base_game/boons/boons/"
	all_boons = Array(DirAccess.get_directories_at(DIR_PATH)).map(func(x: String): return load(DIR_PATH + x + "/boon_info.tres"))

func onStartPhaseStart() -> void:
	const ASCEND_CHANCE: float = 0.1
	const CHANCE_AT_BOON: float = 0.5
	for i in range(1, 5):
		var roll: bool = randf() < CHANCE_AT_BOON
		if roll:
			var ascend: bool = randf() < ASCEND_CHANCE
			onCreateBoon(onFindAllBoon(i), ascend)

func onCreateBoonByID(id: int, ascend: bool = false) -> void:
	onCreateBoon(onFindAllBoon(id), ascend)

func onCreateBoon(boon_info: BoonInfoGD, ascend: bool = false) -> void:
	if !onBoonExists(boon_info):
		var boon := Node.new()
		boon.script = boon_info.boon_script
		boon.setInfo(boon_info, ascend)
		add_child(boon)
		LevelUI.onCreateBoon(boon)
		if ascend: onAscendBoon(boon)
		if boon.has_method("onArrive"): boon.onArrive()
	else: onAscendBoon(onFindBoon(boon_info))

func onBoonExists(boon_info: BoonInfoGD) -> int: # 0 = false, 1 = exists, 2 = exists and ascended
	for boon in get_children():
		var _boon_info: BoonInfoGD = boon.boon_info
		if _boon_info == boon_info: return 1 if (!boon.is_ascended) else 2
	return 0

func onFindBoon(boon_info: BoonInfoGD) -> BoonGD:
	for boon in get_children():
		if boon.boon_info == boon_info: return boon
	return null

func onFindAllBoon(id: int) -> BoonInfoGD:
	return all_boons.filter(func(x: BoonInfoGD): return x.id == id)[0]

func onAscendBoon(boon: BoonGD) -> void:
	if !boon.is_ascended:
		LevelUI.onAscendBoon(boon)

func onRemoveBoon(id: int) -> void:
	var boon_info: BoonInfoGD = onFindAllBoon(id)
	var boon: BoonGD = onFindBoon(boon_info)
	
	if boon != null:
		LevelUI.onRemoveBoon(boon)
		boon.queue_free()

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	for boon in get_children().filter(func(x: BoonGD): return x.has_method("onTrigger")):
		boon.onTrigger(Unit, trigger, args)
		if boon.boon_info.track_charges:
			LevelUI.onTrackBoonCharges(boon)
		
