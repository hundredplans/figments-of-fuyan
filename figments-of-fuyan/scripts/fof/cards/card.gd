class_name CardGD extends GameObjectGD

#region Saved Data
var team: int
#endregion

#region Signals
signal mouse_entered
signal mouse_exited
#endregion

#region Setters
func setOwner(node: Node) -> void:
	owner = node
	get_child(0).owner = node

func setScale(_scale: Vector3) -> void:
	scale = _scale
	
func setScaleUniform(x: float) -> void:
	scale = Vector3(x, x, x)

func setDefaultCollisionLayers() -> void:
	for body in getStaticBodies(): body.collision_layer = 480
	
func setMapPosition() -> void:
	position = Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)
#endregion

#region Getters
	
func getArea() -> AreaInfo:
	for area_info in Helper.getResourcesRecursive(AreaInfo):
		if info in area_info.cards: return area_info
	return null
	
func getStatHeightPosition() -> Vector3:
	return Vector3(position.x, info.height.stat_height, position.z)
#endregion

#region Animation

func setAniPlayer() -> void:
	for child in Helper.getChildrenRecursive(self):
		if child is AnimationPlayer: AniPlayer = child; return

var AniPlayer: AnimationPlayer
func onIdle() -> void:
	if AniPlayer != null: AniPlayer.play("Idle")
#endregion

#region Card
func onCreateCardUI(parent: Control) -> Control:
	var CardUI: Control = load(info.CARD_UI_SCENE_PATH).instantiate()
	parent.add_child(CardUI)
	CardUI.setInfo(self)
	return CardUI
#endregion

#region Save/Load/Clear
func onSave() -> SavedDataCard:
	return SavedDataCard.new(info.id, coords, tile_rotation, team)

func onLoadData(data: SavedData) -> void:
	super(data)
	team = data.team
	add_to_group("CardsGD")
	
func onCreateModel() -> void:
	Model = info.model.instantiate()
	add_child(Model)
	
	var body := StaticBody3D.new()
	Model.add_child(body)
	
	if info.collision_shape != null: body.add_child(info.collision_shape.instantiate())
	body.collision_mask = 0
	body.mouse_entered.connect(func(): mouse_entered.emit(self))
	body.mouse_exited.connect(func(): mouse_exited.emit(self))
		
	setDefaultCollisionLayers()
	setAniPlayer()
#endregion
