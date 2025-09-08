class_name GameObjectGD extends FofGD

#region Saved Data
var Model: Node3D
var coords: Vector4i
var tile_rotation: int
var adjusted_points: Array = []

var vision_datastore: VisionDatastore
#endregion

#region Helper Functions
func getMeshes(parent: Node3D = self) -> Array[MeshInstance3D]:
	var arr: Array[MeshInstance3D] = []
	arr.assign(Helper.getChildrenRecursive(parent).filter(func(x: Node): return x is MeshInstance3D))
	return arr

func getStaticBodies() -> Array: return []
#endregion

#region Getters
func getLockRotation() -> bool: return false

func getRayPickable() -> bool:
	for body in getStaticBodies(): return body.input_ray_pickable
	return false
#endregion

#region Setters
func setOwner(new_owner: Node3D) -> void:
	owner = new_owner
	for child in get_children(): child.owner = new_owner

func setRayPickable(state: bool) -> void:
	for body in getStaticBodies():
		body.input_ray_pickable = state
	
func getTileRotationFromRotation() -> int:
	return (int((rotation_degrees.y + 30) / 60) % 6)
	
func getTileRotationForce() -> int:
	return tile_rotation if info.lock_rotation else getTileRotationFromRotation()

func onRotateDirection(direction: int) -> void:
	tile_rotation += direction
	if tile_rotation > 5: tile_rotation = 0
	elif tile_rotation < 0: tile_rotation = 5
	setTileRotation(tile_rotation)

func setTileRotation(_tile_rotation: int) -> void:
	tile_rotation = _tile_rotation
	rotation.y = (tile_rotation * (PI / 3))
	
func setCoords(_coords: Vector4i) -> void:
	coords = _coords
	setMapPosition()
	
func setMapPosition() -> void:
	position = Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), coords.w * 0.6, coords.y * 3 / 2.0)
#endregion

#region Save/Load/Clear
func onLoadData(data: SavedData) -> void:
	super(data)
	vision_datastore = data.vision_datastore
	add_to_group("GameObjectsGD")
	
func onLoadDataLevel() -> void:
	pass
	
func onLoadDataLevelFofInit() -> void:
	pass
	
func onFofInit() -> void:
	pass
	
func onProcessAction(action: Action) -> void:
	if action.post:
		if action is ChangePhaseAction and action.phase in Game.ADVANCE_PHASES:
			onAdvanceTurn(Game.ADVANCE_PHASES.find(action.phase))
		elif action is ChangeTurnStateAction and action.turn_state == Game.TurnStates.PASSED:
			onCardTurnPassed(action.Card)
#endregion

#region Material Updates

func setRegularMaterial() -> void:
	setMeshesMaterial()
	
func setMeshesMaterial(mat: Material = null, parent: Node3D = self) -> void:
	for mesh in getMeshes(parent):
		for surface in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(surface, mat)
				
func setCollisionLayers(layer: int) -> void:
	for body in getStaticBodies():
		body.collision_layer = layer
#endregion

#region Level Visible
func isRevealed(team: int = -1) -> bool:
	return vision_datastore.isRevealed(team)
	
func onRevealed(revealed_datastore: RevealedDatastore) -> void:
	vision_datastore.onRevealed(revealed_datastore)
	
func onRemoveReveal(revealed_id: int) -> void:
	vision_datastore.onRemoveReveal(revealed_id)
	
func isLevelVisible() -> bool:
	return vision_datastore.level_visible
	
func setLevelVisible(state: bool) -> void:
	vision_datastore.level_visible = state
	onUpdateLevelVisible()
	
func onUpdateLevelVisible() -> void: pass
#endregion

#region Points
func getLevelPoints() -> Array:
	return call("getPoints")
		
func getAdjustedPoints() -> Array:
	return adjusted_points
#endregion

#region Advance Turn
func onAdvanceTurn(_team: int) -> void:
	pass

func onCardTurnPassed(_Card: CardGD) -> void:
	pass
#endregion
