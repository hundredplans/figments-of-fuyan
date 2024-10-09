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

var attacks: int
var field_traits: Array = []
var status_effects: Array = []

var delayed_stats: Array[StatAction]
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
	setCollisionLayers(96)
	
func setCollisionLayers(layer: int) -> void:
	for body in getStaticBodies(): body.collision_layer = layer
	
func setMapPosition() -> void:
	position = Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)

func setTileRotation(_tile_rotation: int) -> void:
	tile_rotation = _tile_rotation
	Model.rotation.y = (tile_rotation * (PI / 3)) + (PI / 6)
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
	
func getCoords() -> Vector4i:
	return Tile.getCoords()
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
	
func onAttack() -> void:
	AniPlayer.play("Attack")
	
func onHurt() -> void:
	AniPlayer.play("Hurt")
	
func onDeath() -> void:
	AniPlayer.play("Death")
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
	return SavedDataCard.new(info.id, false, coords, tile_rotation, level_visible, is_revealed, team, \
	attack, health, speed, max_speed, max_health, energy, ascended, draw_order, card_place, turn_state,\
	SavedData.onSaveGroup(field_traits), SavedData.onSaveGroup(status_effects), attacks)

func onLoadData(data: SavedData) -> void:
	super(data)
	coords = data.coords
	team = data.team
	ascended = data.ascended
	turn_state = data.turn_state
	attacks = data.attacks
	
	for field_trait_data in data.field_traits:
		field_traits.append(SavedData.onLoadModel(field_trait_data, self))
	
	for status_effect_data in data.status_effects:
		status_effects.append(SavedData.onLoadModel(status_effect_data, self))
	
	onCreateAdjustedPoints()
	
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
	energy = info.energy
	
	if ascended:
		attack += info.plus_attack
		health += info.plus_health
		speed += info.plus_speed
		energy += info.plus_energy
		
	max_health = info.health
	max_speed = info.speed
	
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
	var old_rotation: Vector3 = Model.rotation
	Model.look_at(node.position, Vector3(0, 1, 0), true)
	Model.rotation = Vector3(old_rotation.x, Model.rotation.y, old_rotation.z)
#endregion

#region Points
func getPoints() -> Array:
	return info.points

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

func isAdjacent(_coords: Vector4i, distance: int = 1) -> bool:
	return Tile.isAdjacent(_coords, distance)
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
	if turn_state != _turn_state:
		turn_state = _turn_state
		FieldInfo.setInfoSpriteTurnState()
		match turn_state:
			Game.TurnStates.INACTIVE:
				onPushAction([ChangeAttacksAction.new(self, getMaxAttacks()), StatAction.new(self, Game.Stats.SPEED, max_speed, 0, 0, true)])
	
#endregion

#region Actions
func onProcessAction(action: Action) -> void:
	if Game.CardPlaces.FIELD == card_place:
		if !action.post:
			if action is MoveToTileAction and action.Card == self: onMoveToTile(action)
		elif action.post:
			if action is MovementFinishAction and action.Card == self: Tile.setOutlineMaterial()
			elif action is ChangePhaseAction and Game.isAdvanceTurn(action.phase, team):
				onAdvanceTurn()
				
	elif Game.CardPlaces.GRAVEYARD == card_place:
		if action.post:
			if action is DeathAction and action.Defender == self:
				onRemoveModel()
				onRemoveFieldInfo()
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
			
			if action.DestinationTile.isRamp():
				tween.tween_property(self, "position", Tile.getHalfwayCardPosition(action.DestinationTile), action.getDelay() / 2.0)
				tween.tween_property(self, "position", action.DestinationTile.getCardPosition(), action.getDelay() / 2.0)
			elif Tile.isRamp():
				tween.tween_property(self, "position", action.DestinationTile.getHalfwayCardPosition(Tile), action.getDelay() / 2.0)
				tween.tween_property(self, "position", action.DestinationTile.getCardPosition(), action.getDelay() / 2.0)
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
	add_child(FieldInfo)
	FieldInfo.setInfo(self)
	
func onRemoveFieldInfo() -> void:
	FieldInfo.queue_free()
	
func onCameraPositionUpdated(pos: Vector3) -> void:
	FieldInfo.onCameraPositionUpdated(pos)
#endregion

#region Awaken
func onAwaken() -> void:
	onCreateModel()
	onIdle()
	onCreateFieldInfo()
	onCreateVisionRay()
	setPositionToTile()
	setTileRotation(tile_rotation)
	setTurnState(turn_state)
	setLevelVisible(level_visible)
	
	onPushAction(AddStatusEffectAction.new(SavedData.onLoadModel(SavedDataStatusEffect.new(2, false, 1, getCoords()), self)))
#endregion

#region Vision
var visible_game_objects: Dictionary = {}
var VisionRay: RayCast3D
const BASE_VISION_RANGE: int = 5
const EXTRA_RAY_LENGTH: float = 1.05

