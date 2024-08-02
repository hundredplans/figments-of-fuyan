extends DObjectGD

signal action_sig
var palm_mini_tool_info: Resource = preload("res://assets/base_game/unique_tiles/extras/palm_mini_tool_info.tres")
var ObjModel: Node3D
const DROP_ODDS: Dictionary = {
	"COCONUT": 0.23,
	"MINI-TOOL": 0.05,
	"PALMY": 0.02,
}

var recharge: int = 0

func onReady() -> void:
	ObjModel = BaseTile.types[1].model

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.START_TURN_GLOBAL and args.team_relation.onTeam() == 0 and recharge > 0:
		recharge -= 1

var fell_count: int = 0
func onAttacked(DMGInfo: DMGInfoGD) -> void:
	if recharge == 0:
	#recharge = 5
		var vis: bool = false
		var Attacker: UnitGD = DMGInfo.getAttacker()
		if Attacker != null: vis = Attacker.isVis()
		else: vis = BaseTile in Vision.getTeamVision()
		ActionManager.onAddAction(SignalDelayActionGD.new(onAttackedBegin.bind(DMGInfo), Callable(), vis, action_sig))
		
func onAttackedBegin(DMGInfo: DMGInfoGD) -> void:
	var adjacent_tiles: Array = Tiles.getAdjacentTiles(BaseTile, 1, true)
	adjacent_tiles = adjacent_tiles.filter(func(x: TileGD): return BaseTile.w + 3 >= x.w)
	var top_tiles: Array = Tiles.getTopTiles(adjacent_tiles)
	var Attacker: UnitGD = DMGInfo.getAttacker()
	
	fell_count = 0
	for Tile in top_tiles.filter(func(x: TileGD): return x.solid_status == 0):
		var random_key_gen := RandomKeyGenGD.new(["COCONUT", "MINI-TOOL", "PALMY"], [0.23, 0.05, 0.02])
		var roll: String = random_key_gen.onRoll()
		var model: PackedScene = null
		var callable: Callable
		
		match roll:
			"COCONUT":
				model = load("res://assets/models/objects/" + Helper._id_to[1][12] + ".tscn")
				if Tile.Unit != null: callable = onCoconutFallOnUnit.bind(Tile.Unit)
				else: callable = onCoconutFallOnFloor.bind(Tile)
			"MINI-TOOL":
				var index: int = randi_range(0, palm_mini_tool_info.mini_tool_info.size() - 1)
				var mini_tool_id: int = palm_mini_tool_info.mini_tool_info[index].id
				var iobj_id: int = palm_mini_tool_info.getIObjectID(mini_tool_id)
				model = load("res://assets/models/objects/" + Helper._id_to[1][iobj_id] + ".tscn")
				
				if Tile.Unit != null: callable = onMiniToolFallOnUnit.bind(Tile.Unit, mini_tool_id)
				else: callable = onMiniToolFallOnFloor.bind(Tile, iobj_id)
			"PALMY":
				model = load("res://assets/base_game/cards/cards/Palmy/model.tscn")
				if Tile.Unit != null: callable = onPalmyFallOnUnit.bind(Tile.Unit)
				else: callable =  onPalmyFallOnFloor.bind(Tile)
		
		if model != null:
			onSpawnFallingModel(Tile, model, callable)
			fell_count += 1
	if fell_count == 0: action_sig.emit()

func onCoconutFallOnUnit(Unit: UnitGD) -> void:
	Combat.onDMG(Unit, AppliedByGD.new(AppliedByGD.DOBJECT, self), 1)
	
func onCoconutFallOnFloor(Tile: TileGD) -> void:
	ObjectManager.onCreateIObject(Tile, 12)
	
func onMiniToolFallOnUnit(Unit: UnitGD, id: int) -> void:
	Tools.onEquipTool(Unit, id)
	
func onMiniToolFallOnFloor(Tile: TileGD, iobj_id: int) -> void:
	ObjectManager.onCreateIObject(Tile, iobj_id)
	
func onPalmyFallOnUnit(Unit: UnitGD) -> void:
	Combat.onDMG(Unit, AppliedByGD.new(AppliedByGD.DOBJECT, self), 1)
	
func onPalmyFallOnFloor(Tile: TileGD) -> void:
	Units.onUnitAwakened(7, 1, Tile.obj.rotation, Tile)

func onSpawnFallingModel(Tile: TileGD, _model: PackedScene, callable: Callable) -> void:
	var model: Node3D = _model.instantiate()
	var coconut_tree_fall_obj: Node3D = preload("res://scenes/screens/level_map/utility_nodes/object_manager/extras/coconut_tree_fall_object.tscn").instantiate()
	ObjectManager.add_child(coconut_tree_fall_obj)
	coconut_tree_fall_obj.add_child(model)
	model.rotation_degrees.y = randi_range(0, 360)
	
	if model is ModelGD: model.setDisabled(true)
	else:
		for body in model.bodies: body.get_child(0).disabled = true
	
	var stop_falling: float = (Tile.position.y + 0.3) if Tile.Unit == null else (Tiles.getUnitAdjustedHeight(Tile) + Tile.Unit.height.top)
	coconut_tree_fall_obj.setInfo(callable, stop_falling)
	coconut_tree_fall_obj.position = Tile.position
	coconut_tree_fall_obj.position.y += 4
	coconut_tree_fall_obj.fell.connect(onObjectFell)
	
func onObjectFell() -> void:
	fell_count -= 1
	if fell_count == 0: action_sig.emit()
		
