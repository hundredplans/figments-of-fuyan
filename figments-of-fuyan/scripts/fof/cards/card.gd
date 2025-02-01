class_name CardGD extends GameObjectGD

#region Saved Data
var base_stats: StatsDatastore # Can be updated, are set when unit is first loaded in

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
var attack_range: int
var status_effects: Array = []

var delayed_stats: Array[StatInfo]
var ability_save: Dictionary
var active_effects: Array[ActiveEffectDatastore]
var field_effects: Array[FieldEffectGD]

var anibility_datastore: AnibilityDatastore
var temporary_card_conditions: Array = [] # Array of map effects

var Tool: ToolGD
var is_awakened_in_combat: bool
var overworld_traits: Array[OverworldTrait] = []
var bounty_kills: BountyKills
var card_vision_mode: CardVisionMode
var is_card_change_level_visible: bool # Not saved
var ai_datastore: AIDatastore
#endregion

#region Globals
const DEFAULT_ANIMATION_BLEND_TIME: float = 0.2
const IDLE_RARE_MIN_TIME: int = 12
const IDLE_RARE_MAX_TIME: int = 80
const ALPHAGREY_CHANGE_SPEED: float = 0.5
#endregion

#region Signals
signal inspect_screen_created
signal tool_added
signal mouse_entered
signal mouse_exited
signal update_ascended
signal temporary_card_conditions_updated
signal update_active_effect_description
signal awakened_in_combat
signal update_stats
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
	layer = 0 if is_in_group("GraveyardCardsGD") else layer
	for body in getStaticBodies():
		body.collision_layer = layer
	
func setMapPosition() -> void:
	position = Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)

func setTileRotation(_tile_rotation: int) -> void:
	tile_rotation = _tile_rotation
	Model.rotation.y = (tile_rotation * (PI / 3)) + (PI / 6)
	
func setIdleAbility(state: bool) -> void:
	anibility_datastore.is_idle_ability = state
	if AniPlayer.current_animation.begins_with("Idle"):
		onIdle()
		
func setAttackAbility(state: bool, play_attack_animation: bool = true) -> void:
	anibility_datastore.is_attack_ability = state
	if play_attack_animation:
		onAttack()
		
func setDeathAbility(state: bool, play_death_animation: bool = true) -> void:
	anibility_datastore.is_death_ability = state
	if play_death_animation:
		onDeath()
		
func setAwakenedInCombat(state: bool) -> void:
	is_awakened_in_combat = state
	awakened_in_combat.emit(state)
	
func setStats(stats: StatsDatastore) -> void:
	attack = stats.attack
	health = stats.health
	max_health = stats.health
	speed = stats.speed
	max_speed = stats.speed
	energy = stats.energy
#endregion

#region Getters
func getDescription() -> String:
	return info.getDescription(ascended)
	
func getAscended() -> bool:
	return ascended
	
func getArea() -> AreaInfo:
	for area_info in Helper.getFofInfoArray(AreaInfo):
		if info.id in area_info.card_ids: return area_info
	return null
	
func getMovementSpeed() -> int:
	return speed
	
func getCoords() -> Vector4i:
	return Tile.getCoords()
	
func getTile() -> TileGD:
	return Tile
#endregion

#region Animation
func setAniPlayer(Model: Node3D) -> void:
	for child in Helper.getChildrenRecursive(Model):
		if child is AnimationPlayer and !child.is_queued_for_deletion():
			AniPlayer = child
			AniPlayer.animation_finished.connect(onAnimationFinished)
			AniPlayer.playback_default_blend_time = DEFAULT_ANIMATION_BLEND_TIME
			return

var AniPlayer: AnimationPlayer

func onPlayAnimation(animation_name: String) -> void:
	if AniPlayer != null:
		match animation_name:
			"Walk": if AniPlayer.current_animation == "Walk": return
		
		AniPlayer.play(animation_name)
		AniPlayer.set_current_animation(animation_name)
		
func onAnimationFinished(ani_name: String) -> void:
	if !ani_name.begins_with("Death"): onIdle()
		
func onJump() -> void:
	AniPlayer.stop()
	onPlayAnimation("Jump")
		
func onAttack() -> void:
	onPlayAnimation("Attack" if !anibility_datastore.is_idle_ability else "AttackAbility")
		
func onWalk() -> void:
	onPlayAnimation("Walk")
	
func onIdle() -> void:
	onPlayAnimation("Idle" if !anibility_datastore.is_idle_ability else "IdleAbility")
	
func onDeath() -> void:
	onPlayAnimation("Death" if !anibility_datastore.is_death_ability else "DeathAbility")
	
func onHurt() -> void:
	onPlayAnimation("Hurt")
	
func onAbility() -> void:
	onPlayAnimation("Ability")
	
func onIdleRare() -> void:
	onPlayAnimation("IdleRare")
	
func isWalking() -> bool:
	return AniPlayer.current_animation.begins_with("Walk")
	
func onPauseAnimation(state: bool = true) -> void:
	if state: AniPlayer.pause()
	else: AniPlayer.play()
#endregion

#region Card
func onCreateCardUI(parent: Control, highlight_on_hover: bool = false, inspectable: bool = true, DraggableParent: Control = null) -> Control:
	var CardUI: Control = load(info.CARD_UI_SCENE_PATH).instantiate()
	parent.add_child(CardUI)
	CardUI.setInfo(self, highlight_on_hover, inspectable, DraggableParent)
	return CardUI
#endregion

#region Save/Load/Clear
func _ready() -> void:
	update_ascended.connect(onAscendedUpdated)

