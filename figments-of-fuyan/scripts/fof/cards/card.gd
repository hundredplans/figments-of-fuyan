class_name CardGD extends GameObjectGD

#region Saved Data
var attack: int
var health: int
var speed: int
var max_speed: int
var max_health: int
var energy: int

var is_spectated: bool
var team: int
var ascended: bool

var card_place: Game.CardPlaces
var turn_state: Game.TurnStates

var draw_order: int
var Tile: TileGD
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

func setTileRotation(_tile_rotation: int) -> void:
	super(_tile_rotation)
	rotation.y += PI / 6

#endregion

#region Getters
func getAbilityText() -> String:
	if ascended and !info.ascended_ability_text.is_empty(): return info.ascended_ability_text
	return info.ability_text
	
func getArea() -> AreaInfo:
	for area_info in Helper.getFofInfoArray(AreaInfo):
		if info.id in area_info.card_ids: return area_info
	return null
	
func getStatHeightPosition() -> Vector3:
	return Vector3(position.x, info.stat, position.z)
	
func getMovementSpeed() -> int:
	return speed
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
	
func onWalk() -> void:
	if AniPlayer != null and AniPlayer.current_animation != "Walk": AniPlayer.play("Walk")
#endregion

#region Card
func onCreateCardUI(parent: Control, highlight_on_hover: bool = false) -> Control:
	var CardUI: Control = load(info.CARD_UI_SCENE_PATH).instantiate()
	parent.add_child(CardUI)
	CardUI.setInfo(self, highlight_on_hover)
	return CardUI
#endregion

#region Save/Load/Clear
func onSave() -> SavedDataCard:
	return SavedDataCard.new(info.id, false, coords, tile_rotation, level_visible, team, \
	attack, health, speed, max_speed, max_health, energy, ascended, draw_order, card_place, turn_state)

func onLoadData(data: SavedData) -> void:
	super(data)
	coords = data.coords
	team = data.team
	ascended = data.ascended
	turn_state = data.turn_state
	setBaseStats()
	onChangeCardPlace(data.card_place)
	add_to_group("CardsGD")
	
func onChangeCardPlace(place: Game.CardPlaces) -> void:
	if place != card_place:
		if card_place != Game.CardPlaces.NULL:
			remove_from_group(Game.CARD_PLACES_TO_GROUP[card_place])
			
		card_place = place
		add_to_group(Game.CARD_PLACES_TO_GROUP[card_place])
			
func onFofInit() -> void:
	setBaseStats()
	
func setBaseStats() -> void:
	attack = info.attack
	health = info.health
	speed = info.speed
	max_health = info.health
	energy = info.energy
	
	if ascended:
		attack += info.plus_attack
		health += info.plus_health
		speed += info.plus_speed
		max_health += info.plus_health
		energy += info.plus_energy
	
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
	
func onCreateEmptyModel(parent: Node3D) -> Node3D:
	var EmptyModel: Node3D = info.model.instantiate()
	parent.add_child(EmptyModel)
	return EmptyModel
	
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

#region Points
func onLoadPoints(parent: Node3D) -> void:
	for point in info.points:
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
	info.points.append(point)
	ResourceSaver.save(info)
	
func onRemovePoint(point: Vector3) -> void:
	info.points.erase(point)
	ResourceSaver.save(info)
#endregion

#region Position
func setPositionToTile() -> void:
	position = Tile.getCardPosition()
#endregion

#region Is Checks
func isAlly(_team: int = 0) -> bool:
	return team == _team
	
func isEnemy(_team: int = 0) -> bool:
	return team != _team

func isPlayable(_energy: int) -> bool:
	return _energy >= energy

#endregion

#region Inspect Card
var inspectable: bool
var InspectableParent: Control
func setInspectable(_inspectable: bool, _InspectableParent: Control = null) -> void:
	inspectable = _inspectable
	InspectableParent = _InspectableParent

