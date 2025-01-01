class_name SavedData extends Resource

# Stores the id to the info
@export var id: int
@export var first_init: bool
@export var public_id: int

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0) -> void:
	id = _id
	first_init = _first_init
	
	#if _public_id == 0 and !Engine.is_editor_hint(): _public_id = Game.onIncrementPublicID()
	public_id = _public_id

static func onLoadModel(data: SavedData, parent: Node3D, init_args: Array = []) -> FofGD:
	if data.public_id == 0: data.public_id = Game.onIncrementPublicID()
	var model := FofGD.new()
	var info: FofInfo = Helper.getFofInfoID(data.getInfoType(), data.id)
	
	model.name = info.getFofName() + str(data.public_id)
	model.script = info.gdscript
	model.info = info
	
	parent.add_child(model)
	model.onLoadData(data)
	
	if Game.ActionManagerReference != null:
		model.push_action.connect(Game.ActionManagerReference.onPushAction)
		model.append_action.connect(Game.ActionManagerReference.onAppendAction)
		model.force_action.connect(Game.ActionManagerReference.onForceAction)
		model.remove_move_and_attack_actions.connect(Game.ActionManagerReference.onRemoveMoveAndAttackActions)
		Game.ActionManagerReference.process_action.connect(model.onProcessAction)
	
	if data.first_init and model.has_method("onFofInit"): model.callv("onFofInit", init_args)
	return model
	
func getInfoType() -> GDScript: return FofInfo
static func onSaveGroup(nodes: Array, save_data: Array = []) -> Array:
	for node in nodes.filter(func(x: FofGD): return x.groupsave):
		save_data.append(node.onSave())
	return save_data
