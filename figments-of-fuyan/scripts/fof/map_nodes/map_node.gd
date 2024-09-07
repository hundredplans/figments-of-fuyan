class_name MapNodeGD extends FofGD

#region Globals
signal hovered
signal pressed
signal entered
var map_location: MapLocation
var link_models: Array
var links: Array
var Model: Node3D

const PROGRESS_OFFSET: float = 3
const LANE_OFFSET: float = 4
const CENTER_PROGRESS_OFFSET: float = -15
#endregion

func onFofInit() -> void: pass

#region Base Functions
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and hovered_state:
		pressed.emit(self)
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
	add_child(Model)
	setPosition(map_locations)
	
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
		
		var vector: Vector3 = map_location_to_node[link.map_location].position - map_location_to_node[map_location].position
		MapNodeLink.setInfo(vector, link.is_holy)
		
func isMapNodeLink(map_node: MapNodeGD) -> bool:
	return map_node.map_location in links.map(func(x: MapLink): return x.map_location)
#endregion
		
#region Selected
func onSelected(speed: float) -> void:
	var mesh: MeshInstance3D = Helper.getNodeTypeRecursive(Model, MeshInstance3D)[0]
	var tween := get_tree().create_tween()
	tween.tween_method(setAlphagreyMaterialValue.bind(mesh), 0.0, 1.0, speed)
	
	for link_model in link_models: link_model.onMapNodeSelected()
	await tween.finished
	entered.emit(self)
	
func onDeselected(speed: float) -> void:
	var mesh: MeshInstance3D = Helper.getNodeTypeRecursive(Model, MeshInstance3D)[0]
	var tween := get_tree().create_tween()
	tween.tween_method(setAlphagreyMaterialValue.bind(mesh), 1.0, 0.0, speed)
	
	for link_model in link_models: link_model.onMapNodeDeselected()
#endregion

#region Setters
func setAlphagreyMaterialValue(value: float, mesh: MeshInstance3D) -> void:
	mesh.set_instance_shader_parameter("time_value", value)

func setPosition(map_locations: Array) -> void:
	var pos := Vector3((map_location.progress * PROGRESS_OFFSET) + CENTER_PROGRESS_OFFSET, 0.3, 0)
	var lanes: Array = map_locations.filter(func(x: MapLocation): return x.progress == map_location.progress)\
	.map(func(x: MapLocation): return x.lane)
	var direction: int = 0
	
	match lanes.size():
		2: direction = -1 if lanes.max() == 1 else 1
		4: direction = -1 if lanes.max() == 2 else 1
	
	pos.z = (map_location.lane + (direction * 0.5)) * LANE_OFFSET
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
	
	for mesh in Helper.getNodeTypeRecursive(Model, MeshInstance3D):
		mesh.set_surface_override_material(0, mat)
#endregion
