class_name MapNodeGD extends FofGD

#region Globals
signal create_screen
signal create_world_scene
@warning_ignore("unused_signal")
signal load_level
signal hovered
signal pressed

var is_minimap: bool
var is_finished: bool
var is_entered: bool
var map_location: MapLocation
var link_models: Array
var links: Array
var Model: Node3D
var StaticBody: StaticBody3D
var mesh: MeshInstance3D
var HoverUI: Control
var ability_save: Dictionary
var screen: Control

var saved_rotation_y: float = 0
const PROGRESS_OFFSET: float = 3
const LANE_OFFSET: float = 3
const CENTER_PROGRESS_OFFSET: float = -15
const ENCOUNTER_SCREEN_PATH: String = "res://scenes/game/map_nodes/screens/encounter_screen/encounter_screen.tscn"
#endregion

#region Helper
func isHoly() -> bool:
	return links.any(func(x: MapLink): return x.is_holy)
#endregion

#region Static
static func onCalculatePosition(_map_location: MapLocation) -> Vector3:
	var pos := Vector3((_map_location.progress * PROGRESS_OFFSET) + CENTER_PROGRESS_OFFSET, 0.3, 0)
	pos.z = (_map_location.lane * LANE_OFFSET)
	return pos
#endregion

#region Base Functions
var was_pressed: bool = false
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and hovered_state and !was_pressed and !is_minimap:
		pressed.emit(self)
		was_pressed = true
		
func _process(delta: float) -> void:
	if Model != null and !is_finished: Model.rotation_degrees.y += SPIN_SPEED * delta
	
func onProcessAction(action: Action) -> void:
	super(action)
#endregion

#region Save / Load
func onSave() -> SavedDataMapNode:
	return SavedDataMapNode.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save)

func onLoadData(data: SavedData) -> void:
	super(data)
	map_location = data.map_location
	links = data.links
	is_entered = data.is_entered
	is_finished = data.is_finished
	saved_rotation_y = data.rotation_y
	ability_save = data.ability_save
	onCreateModel()
	
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
		
	add_to_group("MapNodesGD")
	onAfterLoadSetupFinishedEntered()
	
func onAfterLoadSetupFinishedEntered() -> void:
	if is_finished and !is_entered: onExitedVisual(true)
	elif !is_finished and is_entered: onEnteredVisual(true)
		
func onFofInit() -> void: pass # For super purposes
	
func onCreateModel() -> void:
	Model = info.model.instantiate()
	Model.position.y += info.float_y
	Model.rotation.y = saved_rotation_y
	add_child(Model)
	mesh = Helper.getNodeTypeRecursive(Model, MeshInstance3D)[0]
	mesh.set_instance_shader_parameter("time_value", 0.0) # Default value sets
	
	position = map_location.position
	onTweenChain()
	
	StaticBody = load(info.MAP_NODE_STATIC_BODY).instantiate()
	Model.add_child(StaticBody)
	
	Game.mouse_in_ui.connect(onMouseInUI)
	StaticBody.mouse_exited.connect(onMouseHovered.bind(false))
	StaticBody.mouse_entered.connect(onMouseHovered.bind(true))
	onCreateLinks()
#endregion

#region Links
func onCreateLinks() -> void:
	for link in links:
		link.update_finished.connect(onUpdateMapLink)
		var MapNodeLink: Node3D = load(info.MAP_NODE_LINK_PATH).instantiate()
		link_models.append(MapNodeLink)
		add_child(MapNodeLink)
		
		var vector: Vector3 = link.map_location.position - map_location.position
		MapNodeLink.setInfo(vector, link)
		
func onUpdateMapLink(link: MapLink, _finished: bool) -> void:
	var MapNodeLink: Node3D = link_models[link_models.find(link)]
	MapNodeLink.onUpdate()
	
func isMapNodeLink(map_node: MapNodeGD) -> bool:
	for link in links:
		if link.map_location == map_node.map_location:
			return true
	return false
#endregion

#region Setters
func setAlphagreyMaterialValue(value: float) -> void:
	mesh.set_instance_shader_parameter("time_value", value)
	
func setRayPickable(state: bool) -> void:
	StaticBody.input_ray_pickable = state
	
func setRayPickableGlobal(state: bool) -> void:
	if !is_finished and !is_entered: setRayPickable(state)
#endregion

#region Hovered
var hovered_state: bool
func onMouseInUI(_state: bool) -> void:
	if hovered_state:
		onUpdateHovered()

func onMouseHovered(state: bool) -> void:
	if !is_finished and !is_entered:
		hovered_state = state
	onUpdateHovered()

func onUpdateHovered() -> void:
	var state: bool = getHoveredState()
	hovered.emit(self, state, HoverUI)
	
func getHoveredState() -> bool:
	return hovered_state and !Game.isMouseInUI()

func onStaticBodyHovered(is_walkable: bool, state: bool) -> void:
	var mat: Material = null
	if state:
		if is_walkable and !is_minimap: mat = load(info.MAP_NODE_WALKABLE_OUTLINE_PATH)
		else: mat = load(info.MAP_NODE_OUTLINE_PATH)
	mesh.set_surface_override_material(0, mat)
		
#endregion

#region Default Animation
const SPIN_SPEED: float = 40
const SPEED: float = 3
const DISTANCE: float = 0.2
var direction: int = -1
func onTweenChain() -> void:
	if !is_finished:
		direction *= -1
		var tween := get_tree().create_tween()
		tween.tween_property(Model, "position:y", DISTANCE * direction, SPEED).as_relative().set_trans(Tween.TRANS_SINE)
		tween.finished.connect(onTweenChain)
#endregion

#region Enter / Exit / Finish
func onExited() -> void:
	is_entered = false
		
func onEntered() -> void:
	onPushAction(MapNodeEnteredAction.new(self))
	is_entered = true
	setRayPickable(false)
		
func onEnteredVisual(is_instant: bool = false) -> void:
	for link_model in link_models: link_model.onMapNodeSelected()
	if is_instant: setAlphagreyMaterialValue(1.0); setRayPickable(false); return
	
	var tween := get_tree().create_tween()
	tween.tween_method(setAlphagreyMaterialValue, 0.0, 1.0, Game.SELECTED_MAP_NODE_TRAVEL_SPEED)
	
func onExitedVisual(is_instant: bool = false) -> void:
	for link_model in link_models: link_model.onMapNodeDeselected()
	if is_instant: setAlphagreyMaterialValue(0.5); setRayPickable(false); return
	
	var tween := get_tree().create_tween()
	tween.tween_method(setAlphagreyMaterialValue, 1.0, 0.5, Game.SELECTED_MAP_NODE_TRAVEL_SPEED)
		
func onFinished() -> void:
	onPushAction(MapNodeFinishedAction.new(self))
	is_finished = true
	setRayPickable(false)
		
func onOtherMapNodeFinished(map_node: MapNodeGD) -> void:
	if map_node == self: return
	if !is_finished: return
	for link in links.filter(func(x: MapLink): return x.map_location == map_node.map_location):
		link.setIsFinished(true)
		
func onCreateScreen() -> void:
	if info.is_encounter:
		screen = load(ENCOUNTER_SCREEN_PATH).instantiate()
		screen.finished.connect(onFinished)
		create_screen.emit(self, screen)
	elif info.screen != null:
		screen = info.screen.instantiate()
		screen.finished.connect(onFinished)
		create_screen.emit(self, screen)
	else: onFinished()
	
func onCreateWorldScene() -> void:
	var world: Node3D = info.world.instantiate()
	create_world_scene.emit(self, world)
#endregion