func onSave() -> SavedDataCard:
	var tool_data: SavedDataTool = Tool.onSave() if Tool != null else null
	for stat_info in delayed_stats: stat_info.onSave()
	for overworld_trait in overworld_traits: overworld_trait.onSave()

	vision_datastore.onSave()
	ai_datastore.onSave()
	
	return SavedDataCard.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, team, ascended, \
	attack, health, speed, max_speed, max_health, energy, draw_order, card_place, turn_state, SavedData.onSaveGroup(status_effects), attacks, attack_range, delayed_stats,\
	ability_save, active_effects, tool_data, SavedData.onSaveGroup(field_effects), anibility_datastore,\
	SavedData.onSaveGroup(temporary_card_conditions), is_awakened_in_combat, ai_datastore, base_stats,
	overworld_traits, bounty_kills)

func onLoadData(data: SavedData) -> void:
	super(data)
	coords = data.coords
	team = data.team
	ascended = data.ascended
	turn_state = data.turn_state
	attacks = data.attacks
	status_effects_datas = data.status_effects
	tile_rotation = data.tile_rotation
	delayed_stats = data.delayed_stats
	ability_save = data.ability_save
	active_effects = data.active_effects
	attack = data.attack
	attack_range = data.attack_range
	health = data.health
	max_health = data.max_health
	speed = data.speed
	max_speed = data.max_speed
	energy = data.energy
	anibility_datastore = data.anibility_datastore
	field_effects_datas = data.field_effects
	ai_datastore = data.ai_datastore
	base_stats = data.base_stats
	overworld_traits = data.overworld_traits
	bounty_kills = data.bounty_kills
	
	temporary_card_conditions = temporary_card_conditions.map(func(x: SavedDataMapEffect): return SavedData.onLoadModel(x, self))
	if data.tool_data != null:
		Tool = SavedData.onLoadModel(data.tool_data, self)
		Tool.Card = self
		onAddTool(Tool)
	
	for active_effect in active_effects:
		active_effect.owner = self
	
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
	onChangeCardPlace(data.card_place)
	add_to_group("CardsGD")
	
func onLoadDataLevel() -> void:
	super()
	if card_place == Game.CardPlaces.FIELD:
		Tile = Game.getTile(coords)
		
		for stat_info in delayed_stats: stat_info.onLoad()
		
		onAwaken()
		onLoadTraits()
		onLoadStatusEffects()
		onLoadFieldEffects()
		vision_datastore.onLoad()
		ai_datastore.onLoad()
	
func onLoadDataLevelFofInit() -> void:
	super()
	if !Game.isChampion(info.rarity):
		if is_in_group("HandCardsGD"): return
		onPushAction(AddToDeckAction.new(self, AddToDeckAction.ADD_TYPES.SHUFFLE))
	else:
		onPushAction(InsertAction.new(self))
	
func onFofInit() -> void:
	super()
	base_stats = StatsDatastore.new(attack, max_health, max_speed, energy)
	
	var initial_traits: Array = []
	if !ascended: initial_traits = info.initial_traits.duplicate()
	else: initial_traits = info.ascended_traits.duplicate()
	
	for trait_data in initial_traits:
		var added_by := OverworldTrait.AddedBy.ASCENDED if ascended else OverworldTrait.AddedBy.REGULAR
		onAddOverworldTrait(OverworldTrait.new(trait_data, added_by))
	
var status_effects_datas: Array
var field_effects_datas: Array
func onLoadTraits() -> void:
	for overworld_trait in overworld_traits:
		overworld_trait.onLoad(self)
		onAddFieldTrait(overworld_trait)

func onLoadStatusEffects() -> void:
	for status_effect_data in status_effects_datas:
		onAddStatusEffect(SavedData.onLoadModel(status_effect_data, self))
	
func onLoadFieldEffects() -> void:
	for field_effect_data in field_effects_datas:
		onAddFieldEffect(SavedData.onLoadModel(field_effect_data, self))
	
func onChangeCardPlace(place: Game.CardPlaces) -> void:
	if place != card_place:
		if card_place != Game.CardPlaces.NULL:
			remove_from_group(Game.CARD_PLACES_TO_GROUP[card_place])
			
		card_place = place
		add_to_group(Game.CARD_PLACES_TO_GROUP[card_place])
		
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
	setAniPlayer(Model)
	setBaseMaterials()
	
func onCreateEmptyModel(parent: Node3D) -> Node3D:
	var EmptyModel: Node3D = info.model.instantiate()
	parent.add_child(EmptyModel)
	return EmptyModel
	
func onRemoveModel() -> void:
	if Model != null: Model.queue_free()
	if FieldInfo != null: FieldInfo.queue_free()
#endregion

#region Walk
func onWalkTo(pos: Vector3, walk_speed: float) -> void:
	AniPlayer.play("Walk")
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", pos, walk_speed)
	await tween.finished
	AniPlayer.play("Idle")
	
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
		inspect_screen_created.emit(InspectCardScreen)
#endregion

#region TurnStates
func setTurnState(_turn_state: Game.TurnStates) -> void:
	turn_state = _turn_state
	FieldInfo.setInfoSpriteTurnState()
	
	if turn_state == Game.TurnStates.PASSED:
		for stat_info in delayed_stats.duplicate():
			stat_info.onCardTurnPassed()
		
		ai_datastore.onCardTurnPassed()
	
#endregion

#region Actions
func onProcessAction(action: Action) -> void:
	super(action)
	if Game.CardPlaces.FIELD == card_place:
		if !action.post:
			if action is MoveToTileAction and action.Card == self:
				onMoveToTile(action)
		elif action.post:
			if action is MovementFinishAction and action.Card == self: Tile.setOutlineMaterial()
			#elif isOccupyVisionVisibleAction(action):
				#onAddUnitVisibleParticle()
			elif action is AttackAction and action.Attacker.isEnemy(team) and action.Attacker in getVisibleFieldCardsEnemies():
				ai_datastore.setLastSeenViolence(0)
			elif isValidRampage(action):
				onBountyKill(action) # Needs to be here instead of in death action
			
	elif Game.CardPlaces.GRAVEYARD == card_place:
		if action.post:
			if action is DeathAction and action.Defender == self:
				onRemoveModel()
				onRemoveFieldInfo()

