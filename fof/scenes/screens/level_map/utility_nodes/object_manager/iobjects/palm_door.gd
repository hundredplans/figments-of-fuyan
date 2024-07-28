extends IObjectGD

var original_materials: Array = []
var ObjModel: Node3D
var StaticBody: StaticBody3D
var is_tall: bool = false
var is_open: bool = false
var AniPlayer: AnimationPlayer
# Returns 0 if enabled, 1 for disabled, 2 for invisible
func onAbilityCondition(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> int:
	if is_open and ability.name == "Open Door": return 2
	elif !is_open and ability.name == "Close Door": return 2
	if Unit in used_list: return 1
	return 0

func onCondition(Unit: UnitGD) -> bool:
	return Unit.Tile in interactable_tiles

func onReady() -> void:
	ObjModel = BaseTile.types[1].model
	is_tall = info.id == 10
	
	addStaticBody()
	AniPlayer = ObjModel.get_node("AnimationPlayer")
	AniPlayer.animation_finished.connect(onAnimationFinished)
	
	onPlayIdleAnimation()
	setFneighboursUnitHeight()
	
func onPlayIdleAnimation() -> void:
	var ani_name: String = "Idle" if !is_open else "IdleAbility"
	AniPlayer.play(ani_name)

func onAnimationFinished(__: String) -> void:
	onPlayIdleAnimation()

func onAfterDelay() -> void:
	Vision.onRecalculateVisionUnitsInRangeOfTile(BaseTile)

var used_list: Array = []
func onAbilityTrigger(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> void:
	Unit.Model._look_at(BaseTile)
	if ability.name == "Close Door": onCloseDoor()
	elif ability.name == "Open Door": onOpenDoor()
	used_list.append(Unit)
	
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.START_TURN_GLOBAL:
		for Unit in used_list.duplicate():
			if Unit.is_dead or args.team_relation.onTeam() == Unit.team:
				used_list.erase(Unit)
	
func onCloseDoor() -> void:
	AniPlayer.play_backwards("Ability")
	is_open = false
	setFneighbours(true)
	addStaticBody()
	
func addStaticBody() -> void:
	if StaticBody != null: StaticBody.queue_free(); ObjModel.bodies.erase(StaticBody)
	var path: String = "res://scenes/screens/level_map/utility_nodes/object_manager/extras/"
	if is_open:
		if is_tall: path += "palm_door_static_body_open"
		else: path += "palm_door_short_static_body_open"
	else:
		if is_tall: path += "palm_door_static_body"
		else: path += "palm_door_short_static_body"
	path += ".tscn"
	StaticBody = load(path).instantiate()
	ObjModel.add_child(StaticBody)
	ObjModel.bodies.append(StaticBody)
	
func onOpenDoor() -> void:
	AniPlayer.play("Ability")
	is_open = true
	setFneighbours(false)
	addStaticBody()
			
func setFneighbours(is_solid: bool) -> void:
	for Tile in interactable_tiles:
		for fneighbour in Tile.fneighbours:
			if fneighbour.Tile == BaseTile and Tile.solid_status == 0:
				fneighbour.changeIsSolid(is_solid)
				
func setFneighboursUnitHeight() -> void:
	for Tile in interactable_tiles:
		for fneighbour in Tile.fneighbours:
			if fneighbour.Tile == BaseTile and Tile.solid_status == 0:
				fneighbour.unit_height = 3 if is_tall else 1
				
