class_name PalmZiplineGD
extends IObjectGD

@export var height_limit: float = 2.8

var hanger_names: Array = ["HolderLeft", "HolderRight"]
var zipline_delay: float
var is_equal_height: bool
var tween_info: Array
# Class to sync all the functions for palm ziplines

var hanger_originals: Dictionary = {}
var used_list: Array = []
func onReady() -> void:
	is_equal_height = info.id in [5, 6]
	
	for hanger_name in hanger_names.filter(func(x: String): return ObjModel.has_node(x)):
		var hanger: MeshInstance3D = ObjModel.get_node(hanger_name)
		hanger_originals[hanger] = {"position": hanger.position, "rotation": hanger.rotation}
	
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.START_TURN_GLOBAL:
		for Unit in used_list.duplicate():
			if Unit.is_dead or args.team_relation.onTeam() == Unit.team:
				used_list.erase(Unit)
				
var ZiplineUnit: UnitGD
var EndTile: TileGD
var OtherHanger: Node3D
func onAbilityTrigger(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> void:
	zipline_delay = ability.delay
	var StartTile: TileGD = Unit.Tile
	var start_index: int = 0 if (StartTile == ability.tiles[0]) else 1
	
	if is_equal_height:
		var end_index: int = abs(start_index - 1)
		EndTile = ability.tiles[end_index]
		var other_hanger_name: String = hanger_names[end_index]
		OtherHanger = ObjModel.get_node(other_hanger_name)
		OtherHanger.visible = false
	else:
		EndTile = Tiles.position_to_tile(BaseTile.onTTpos() + Tiles.onRotatePositionLeft(Vector4(1, 0, -1, 0)))
	
	var CoconutHanger: Node3D = ObjModel.get_node(hanger_names[start_index] if is_equal_height else "HolderRight")
		
	used_list.append(Unit)
	var ani_name: String = ("AbilityLeft" if start_index == 0 else "AbilityRight") if is_equal_height else "Ability"
	ObjModel.get_node("AnimationPlayer").play(ani_name)
	
	ZiplineUnit = Unit
	Unit.Model._look_at(StartTile)
	
	var tween := Unit.create_tween()
	tween.tween_method(setUnitZiplineTransform.bind(Unit, CoconutHanger, start_index == 0 if is_equal_height else false), 0, 1, zipline_delay - 0.2)
	
func onAfterDelay() -> void:
	ZiplineUnit.occupy_tile(EndTile)
	ZiplineUnit.position = ZiplineUnit.Model.onCalculateEndPosition(EndTile)
	ZiplineUnit.Model.rotation.x = 0
	ZiplineUnit.Model.rotation.z = 0
	if OtherHanger != null: OtherHanger.visible = true
	
	for hanger in hanger_originals:
		hanger.position = hanger_originals[hanger].position
		hanger.rotation = hanger_originals[hanger].rotation
	
func onAbilityCondition(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> int:
	if Unit.height.top > height_limit: return 2
	if Unit.Tile in ability.tiles:
		if !is_equal_height: return 0
		return 1 if ability.tiles.all(func(x: TileGD): return !x.isTileFree()) or Unit in used_list else 0
	return 2

func setUnitZiplineTransform(__: float, Unit: UnitGD, CoconutHanger: Node3D, is_left: bool) -> void:
	Unit.position = CoconutHanger.global_position
	Unit.position.y -= Unit.height.top + 0.5
	
	Unit.Model.rotation.z = CoconutHanger.rotation.x
	Unit.Model.rotation.x = CoconutHanger.rotation.z
	if !is_left: Unit.Model.rotation.z *= -1
	
	var y_rot: float = CoconutHanger.rotation.y + ((PI if is_left else -PI) / 2)
	Unit.Model.setCustomRotation(y_rot + deg_to_rad(BaseTile.obj.rotation * 60))
		