func isOccupyVisionVisibleAction(action: Action) -> bool:
	if action is not VisionNewUnitAction: return false
	if !action.enter_vision: return false
	if isAlly(0): return false
	if action.Discovered != self: return false
	if action.owner == null: return false
	if action.owner is not VisionAction: return false
	if action.owner.owner == null: return false
	if action.owner.owner is not OccupyAction: return false
	return true
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
	
	onJump()
	if action.movement_type == MoveToTileAction.MOVEMENT_TYPES.JUMP: onJumpTween(action)
	elif action.movement_type == MoveToTileAction.MOVEMENT_TYPES.FALL: onFall(action)
	
const JUMP_SPEEDSCALE: float = 2.5
func onJumpTween(action: MoveToTileAction) -> void:
	var jump_time: float = 1
	var jump_end: Vector3 = action.DestinationTile.getCardPosition()
	var jump_height: float = -4
	var start_highest: Vector3 = position + Vector3(0, jump_height, 0)
	var end_highest: Vector3 = jump_end + Vector3(0, jump_height, 0)
	
	AniPlayer.speed_scale = JUMP_SPEEDSCALE
	
	onTweenJumpFall(jump_end, start_highest, end_highest, jump_time)
	await get_tree().create_timer(action.getDelay()).timeout
	
	AniPlayer.speed_scale = 1
	
const FALL_MULTIPLIER: float = 2.3
const FALL_SPEEDSCALE: float = 3.5
func onFall(action: MoveToTileAction) -> void:
	var height_diff: int = abs(action.DestinationTile.getHeight() - Tile.getHeight())
	var jump_end: Vector3 = action.DestinationTile.getCardPosition()
	var jump_height: float = 3 + (height_diff * FALL_MULTIPLIER)
	var start_highest: Vector3 = position + Vector3(0, -jump_height, 0)
	var end_highest: Vector3 = jump_end + Vector3(0, -jump_height, 0)
	
	AniPlayer.speed_scale = FALL_SPEEDSCALE - ((action.fall_time - 1) * 2.2)
	onTweenJumpFall(jump_end, start_highest, end_highest, action.fall_time)
	await get_tree().create_timer(action.getDelay()).timeout
	
	AniPlayer.speed_scale = 1
	
func onTweenJumpFall(jump_end: Vector3, start_highest: Vector3, end_highest: Vector3, jump_time: float) -> void:
	var tween := get_tree().create_tween()
	var jump_start: Vector3 = Tile.getCardPosition()
	tween.tween_method(onJumpFall.bind(jump_start, jump_end, start_highest, end_highest), 0.0, 1.0, jump_time)
	onJump()
	
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
	onCreateIdleRareTimer()
	onUpdateLevelVisible()
#endregion

#region Vision
var VisionRay: RayCast3D
const BASE_VISION_RANGE: int = 5
const EXTRA_RAY_LENGTH: float = 1.05

func getRevealVisibleGroup() -> Array:
	return [self]

func onAddVisibleGameObject(GameObject: GameObjectGD) -> void:
	vision_datastore.onAddVisibleGameObject(GameObject)

func onRemoveVisibleGameObject(GameObject: GameObjectGD) -> void:
	vision_datastore.onRemoveVisibleGameObject(GameObject)

func onAddUnitVisibleParticle() -> void:
	var UnitVisibleParticle: GPUParticles3D = load(info.UNIT_VISIBLE_PARTICLE_SCENE_PATH).instantiate()
	add_child(UnitVisibleParticle)
	UnitVisibleParticle.emitting = true

func getVisionRange() -> int:
	return BASE_VISION_RANGE if !isBlind() else 1

func onUpdateVision() -> void: # Returns the new visibles
	if card_place != Game.CardPlaces.FIELD: return
	
	var cards: Array = get_tree().get_nodes_in_group("FieldCardsGD")
	cards.erase(self)
	var tile_to_card: Dictionary = {}

	var vision_range_game_objects: Array = Game.getAdjacentOrCloserTiles(Tile, getVisionRange())
	var visibles: Dictionary = vision_datastore.getVisibles()
	var previous_direct_game_objects: Array = []
	for GameObject in visibles:
		if visibles[GameObject].direct:
			previous_direct_game_objects.append(GameObject)

	for Card in cards.duplicate():
		var tile_in_vision_range: bool = Card.Tile in vision_range_game_objects
		Card.setDetectableByRay(tile_in_vision_range and Card.isNotInvisibleOrIsAdjacent(Tile))
		if !tile_in_vision_range:
			cards.erase(Card)
			
	for FieldCard in cards:
		tile_to_card[FieldCard.Tile] = FieldCard
	
	for obj_array in vision_range_game_objects.map(func(x: GameObjectGD): return x.occupied_objects):
		for Obj in obj_array: vision_range_game_objects.append(Obj)
		
	var adjacent_tiles_and_center: Array = Game.getAdjacentTiles(Tile, 1) + [Tile]
	for Tile in adjacent_tiles_and_center:
		vision_range_game_objects.erase(Tile)
		
	vision_range_game_objects += cards
	
	var direct_game_objects_dict: Dictionary = {}
	var point_batches: Dictionary = {}
	for GameObject in vision_range_game_objects:
		point_batches[GameObject] = GameObject.getAdjustedPoints()
	
	for GameObject in point_batches:
		for point in point_batches[GameObject]:
			VisionRay.target_position = (point - VisionRay.global_position) * EXTRA_RAY_LENGTH
			VisionRay.force_raycast_update()
			if VisionRay.is_colliding():
				var DirectGameObject: GameObjectGD = Helper.getCollision(VisionRay.get_collider(), GameObjectGD)
				if DirectGameObject in vision_range_game_objects: # Has to be in range
					direct_game_objects_dict[DirectGameObject] = null
					if GameObject == DirectGameObject: break
	
	for Tile in adjacent_tiles_and_center:
		direct_game_objects_dict[Tile] = null
	
	var direct_game_objects: Array = direct_game_objects_dict.keys()
	for GameObject in previous_direct_game_objects.filter(func(x: GameObjectGD): return x not in direct_game_objects): # No longer direct
		vision_datastore.setDirect(GameObject, false)
		
		if GameObject is CardGD:
			visibles[GameObject.Tile].setByUnit(false)
			if GameObject.isNotInvisibleOrIsAdjacent(Tile):
				visibles[GameObject].setByTile(false)
			
		elif GameObject is TileGD:
			for Obj in GameObject.occupied_objects:
				visibles[Obj].onRemoveTile(GameObject)
			
			if tile_to_card.has(GameObject):
				visibles[tile_to_card[GameObject]].setByTile(false)
				
		elif GameObject is ObjectGD:
			for Tile in GameObject.occupied_tiles:
				visibles[Tile].onRemoveObject(GameObject)
		
	for GameObject in direct_game_objects:
		if GameObject is CardGD and GameObject in cards:
			vision_datastore.setDirect(GameObject, true)
			visibles[GameObject.Tile].setByUnit(true)
			
		elif GameObject is TileGD:
			vision_datastore.setDirect(GameObject, true)
			for Obj in GameObject.occupied_objects:
				visibles[Obj].onAddTile(GameObject)
			
			if tile_to_card.has(GameObject):
				visibles[tile_to_card[GameObject]].setByTile(true)
				
		elif GameObject is ObjectGD:
			vision_datastore.setDirect(GameObject, true)
			for Tile in GameObject.occupied_tiles:
				visibles[Tile].onAddObject(GameObject)
	
