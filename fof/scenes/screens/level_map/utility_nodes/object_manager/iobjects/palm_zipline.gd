class_name PalmZiplineGD
extends IObjectGD

const ZIPLINE_DELAY: float = 3
var ObjModel: Node3D
var is_equal_height: bool
var tween_info: Array
# Class to sync all the functions for palm ziplines

var hanger_originals: Dictionary = {}
var used_list: Array = []
func onReady() -> void:
	is_equal_height = info.id in [5, 6]
	ObjModel = BaseTile.types[1].model
	
	for hanger in [ObjModel.get_node("HolderLeft"), ObjModel.get_node("HolderRight")]:
		hanger_originals[hanger] = {"position": hanger.position, "rotation": hanger.rotation}
	
func onCondition(Unit: UnitGD) -> bool: return Unit.Tile in interactable_tiles

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.START_TURN_GLOBAL:
		for Unit in used_list.duplicate():
			if Unit.is_dead or args.team_relation.onTeam() == Unit.team:
				used_list.erase(Unit)

func onAbilityTrigger(Unit: UnitGD, _ability: IObjectAbilityInfoGD) -> void:
	var StartTile: TileGD = Unit.Tile
	var start_index: int = 0 if (StartTile == interactable_tiles[0]) else 1
	var end_index: int = abs(start_index - 1)
	var EndTile: TileGD = interactable_tiles[end_index]
	
	var other_hanger_name: String = hanger_names[end_index]
	var hanger_name: String = hanger_names[start_index]
	
	var CoconutHanger: Node3D = ObjModel.get_node(hanger_name)
	var OtherHanger: Node3D = ObjModel.get_node(other_hanger_name)
	
	used_list.append(Unit)
	ActionManager.onAddAction(ArgDelayActionGD.new(\
	onTriggerStarted.bind(Unit, StartTile, start_index, CoconutHanger, OtherHanger), \
	onTriggerFinished.bind(Unit, EndTile, OtherHanger), Unit.isVis(), \
	DelayGD.new(ZIPLINE_DELAY + 0.2)), ActionManager.APPEND)
	
func onAbilityCondition(Unit: UnitGD, _ability: IObjectAbilityInfoGD) -> int:
	return 1 if interactable_tiles.all(func(x: TileGD): return !x.isTileFree()) or Unit in used_list else 0

var hanger_names: Array = ["HolderLeft", "HolderRight"]
func onTriggerStarted(Unit: UnitGD, StartTile: TileGD, start_index: int, CoconutHanger: Node3D, OtherHanger: Node3D) -> void:
	OtherHanger.visible = false
	var ani_name: String = "AbilityLeft" if start_index == 0 else "AbilityRight"
	ObjModel.get_node("AnimationPlayer").play(ani_name)
	
	Unit.Model._look_at(StartTile)
	
	var tween := Unit.create_tween()
	tween.tween_method(setUnitZiplineTransform.bind(Unit, CoconutHanger, start_index == 0), 0, 1, ZIPLINE_DELAY)

func setUnitZiplineTransform(__: float, Unit: UnitGD, CoconutHanger: Node3D, is_left: bool) -> void:
	Unit.position = CoconutHanger.global_position
	Unit.position.y -= Unit.height.top + 0.5
	
	Unit.Model.rotation.z = CoconutHanger.rotation.x
	Unit.Model.rotation.x = CoconutHanger.rotation.z
	if !is_left: Unit.Model.rotation.z *= -1
	
	var y_rot: float = CoconutHanger.rotation.y + ((PI if is_left else -PI) / 2)
	Unit.Model.setCustomRotation(y_rot + deg_to_rad(BaseTile.obj.rotation * 60))

func onTriggerFinished(Unit: UnitGD, EndTile: TileGD, OtherHanger: Node3D) -> void:
	Unit.occupy_tile(EndTile)
	Unit.position = Unit.Model.onCalculateEndPosition(EndTile)
	
	OtherHanger.visible = true
	
	for hanger in hanger_originals:
		hanger.position = hanger_originals[hanger].position
		hanger.rotation = hanger_originals[hanger].rotation
		