func onUpdateVision() -> Array:
	var updated_visible_game_objects: Dictionary = {}
	if card_place != Game.CardPlaces.GRAVEYARD:
		
		get_tree().call_group("FieldCardsGD", "setDetectableByRay", false)
		var tile_objects: Array = Game.getAdjacentOrCloserTiles(Tile, BASE_VISION_RANGE)
		
		var cards: Array = []
		for VisionTile in tile_objects.duplicate():
			var Card: CardGD = Game.getFieldCard(VisionTile)
			if Card != null and !Card.isInvisible() and Card != self: cards.append(Card); Card.setDetectableByRay(true)
		
		for obj_array in tile_objects.map(func(x: GameObjectGD): return x.occupied_objects):
			for Obj in obj_array: tile_objects.append(Obj)
			
		tile_objects += cards
		var point_batches: Array = tile_objects.map(func(x: GameObjectGD): return x.adjusted_points)
		for point_batch in point_batches:
			for point in point_batch:
				VisionRay.target_position = (point - VisionRay.global_position) * EXTRA_RAY_LENGTH
				VisionRay.force_raycast_update()
				if VisionRay.is_colliding():
					var GameObject: GameObjectGD = Helper.getCollision(VisionRay.get_collider(), GameObjectGD)
					if GameObject in tile_objects:
						updated_visible_game_objects[GameObject] = null
	else: updated_visible_game_objects = {}
	
	return updated_visible_game_objects.keys()
	
func getVisibleFieldCards() -> Array:
	return visible_game_objects.keys().filter(func(x: GameObjectGD): return x is CardGD)
	
func getVisibleTiles() -> Array:
	return visible_game_objects.keys().filter(func(x: GameObjectGD): return x is TileGD)
	
func getVisibleGameObjects() -> Array:
	return visible_game_objects.keys()
	
func onCreateVisionRay() -> void:
	VisionRay = load(info.VISION_RAY_SCENE_PATH).instantiate()
	add_child(VisionRay)
	VisionRay.position.y = info.eye
	
func setLevelVisible(state: bool) -> void:
	super(state)
	visible = state
	
func setDetectableByRay(state: bool) -> void:
	if state: setCollisionLayers(96)
	else: setCollisionLayers(32)
#endregion

#region Invisible
func isInvisible() -> bool:
	return false
#endregion

#region Fall Damage
var temp_fall_damage: int = 0
func isCardSurviveFallDamage(_temp_fall_damage: int) -> bool:
	temp_fall_damage += _temp_fall_damage
	return temp_fall_damage < health
#endregion

#region Attacks and Range
func setEnemyInMovementRange(state: bool) -> void:
	if !isAlly(0): FieldInfo.setInfoSpriteEnemyInMovementRange(state)

func isAttackable(GameObject: GameObjectGD) -> bool:
	if GameObject is CardGD: return !GameObject.isAlly(team)
	return false
	
func getAttackDamage() -> int:
	return attack
	
func getAttackRange() -> int:
	for field_trait in field_traits:
		if field_trait is RangedGD: return field_trait.ranged
	return 1 
	
func canAttack() -> bool: return attacks > 0
	
func getMaxAttacks() -> int: return 1
	
func setAttacks(_attacks: int) -> void: attacks = _attacks
	
func getAttackablesInRange() -> Array:
	if !canAttack(): return []
	var cards: Array = get_tree().get_nodes_in_group("FieldCardsGD")
	cards = cards.filter(func(x: GameObjectGD): \
		return x.isAttackable(self) and\
		Game.getCoordsDistance(Tile.getCoords(), x.Tile.getCoords()) <= speed + getAttackRange() and\
		x.position.y <= position.y + info.top)
	return cards
#endregion

#region Damage
func onDMG(Damager: GameObjectGD, damage: int) -> void:
	var old_health: int = health
	var health_damage: int = old_health - min(health - damage, 0)
	Damager.onPushAction(StatAction.new(self, Game.Stats.HEALTH, -health_damage))

func onTakeDamage(Damager: GameObjectGD, damage: int) -> int: # Returns damage dealt
	var old_health: int = health
	damage = onApplyArmor(damage)
	health = max(health - damage, 0)
	var health_damage: int = old_health - health
	
	FieldInfo.onUpdateStat(Game.Stats.HEALTH, health, level_visible)
	if health == 0: onPushAction(DeathAction.new(Damager, self, damage, health_damage))
	else: onPushAction(HurtAction.new(Damager, self, damage, health_damage))
	return health_damage
#endregion

#region Speed
func onUpdateStat(type: Game.Stats, difference: int, show_particles: bool, include_action_delay: bool) -> void:
	var play_animation: bool = include_action_delay and level_visible
	var value: int = 0
	match type:
		Game.Stats.ATTACK: value = attack
		Game.Stats.HEALTH: value = health
		Game.Stats.SPEED: value = speed
	
	FieldInfo.onUpdateStat(type, value, difference, play_animation, show_particles)
#endregion

#region Traits
func onCreateInitialTraits() -> void:
	var initial_traits: Array = []
	if !ascended: initial_traits = info.initial_traits
	else: initial_traits = info.ascended_traits
	
	for field_trait_data in initial_traits:
		field_trait_data.coords = getCoords()
		field_traits.append(SavedData.onLoadModel(field_trait_data, self))
	FieldInfo.onUpdateTraits()
		
func onApplyArmor(damage: int) -> int:
	for field_trait in field_traits:
		if field_trait is ArmorGD: damage -= field_trait.armor
	return damage
	
func isMobile() -> bool:
	return field_traits.any(func(x: TraitGD): return x is MobileGD)
#endregion

#region Status Effects
func onRemoveStatusEffect(status_effect: StatusEffectGD) -> void:
	status_effects.erase(status_effect)
	FieldInfo.onRemoveIcon(status_effect)
	
func onAddStatusEffect(status_effect: StatusEffectGD) -> void:
	status_effects.append(status_effect)
	FieldInfo.onAddIcon(status_effect)
#endregion

#region Advance Turn
func onAdvanceTurn() -> void:
	var actions: Array = [StatAction.new(self, Game.Stats.SPEED, max_speed, 0, 0, true, false, false), ChangeTurnStateAction.new(self, Game.TurnStates.INACTIVE)]
	onPushAction(actions)
#endregion