func onTileOccupiedIsInVision(Tile: TileGD, PreviousTile: TileGD, Card: CardGD) -> void:
	var visibles: Dictionary = vision_datastore.getVisibles()
	
	if PreviousTile != null: visibles[PreviousTile].setByUnit(false)
	
	var new_tile_in_vision: bool = Tile != null and Tile in getVisibleGameObjects()
	
	if Tile != null: visibles[Tile].setByUnit(new_tile_in_vision)
	if Card != null: visibles[Card].setByTile(new_tile_in_vision)
	
func inEnemyVision() -> bool:
	return Game.getEnemyUnits(team).any(func(x: CardGD): return self in x.getVisibleFieldCardsEnemies())
	
func getVisibleFieldCardsEnemies() -> Array:
	return getVisibleFieldCards().filter(func(x: CardGD): return isEnemy(x.team))
	
func getVisibleFieldCardsAllies() -> Array:
	return getVisibleFieldCards().filter(func(x: CardGD): return isAlly(x.team) and x != self)
	
func getVisibleFieldCards() -> Array:
	return getVisibleGameObjects().filter(func(x: GameObjectGD): return x is CardGD)
	
func getVisibleTiles() -> Array:
	return getVisibleGameObjects().filter(func(x: GameObjectGD): return x is TileGD)
	
func getVisibleGameObjects() -> Array:
	return vision_datastore.getVisibleGameObjects()
	
func onCreateVisionRay() -> void:
	VisionRay = load(info.VISION_RAY_SCENE_PATH).instantiate()
	add_child(VisionRay)
	VisionRay.position.y = info.eye
	
func onUpdateLevelVisible() -> void:
	visible = isLevelVisible() if !is_card_change_level_visible else true
	
func isLevelVisible() -> bool:
	return isAlly(0) or super()
	
func setLevelVisible(state: bool) -> void:
	if state != vision_datastore.level_visible:
		is_card_change_level_visible = true
		super(state)
		setAlphagreyMaterial(1.0 if state else 0.0)
	else: super(state)
		
	if Tile != null:
		var occupy_state := Tile.OccupyStates.NULL
		if state:
			match team:
				0: occupy_state = Tile.OccupyStates.ALLY
				1: occupy_state = Tile.OccupyStates.ENEMY
				2: occupy_state = Tile.OccupyStates.NEUTRAL
		Tile.onOccupyingCardLevelVisibleChanged(occupy_state)
	
func setDetectableByRay(state: bool) -> void:
	if state: setCollisionLayers(96)
	else: setCollisionLayers(32)
	
func setCardVisionMode(state: bool) -> void:
	card_vision_mode = null if !state else CardVisionMode.new()
	setBaseMaterials()
	
func setCardVisionModeState(state: bool) -> void:
	card_vision_mode.state = state
	setBaseMaterials()
#endregion

#region Fall Damage
var temp_fall_damage: int = 0
func isCardSurviveFallDamage(_temp_fall_damage: int) -> bool:
	temp_fall_damage += _temp_fall_damage
	return temp_fall_damage < health
#endregion

#region Attacks and Range
func isInCombat() -> bool:
	return !getVisibleFieldCardsEnemies().is_empty()

func setEnemyInMovementRange(state: bool) -> void:
	if !isAlly(0): FieldInfo.setInfoSpriteEnemyInMovementRange(state)

func isAttackable(Card: CardGD) -> bool:
	return !Card.isAlly(team)
	
func getAttackDamage() -> int:
	return attack
	
func getAttackRange() -> int:
	return attack_range
	
func setAttackRange(_attack_range: int) -> void:
	attack_range = _attack_range
	
func canAttack() -> bool: return attacks > 0
	
func getMaxAttacks() -> int: return 1
	
func setAttacks(_attacks: int) -> void: attacks = _attacks
	
