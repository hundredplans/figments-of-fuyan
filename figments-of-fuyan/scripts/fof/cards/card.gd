class_name CardGD extends GameObjectGD

#region Saved Data
var team: int
var is_in_deck: bool
#endregion

#region Globals
const DEFAULT_ANIMATION_BLEND_TIME: float = 0.2
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
	for area_info in Helper.getFofInfoArray(AreaInfo):
		if info.id in area_info.card_ids: return area_info
	return null
	
func getStatHeightPosition() -> Vector3:
	return Vector3(position.x, info.stat, position.z)
#endregion

#region Animation

func setAniPlayer() -> void:
	for child in Helper.getChildrenRecursive(self):
		if child is AnimationPlayer:
			AniPlayer = child
			AniPlayer.playback_default_blend_time = DEFAULT_ANIMATION_BLEND_TIME
			return

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
	return SavedDataCard.new(info.id, false, coords, tile_rotation, team, is_in_deck)

func onLoadData(data: SavedData) -> void:
	super(data)
	team = data.team
	
	is_in_deck = data.is_in_deck
	if is_in_deck: add_to_group("DeckCardsGD")
	
	add_to_group("CardsGD")
	
func onCreateModel() -> void:
	onRemoveModel()
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
	
func onRemoveModel() -> void:
	if Model != null: Model.queue_free()
#endregion

#region Walk
func onWalkTo(pos: Vector3, walk_speed: float) -> void:
	AniPlayer.play("Walk")
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", pos, walk_speed)
	await tween.finished
	onIdle()
	
#endregion

#region look at
func onLookAtObjectOnlyY(node: Node) -> void:
	var old_rotation: Vector3 = rotation
	look_at(node.position, Vector3(0, 1, 0), true)
	rotation = Vector3(old_rotation.x, rotation.y, old_rotation.z)
#endregion
