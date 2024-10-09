class_name MapNodeGD extends FofGD

#region Globals
signal entered
signal finished

signal hovered
signal pressed
@warning_ignore("unused_signal")
signal load_level

var is_finished: bool
var is_entered: bool
var map_location: MapLocation
var link_models: Array
var links: Array
var Model: Node3D
var StaticBody: StaticBody3D
var mesh: MeshInstance3D
var HoverUI: Control

var saved_rotation_y: float = 0
const PROGRESS_OFFSET: float = 3
const LANE_OFFSET: float = 4
const CENTER_PROGRESS_OFFSET: float = -15
#endregion

#region Static
static func onCalculatePosition(_map_location: MapLocation, map_locations: Array) -> Vector3:
	var pos := Vector3((_map_location.progress * PROGRESS_OFFSET) + CENTER_PROGRESS_OFFSET, 0.3, 0)
	var lanes: Array = map_locations.filter(func(x: MapLocation): return x.progress == _map_location.progress)\
	.map(func(x: MapLocation): return x.lane)
	var _direction: int = 0
	
	match lanes.size():
		2: _direction = -1 if lanes.max() == 1 else 1
		4: _direction = -1 if lanes.max() == 2 else 1
	
	pos.z = (_map_location.lane + (_direction * 0.5)) * LANE_OFFSET
	return pos
#endregion

#region Base Functions
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and hovered_state:
		pressed.emit(self)
		
func _process(delta: float) -> void:
	if Model != null and !is_finished: Model.rotation_degrees.y += SPIN_SPEED * delta
#endregion

#region Save / Load
func onSave() -> SavedDataMapNode:
	return SavedDataMapNode.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y)

func onLoadData(data: SavedData) -> void:
	super(data)
	map_location = data.map_location
	links = data.links
	is_entered = data.is_entered
	is_finished = data.is_finished
	saved_rotation_y = data.rotation_y
	onCreateModel()
		
	add_to_group("MapNodesGD")
	onAfterLoadSetupFinishedEntered()
	
func onAfterLoadSetupFinishedEntered() -> void:
	if is_finished and !is_entered:
		onExit(true)
	elif is_entered:
		onEnter(true)
	
func onCreateModel() -> void:
	Model = info.model.instantiate()
	Model.position.y += info.float_y
	Model.rotation.y = saved_rotation_y
	add_child(Model)
	mesh = Helper.getNodeTypeRecursive(Model, MeshInstance3D)[0]
	
	position = map_location.position
	onTweenChain()
	
	StaticBody = load(info.MAP_NODE_STATIC_BODY).instantiate()
	Model.add_child(StaticBody)
	
	StaticBody.mouse_exited.connect(onMouseHovered.bind(false))
	StaticBody.mouse_entered.connect(onMouseHovered.bind(true))
	onCreateLinks()
#endregion

#region Links
func onCreateLinks() -> void:
	for link in links:
		var MapNodeLink: Node3D = load(info.MAP_NODE_LINK_PATH).instantiate()
		link_models.append(MapNodeLink)
		add_child(MapNodeLink)
		
		var vector: Vector3 = link.map_location.position - map_location.position
		MapNodeLink.setInfo(vector, link.is_holy)
		
func isMapNodeLink(map_node: MapNodeGD) -> bool:
	return map_node.map_location in links.map(func(x: MapLink): return x.map_location)
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
func onMouseHovered(state: bool) -> void:
	hovered_state = state
	hovered.emit(self, state)

var hovered_state: bool
func onStaticBodyHovered(is_walkable: bool, state: bool) -> void:
	var mat: Material = null
	if state:
		if is_walkable: mat = load(info.MAP_NODE_WALKABLE_OUTLINE_PATH)
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
var ActiveScreen: Control
func onExit(is_instant: bool = false) -> void:
	is_entered = false
	if is_instant: setAlphagreyMaterialValue(0.5); setRayPickable(false)
	else:
		var tween := get_tree().create_tween()
		tween.tween_method(setAlphagreyMaterialValue, 1.0, 0.5, Game.SELECTED_MAP_NODE_TRAVEL_SPEED)
		for link_model in link_models: link_model.onMapNodeDeselected()
		
func onEnter(is_instant: bool = false) -> void:
	is_entered = true
	setRayPickable(false)
	for link_model in link_models: link_model.onMapNodeSelected()
	if is_instant: setAlphagreyMaterialValue(1.0)
	else:
		var tween := get_tree().create_tween()
		tween.tween_method(setAlphagreyMaterialValue, 0.0, 1.0, Game.SELECTED_MAP_NODE_TRAVEL_SPEED)
		await tween.finished
	var instant_finish: bool = onLoadEntered()
	
	entered.emit(self)
	if instant_finish: onFinished()
		
func onFinished() -> void:
	is_finished = true
	if ActiveScreen != null: ActiveScreen.queue_free()
	setRayPickable(false)
	if is_entered:
		finished.emit(self)
		
func onLoadEntered() -> bool:
	if info.screen != null:
		ActiveScreen = info.screen.instantiate()
		ActiveScreen.finished.connect(onFinished)
		return false
	return true
#endregion