func getAttackablesInRange(StartingTile: TileGD = Tile) -> Dictionary:
	if !canAttack(): return {}
	var iobjects: Array = get_tree().get_nodes_in_group("LevelIObjectsGD")
	var cards: Array = get_tree().get_nodes_in_group("FieldCardsGD")
	cards.erase(self)
	
	var attackables: Dictionary = {}
	for GameObject in cards + iobjects:
		var EnemyTile: TileGD = GameObject.Tile if GameObject is CardGD else GameObject.getAttackableTile()
		if isGameObjectAttackable(GameObject, EnemyTile, StartingTile):
			attackables[GameObject] = EnemyTile
	
	return attackables
	
func getAttackableTile() -> TileGD: # Simplifying function for iobjects
	return Tile
	
func isGameObjectAttackable(GameObject: GameObjectGD, AttackableTile: TileGD, StartingTile: TileGD = Tile) -> bool:
	if !GameObject.isAttackable(self): return false
	if getAttackDistanceFromEnemy(AttackableTile, StartingTile) != 0: return false
	
	if !(GameObject in getVisibleGameObjects()): return false
	var is_in_height: bool = abs(AttackableTile.getHeight() - StartingTile.getHeight()) in [0, 1]
	
	var top_y: float = GameObject.info.top if GameObject is CardGD else GameObject.getTopVertexY()
	var is_in_unit_height: bool = position.y <= (GameObject.position.y + top_y) and top_y <= (position.y + info.top)
	
	var is_ranged: bool = getAttackRange() > 1 and (abs(AttackableTile.getHeight() - StartingTile.getHeight()) <= 5)
	return (is_in_height or is_in_unit_height or is_ranged)
		
func getAttackDistanceFromEnemy(EnemyTile: TileGD, StartingTile: TileGD = Tile, _speed: int = speed) -> int:
	return max(Game.getCoordsDistance(StartingTile.getCoords(), EnemyTile.getCoords()) - getAttackRange() - _speed, 0)
#endregion

#region Damage
func onTakeDamage(Damager: GameObjectGD, damage: int, lock_action_delay: bool) -> int: # Returns damage dealt
	var old_health: int = health
	health = max(health - damage, 0)
	
	var health_damage: int = old_health - health
	
	var action: Action
	if health == 0: action = DeathAction.new(Damager, self, damage, health_damage)
	else: action = HurtAction.new(Damager, self, damage, health_damage)
	
	action.setLockActionDelay(lock_action_delay)
	onPushAction(action)
	return health_damage
#endregion

#region Speed
func onUpdateStat(type: Game.Stats, difference: int, show_particles: bool) -> void:
	var value: int = 0
	match type:
		Game.Stats.ATTACK: value = attack
		Game.Stats.HEALTH: value = health
		Game.Stats.SPEED: value = speed
		Game.Stats.MAX_HEALTH: value = max_health
		Game.Stats.MAX_SPEED: value = max_speed
	
	FieldInfo.onUpdateStat(type, value, difference, isLevelVisible(), show_particles)
#endregion

#region Traits
func onCreateInitialTraits() -> void:
	var actions: Array = overworld_traits.map(func(x: OverworldTrait): return AddTraitAction.new(self, x))
	onPushAction(actions)
	
func onAscendedUpdateOverworldTraits() -> void:
	var new_traits: Array = info.ascended_traits if ascended else info.initial_traits
	var old_traits: Array = info.ascended_traits if !ascended else info.initial_traits
	
	var new_traits_ids: Array = new_traits.map(func(x: SavedDataTrait): return x.id)
	var old_traits_ids: Array = old_traits.map(func(x: SavedDataTrait): return x.id)
	
	new_traits = new_traits.filter(func(x: SavedDataTrait): return x.id not in old_traits_ids)
	old_traits = old_traits.filter(func(x: SavedDataTrait): return x.id not in new_traits_ids)
	
	var old_added_by := OverworldTrait.AddedBy.REGULAR if ascended else OverworldTrait.AddedBy.ASCENDED
	var added_by := OverworldTrait.AddedBy.ASCENDED if ascended else OverworldTrait.AddedBy.REGULAR
	var actions: Array = old_traits.map(func(x: SavedDataTrait): return RemoveOverworldTraitAction.new(self, x.id, old_added_by))
	actions += new_traits.map(func(x: SavedDataTrait): return AddOverworldTraitAction.new(self, OverworldTrait.new(x, added_by), true))
	
	onPushAction(actions)
	
func onAddOverworldTrait(overworld_trait: OverworldTrait) -> void:
	overworld_traits.append(overworld_trait)
	overworld_trait.clear.connect(func():\
		onPushAction(RemoveOverworldTraitAction.new(self, overworld_trait.Trait.id, overworld_trait.added_by)))
	
func onAddFieldTrait(overworld_trait: OverworldTrait) -> void:
	if overworld_trait.getData() == null: return
	var Trait: TraitGD = SavedData.onLoadModel(overworld_trait.getData(), self)
	
	Trait.Card = self
	overworld_trait.Trait = Trait
	
	if FieldInfo == null: return
	FieldInfo.onAddIcon(Trait)
	FieldInfo.onUpdateTraits()
	
func onRemoveOverworldTrait(overworld_trait: OverworldTrait) -> void:
	overworld_traits.erase(overworld_trait)
	
func onRemoveFieldTrait(overworld_trait: OverworldTrait) -> void:
	var Trait: TraitGD = overworld_trait.Trait
	overworld_trait.onRemoveFieldTrait()
	
	if FieldInfo == null: return
	FieldInfo.onRemoveIcon(Trait)
	FieldInfo.onUpdateTraits()
	
func onCreateArmorTrait(armor: int) -> TraitGD:
	return SavedData.onLoadModel(SavedDataArmor.new(1, true, 0, armor), self)
	
func isMobile() -> bool:
	return getOverworldTraitByID(3) != null
	