func onInspectCard() -> void:
	if inspectable:
		var InspectCardScreen: Control = load(info.INSPECT_CARD_SCREEN).instantiate()
		InspectableParent.add_child(InspectCardScreen)
		InspectCardScreen.setInfo(self)
#endregion

#region TurnStates
func setTurnState(_turn_state: Game.TurnStates) -> void:
	turn_state = _turn_state
	
#endregion

#region Actions
func onProcessAction(action: Action) -> void:
	if !action.post:
		if action is MoveToTileAction and action.Card == self: onMoveToTile(action)
	elif action.post:
		if action is MovementFinishAction and action.Card == self: Tile.setOutlineMaterial()
#endregion

#region Movement
func onMoveToTile(action: MoveToTileAction) -> void:
	if !action.isJumpFall(): # Regular = Ramp movement
		onWalk()
		
		if action.movement_type == MoveToTileAction.MOVEMENT_TYPES.REGULAR:
			var tween := get_tree().create_tween()
			tween.tween_property(self, "position", action.DestinationTile.getCardPosition(), action.getDelay())
		else:
			var tween := get_tree().create_tween()
			tween.tween_property(self, "position", action.DestinationTile.getCardPosition(), action.getDelay() / 2)
		return
	
	onJumpAnimation()
	if action.movement_type == MoveToTileAction.MOVEMENT_TYPES.JUMP: onJump(action)
	elif action.movement_type == MoveToTileAction.MOVEMENT_TYPES.FALL: onFall(action)
	
const FALL_MULTIPLIER: float = 2.3

func onJumpAnimation() -> void:
	AniPlayer.play("Jump")

func onJump(action: MoveToTileAction) -> void:
	var jump_time: float = 1
	var jump_end: Vector3 = action.DestinationTile.getCardPosition()
	var jump_height: float = -4
	var start_highest: Vector3 = position + Vector3(0, jump_height, 0)
	var end_highest: Vector3 = jump_end + Vector3(0, jump_height, 0)
	
	AniPlayer.speed_scale = 2
	
	onTweenJumpFall(jump_end, start_highest, end_highest, jump_time)
	await get_tree().create_timer(action.getDelay()).timeout
	
	AniPlayer.speed_scale = 1
	

func onFall(action: MoveToTileAction) -> void:
	var height_diff: int = abs(action.DestinationTile.getHeight() - Tile.getHeight())
	var jump_end: Vector3 = action.DestinationTile.getCardPosition()
	var jump_height: float = -3 + (height_diff * FALL_MULTIPLIER)
	var start_highest: Vector3 = position + Vector3(0, jump_height, 0)
	var end_highest: Vector3 = jump_end + Vector3(0, jump_height, 0)
	
	AniPlayer.speed_scale = 2.0 / action.fall_time
	onTweenJumpFall(jump_end, start_highest, end_highest, action.fall_time)
	await get_tree().create_timer(action.getDelay()).timeout
	
	AniPlayer.speed_scale = 1
	
func onTweenJumpFall(jump_end: Vector3, start_highest: Vector3, end_highest: Vector3, jump_time: float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_method(onJumpFall.bind(Tile.getCardPosition(), jump_end, start_highest, end_highest), 0.0, 1.0, jump_time)
	onJumpAnimation()
	
func onJumpFall(time: float, jump_start: Vector3, jump_end: Vector3, start_highest: Vector3, end_highest: Vector3) -> void:
	position = jump_start.cubic_interpolate(jump_end, start_highest, end_highest, time)
#endregion

#region Spectated
func onSpectated(state: bool) -> void:
	is_spectated = state
	FieldInfo.onSpectated(state)
#endregion

#region Field Info
var FieldInfo: Node3D
func onCreateFieldInfo() -> void:
	FieldInfo = load(info.FIELD_INFO_SCENE_PATH).instantiate()
	Model.add_child(FieldInfo)
	FieldInfo.setInfo(self)
#endregion
