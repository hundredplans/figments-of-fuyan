class_name MapNodeGD extends FofGD

#region Globals
signal hovered
signal pressed
signal entered
var map_location: MapLocation
var link_models: Array
var links: Array
var Model: Node3D
var mesh: MeshInstance3D

const PROGRESS_OFFSET: float = 3
const LANE_OFFSET: float = 4
const CENTER_PROGRESS_OFFSET: float = -15
#endregion

func onFofInit(_area: AreaGD) -> void: pass

#region Base Functions
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and hovered_state:
		pressed.emit(self)
		
func _process(delta: float) -> void:
	if Model != null: Model.rotation_degrees.y += SPIN_SPEED * delta
#endregion

#region Save / Load
func onSave() -> SavedDataMapNode:
	return SavedDataMapNode.new(info.id, map_location, links)

func onLoadData(data: SavedData) -> void:
	super(data)
	map_location = data.map_location
	links = data.links
	add_to_group("MapNodesGD")
	
func onCreateModel(map_locations: Array) -> void:
	Model = info.model.instantiate()
	Model.position.y += info.float_y
	add_child(Model)
	mesh = Helper.getNodeTypeRecursive(Model, MeshInstance3D)[0]
	setPosition(map_locations)
	onTweenChain()
	
	for static_body in Helper.getNodeTypeRecursive(self, StaticBody3D):
		static_body.mouse_exited.connect(onMouseHovered.bind(false))
		static_body.mouse_entered.connect(onMouseHovered.bind(true))
	
#endregion

#region Links
func onCreateLinks(map_location_to_node: Dictionary) -> void:
	for link in links:
		var MapNodeLink: Node3D = load(info.MAP_NODE_LINK_PATH).instantiate()
		link_models.append(MapNodeLink)
		add_child(MapNodeLink)
		
		var vector: Vector3 = \
		map_location_to_node[link.map_location].position - map_location_to_node[map_location].position
		MapNodeLink.setInfo(vector, link.is_holy)
		
func isMapNodeLink(map_node: MapNodeGD) -> bool:
	return map_node.map_location in links.map(func(x: MapLink): return x.map_location)
#endregion
		
#region Selected
func onSelected(speed: float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_method(setAlphagreyMaterialValue, 0.0, 1.0, speed)
	
	for link_model in link_models: link_model.onMapNodeSelected()
	await tween.finished
	entered.emit(self)
	
func onDeselected(speed: float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_method(setAlphagreyMaterialValue.bind(mesh), 1.0, 0.0, speed)
	
	for link_model in link_models: link_model.onMapNodeDeselected()
#endregion

#region Setters
func setAlphagreyMaterialValue(value: float) -> void:
	mesh.set_instance_shader_parameter("time_value", value)

func setPosition(map_locations: Array) -> void:
	var pos := Vector3((map_location.progress * PROGRESS_OFFSET) + CENTER_PROGRESS_OFFSET, 0.3, 0)
	var lanes: Array = map_locations.filter(func(x: MapLocation): return x.progress == map_location.progress)\
	.map(func(x: MapLocation): return x.lane)
	var _direction: int = 0
	
	match lanes.size():
		2: _direction = -1 if lanes.max() == 1 else 1
		4: _direction = -1 if lanes.max() == 2 else 1
	
	pos.z = (map_location.lane + (_direction * 0.5)) * LANE_OFFSET
	position = pos
	
func setRayPickable(state: bool) -> void:
	for static_body in Helper.getNodeTypeRecursive(self, StaticBody3D):
		static_body.input_ray_pickable = state
#endregion

#region Hovered
func onMouseHovered(state: bool) -> void:
	hovered.emit(self, state)

var hovered_state: bool
func onStaticBodyHovered(is_walkable: bool, state: bool) -> void:
	hovered_state = state
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
	direction *= -1
	var tween := get_tree().create_tween()
	tween.tween_property(Model, "position:y", DISTANCE * direction, SPEED).as_relative().set_trans(Tween.TRANS_SINE)
	tween.finished.connect(onTweenChain)
	
#endregion
