class_name TileObjectGD extends GameObjectGD

signal set_spectate_card
var SpectateCard: CardGD

var variation: int
#region Helper functions
func isIDVariation(id: int, _variation: int) -> bool: return info.id == id and _variation == variation
#endregion

#region Points
func getPoints() -> Array:
	return info.points[variation]

func onLoadPoints(parent: Node3D) -> void:
	for i in range(info.models.size()):
		if i >= info.points.size(): info.points.append([])
			
	for point in info.points[variation]:
		var Point: MeshInstance3D = load(info.POINT_PATH).instantiate()
		Point.setInfo(self)
		Point.position = point
		parent.add_child(Point)
		
	ResourceSaver.save(info)
	
func onCreatePoint(parent: Node3D, point: Vector3) -> void:
	var Point: MeshInstance3D = load(info.POINT_PATH).instantiate()
	Point.setInfo(self)
	Point.position = point
	parent.add_child(Point)
	info.points[variation].append(point)
	ResourceSaver.save(info)
	
func onRemovePoint(point: Vector3) -> void:
	info.points[variation].erase(point)
	ResourceSaver.save(info)
#endregion

#region Load
func onLoadData(data: SavedData) -> void:
	coords = data.coords
	tile_rotation = data.tile_rotation
	variation = data.variation
	
	if data.vision_datastore != null: vision_datastore = data.vision_datastore
	else: vision_datastore = VisionDatastore.new()
	
	add_to_group("TileObjectsGD")
	super(data)
	
func onLoadDataLevel() -> void:
	super()
	onApplyGreyscaleMaterial()
	
func onLoadModel() -> void:
	if Model != null: Model.queue_free()
	Model = info.getModel(variation).instantiate()
	add_child(Model)
	onAfterLoadModel()
	
func onAfterLoadModel() -> void:
	call("setDefaultCollisionLayers")
	setRayPickable(getRayPickable())
#endregion
	
#region Variations
func clampVariation(i: int) -> void:
	if variation >= 0:
		variation += i
		if variation >= info.models.size(): variation = 0
		elif variation < 0: variation = info.models.size() - 1
#endregion

#region Level Visible
func setLevelVisible(state: bool) -> void:
	super(state)
	onApplyGreyscaleMaterial()
				
func onApplyGreyscaleMaterial() -> void:
	var greyscale_material: ShaderMaterial = load(info.GREYSCALE_MATERIAL) if !vision_datastore.level_visible else null
	for mesh in getMeshes():
		for surface_id in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface_id, greyscale_material)
#endregion