func getOverworldTraitByID(id: int) -> OverworldTrait:
	for overworld_trait in overworld_traits:
		if overworld_trait.getData().id == id:
			return overworld_trait
	return null
	
func getFieldTraitByID(id: int) -> TraitGD:
	for overworld_trait in overworld_traits:
		if overworld_trait.getData().id == id and overworld_trait.isActive():
			return overworld_trait.Trait
	return null
	
func getFieldTraits() -> Array:
	return getActiveOverworldTraits().map(func(x: OverworldTrait): return x.Trait)
	
func getActiveOverworldTraits() -> Array:
	return overworld_traits.filter(func(x: OverworldTrait): return x.isActive())
#endregion

#region Tools
func onAddTool(_Tool: ToolGD) -> void:
	Tool = _Tool
	tool_added.emit(Tool) # Created for Card UI to listen to

func onRemoveTool() -> void:
	onAddTool(null)

func getTool() -> ToolGD:
	return Tool

#region Active Effects
func onAddActiveEffect(active_effect: ActiveEffectDatastore) -> void:
	active_effects.append(active_effect)
	active_effect.owner = self

func onCreateInitialActiveAbilities() -> void:
	onPushAction(info.active_abilities.map(func(x: ActiveAbilityDatastore): return AddActiveEffectAction.new(self, x.duplicate())))

func getActiveEffectByName(_name: String) -> ActiveEffectDatastore:
	for active_effect in active_effects:
		if active_effect.name == _name: return active_effect
	return null
	
func getActiveEffectTiles(_active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	return null
	
func onActiveEffect(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	pass
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	pass
	
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return false
	
func setActiveEffectUsed(active_effect: ActiveEffectDatastore, used: bool) -> void:
	active_effect.used = used
	
func getActiveEffectDescription(_active_effect: ActiveEffectDatastore, description: String) -> String:
	return description
	
func getActiveAbilities() -> Array:
	return active_effects.filter(func(x: ActiveEffectDatastore): return x is ActiveAbilityDatastore)
	
func getActiveEffects() -> Array:
	return active_effects
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, _active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	return null
	
func onAIAbilityCheckerDefault(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	if active_effect.getDefaultDisabled(self): return null
	
	var active_effect_tiles: ActiveEffectTiles = getActiveEffectTiles(active_effect)
	if active_effect_tiles == null or active_effect_tiles.pickable_tiles.is_empty(): return null
	return active_effect_tiles
	
func getPickableTiles(active_effect: ActiveEffectDatastore) -> Array:
	return active_effect.pickable_tiles if active_effect != null else []
#endregion

#region Status Effects
func onRemoveStatusEffect(status_effect: StatusEffectGD) -> void:
	status_effects.erase(status_effect)
	FieldInfo.onRemoveIcon(status_effect)
	
func onAddStatusEffect(status_effect: StatusEffectGD) -> void:
	status_effects.append(status_effect)
	status_effect.Card = self
	FieldInfo.onAddIcon(status_effect)
	
func onCreateBaseStatusEffect(id: int, turns: int = 1) -> void:
	var status_data := SavedDataStatusEffect.new(id, true, 0, turns)
	var status_effect: StatusEffectGD = SavedData.onLoadModel(status_data, self)
	status_effect.Card = self
	onPushAction(AddStatusEffectAction.new(status_effect))
	
func getBaseStatusEffectAction(id: int, turns: int = 1) -> AddStatusEffectAction:
	var status_data := SavedDataStatusEffect.new(id, true, 0, turns)
	var status_effect: StatusEffectGD = SavedData.onLoadModel(status_data, self)
	status_effect.Card = self
	return AddStatusEffectAction.new(status_effect)
	
func onStun(turns: int = 1) -> void:
	onCreateBaseStatusEffect(4, turns)
	onCreateBaseStatusEffect(5, turns)
	
func isInvisible() -> bool:
	return status_effects.any(func(x: StatusEffectGD): return x.info.id == 2)
	
func isNotInvisibleOrIsAdjacent(_Tile: TileGD) -> bool:
	return !isInvisible() or Game.isAdjacent(_Tile, Tile)
	
func isBlind() -> bool:
	return status_effects.any(func(x: StatusEffectGD): return x.info.id == 1)
#endregion

#region Advance Turn
func onAdvanceTurn(turn_team: int) -> void:
	super(turn_team)
	if team != turn_team or !is_in_group("FieldCardsGD"): return
	
	var actions: Array = [StatAction.new(
		StatInfo.new(self, Game.Stats.SPEED, max_speed - int(Tile.isDeepwater()), 0, true, false, true)),
		ChangeTurnStateAction.new(self, Game.TurnStates.INACTIVE)]
		
	actions += active_effects.map(func(x: ActiveEffectDatastore): return ChangeActiveEffectUsedAction.new(x, false))
	onPushAction(actions)
		
	FieldInfo.onUpdateDelayedStats()
	
#endregion

#region Delayed Stats
func onAddDelayedStatInfo(stat_info: StatInfo) -> void:
	delayed_stats.append(stat_info)
	FieldInfo.onUpdateDelayedStats()
	
func onRemoveDelayedStatInfo(stat_info: StatInfo) -> void:
	delayed_stats.erase(stat_info)
	FieldInfo.onUpdateDelayedStats()
#endregion

#region Action Checker
func isValidTrauma(action: Action) -> bool:
	return action.post and action is DeathAction and isAlly(action.Defender.team) and card_place == Game.CardPlaces.FIELD and action.getCardSawDefenderDie(self)

func isValidLastWill(action: Action) -> bool:
	return action.post and action is DeathAction and action.Defender == self and card_place == Game.CardPlaces.GRAVEYARD

func isValidRampage(action: Action) -> bool:
	return action.post and action is DeathAction and action.Damager == self and card_place == Game.CardPlaces.FIELD

func isValidOnHit(action: Action) -> bool:
	return action.post and action is DamageAction and action.owner is AttackAction and action.Damager == self and card_place == Game.CardPlaces.FIELD\
		and action.Defenders.any(func(x: GameObjectGD): return x is CardGD)

func isValidRevenge(action: Action) -> bool:
	return action.post and action is StatAction and action.owner is DamageAction and action.owner.damage > 0 and\
	action.owner.damage_type != Game.DamageTypes.FALL_DAMAGE and self in action.owner.Defenders and card_place == Game.CardPlaces.FIELD

func isValidBloodthirst(action: Action) -> bool:
	return action.post and action is DeathAction and action.Damager != self and isEnemy(action.Defender.team) and card_place == Game.CardPlaces.FIELD and action.getCardSawDefenderDie(self) 

func isValidArrive(action: Action) -> bool:
	return action.post and action is AwakenAction and action.Card == self

func isValidWhenHealed(action: Action) -> bool:
	return !action.post and action is StatAction and action.isHeal(self) and card_place == Game.CardPlaces.FIELD
#endregion

#region Heal
func isHealable() -> bool:
	return health < max_health
	
func isInjured() -> bool:
	return health < max_health
#endregion

#region Field Effect
func onAddFieldEffect(FieldEffect: FieldEffectGD, FofObject: FofGD = null) -> void:
	if FofObject != null: FieldEffect.FofObject = FofObject
	field_effects.append(FieldEffect)
	FieldInfo.onAddIcon(FieldEffect)
	FieldEffect.Card = self
	
func onAddBaseFieldEffect(id: int, FofObject: FofGD = null) -> FieldEffectGD:
	var FieldEffect: FieldEffectGD = SavedData.onLoadModel(SavedDataFieldEffect.new(id, true), self)
	onAddFieldEffect(FieldEffect, FofObject)
	return FieldEffect
	
func onRemoveFieldEffect(FieldEffect: FieldEffectGD) -> void:
	field_effects.erase(FieldEffect)
	FieldInfo.onRemoveIcon(FieldEffect)
	FieldEffect.onClear()
	
func onRemoveFieldEffectsByOwner(FofObject: FofGD) -> void:
	for FieldEffect in onFindFieldEffectsByOwner(FofObject):
		onRemoveFieldEffect(FieldEffect)
	
func onFindFieldEffectsByOwner(FofObject: FofGD) -> Array:
	return field_effects.filter(func(x: FieldEffectGD): return x.FofObject == FofObject)
#endregion

#region Revenge
func onRevenge(_action: DamageAction) -> void:
	if AniPlayer.has_animation("HurtAbility"):
		onPlayAnimation("HurtAbility")
#endregion

#region Ascended
func onAscend(state: bool) -> void:
	if ascended == state or info.rarity in\
		[Game.Rarities.NEUTRAL, Game.Rarities.CHAMPION, Game.Rarities.MINI]: return
		
	ascended = state
	
	var mult: int = 1 if ascended else -1
	var plus_attack: int = info.plus_attack * mult
	var plus_health: int = info.plus_health * mult
	var plus_speed: int = info.plus_speed * mult
	var plus_energy: int = info.plus_energy * mult
	
	base_stats.attack += plus_attack
	base_stats.health += plus_health
	base_stats.speed += plus_speed
	base_stats.energy += plus_energy
	
	if Game.ActionManagerReference != null:
		onPushAction(CardEnergyAction.new(self, info.plus_energy * mult))
	else:
		attack += plus_attack
		health += plus_health
		speed += plus_speed
		energy += plus_speed
		
	update_ascended.emit(state)
	
	onAscendedUpdateOverworldTraits()
	setBaseMaterials()
	
func onAscendedUpdated(state: bool) -> void:
	var actions: Array = []
	for active_ability in active_effects.filter(func(x: ActiveEffectDatastore): return x.owner == self and x is ActiveAbilityDatastore\
		and ((x.description != x.ascended_description and !x.ascended_description.is_empty()) or x.max_charges != x.ascended_max_charges)):
		var max_charges: int = active_ability.ascended_max_charges if state else active_ability.max_charges
		
		actions.append(ChangeActiveEffectUsedAction.new(active_ability, false))
		actions.append(ChangeActiveEffectChargesAction.new(active_ability, max_charges - active_ability.charges, max_charges == -1))
	onPushAction(actions)
	
#endregion

#region Temp Card
func onAddTemporaryCardCondition(map_effect_data: SavedDataMapEffect) -> void:
	temporary_card_conditions.append(SavedData.onLoadModel(map_effect_data, self))
	temporary_card_conditions_updated.emit()
	
func isTemporary() -> bool:
	return !temporary_card_conditions.is_empty()
#endregion

#region Info Getters
func getIcon() -> Texture2D: return info.art_mini
#endregion

#region Elites
func isValidEliteLevelSpawns(enemy_spawns: Array) -> bool:
	return true
#endregion

#region Level Ended
func onLevelEnded(_win: bool) -> void:
	setStats(base_stats)
			
	if !(isAlly(0) and !is_awakened_in_combat): return
	if card_place != Game.CardPlaces.DECK: onChangeCardPlace(Game.CardPlaces.DECK)
	
	attacks = 1
	attack_range = 1
	tile_rotation = 0
	delayed_stats = []
	
	active_effects = []
	status_effects = []
	field_effects = []
	turn_state = Game.TurnStates.NULL
	vision_datastore = VisionDatastoreCard.new()
	
	ai_datastore.onReset()
	Tile = null
	
	for overworld_trait in overworld_traits:
		overworld_trait.onLevelEnded(_win)
	
#endregion

#region Idle Rare
var IdleRareTimer: Timer
func onCreateIdleRareTimer() -> void:
	if !is_in_group("FieldCardsGD"): return
	IdleRareTimer = Timer.new()
	add_child(IdleRareTimer)
	IdleRareTimer.timeout.connect(onIdleRareTimerTimeout)
	
	IdleRareTimer.wait_time = randi_range(IDLE_RARE_MIN_TIME, IDLE_RARE_MAX_TIME)
	IdleRareTimer.start()
	
func onIdleRareTimerTimeout() -> void:
	if !is_in_group("FieldCardsGD"): return
	if AniPlayer.current_animation.begins_with("Idle"):
		onIdleRare()
		
	IdleRareTimer.start()
	IdleRareTimer.wait_time = randi_range(IDLE_RARE_MIN_TIME, IDLE_RARE_MAX_TIME)
#endregion

#region Death
func onPreDeath() -> void:
	setCollisionLayers(0)
	
func isAlive() -> bool:
	return is_in_group("FieldCardsGD")
	
func isDead() -> bool:
	return is_in_group("GraveyardCardsGD")
#endregion

#region Kills
func onBountyKill(action: Action) -> void:
	var duelist_kill: bool = isValidDuelistRampage(action)
	var Defender: Variant = action.Defender
	if Defender is CardGD and Defender.isEnemy(team) and \
		!(Defender.is_awakened_in_combat or Defender.info.rarity in [Game.Rarities.SCRAP, Game.Rarities.NEUTRAL]):
		bounty_kills.onIncrementBountyKills(duelist_kill)
	
func getLastClaimedKills() -> int:
	return bounty_kills.last_claimed_kills
	
func isValidDuelistRampage(action: Action) -> bool:
	if !isValidRampage(action): return false
	
	var cards: Array = getVisibleFieldCards()
	cards.erase(self)
	cards.erase(action.Defender)
	
	var enemy_cards: Array = action.Defender.getVisibleFieldCards()
	enemy_cards.erase(self)
	enemy_cards.erase(action.Defender)
	
	return cards.is_empty() and enemy_cards.is_empty()
#endregion

#region AI
func onUnitSpecificTransforms(_tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	pass
	
func getArchetype() -> Game.Archetypes:
	match info.archetype.id:
		1: return Game.Archetypes.SCOUT
		2: return Game.Archetypes.ADVENTURER
		3: return Game.Archetypes.BRUTE
		4: return Game.Archetypes.WARDEN
		5: return Game.Archetypes.TACTICIAN
		6: return Game.Archetypes.REINFORCER
		7: return Game.Archetypes.SUPPORT
		8: return Game.Archetypes.DOCILE
		9: return Game.Archetypes.HOSTILE
		10: return Game.Archetypes.ERRATIC
	return Game.Archetypes.NULL
	
# True if active effect used
func onAICheckActiveEffects(DFL: DefaultFightLogic, allies: Array, enemies: Array, after_action: MovementFinishAction = null) -> bool:
	var tool_active_effects: Array = Tool.getActiveEffects() if Tool != null else []
	var active_effects: Array = getActiveEffects() + tool_active_effects
	
	for IObject in Game.get_tree().get_nodes_in_group("LevelIObjectsGD")\
		.filter(func(x: ObjectGD): return !x.is_queued_for_deletion()):
		active_effects += IObject.getValidActiveEffects(self)
		
	for active_effect in active_effects:
		var active_effect_tiles: ActiveEffectTiles = active_effect.owner.onAIAbilityCheckerDefault(active_effect)\
			if active_effect.owner is not IObjectGD else active_effect.owner.onAIAbilityCheckerDefault(active_effect, self)
		if active_effect_tiles == null: continue
		
		var Tile: TileGD = active_effect.owner.onAIAbilityChecker(active_effect, active_effect_tiles, DFL)
		if Tile == null: continue
		
		var actions: Array = [ChangeTurnStateAction.new(self, Game.TurnStates.ACTIVE),\
			ActiveEffectUsedAction.new(active_effect, Tile, active_effect_tiles, self),\
			MovementFinishAction.new(self, [], allies, enemies)]
			
		if after_action == null: onPushAction(actions)
		else: onPushAfterAction(actions, after_action)
		return true
	return false
	
func onAICheckActiveEffectsOnlyDFL(DFL: DefaultFightLogic, after_action: MovementFinishAction = null) -> bool:
	return onAICheckActiveEffects(DFL, DFL.allies, DFL.enemies, after_action)
#endregion

#region Materials
func setBaseMaterials() -> void:
	if Model == null: return
	var mat: Material
	if card_vision_mode != null and !card_vision_mode.state: mat = info.getColoredBaseMaterial(team)
	elif ascended: mat = load(info.BASE_MATERIAL_ASCENDED_PATH)
	setMeshesMaterial(mat, Model)

var is_in_alphagrey: bool
var AlphagreyTween: Tween
func setAlphagreyMaterial(start_value: float) -> void:
	if AlphagreyTween != null: AlphagreyTween.stop()
	AlphagreyTween = get_tree().create_tween()
	
	is_in_alphagrey = true
	setMeshesMaterial(load(info.BASE_MATERIAL_ALPHAGREY_PATH), Model)
	setAlphagreyMaterialValue(start_value)
	AlphagreyTween.tween_method(setAlphagreyMaterialValue, start_value, abs(start_value - 1), ALPHAGREY_CHANGE_SPEED)
	await AlphagreyTween.finished
	
	is_in_alphagrey = false
	is_card_change_level_visible = false
	
	setBaseMaterials()
	onUpdateLevelVisible()
	
func setAlphagreyMaterialValue(value: float) -> void:
	if !is_in_alphagrey or !is_in_group("FieldCardsGD"): return
	for mesh in getMeshes(Model):
		mesh.set_instance_shader_parameter("time_value", value)
#endregion

func getAdjustedPoints() -> Array:
	return getLevelPoints().map(func(x: Vector3): return (Game.onRotatePosition(x, rotation.y)) + position)
	
