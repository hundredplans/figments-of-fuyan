class_name CardGD extends GameObjectGD

#region Saved Data
const FATIGUE_ID: int = 3
var base_stats: StatsDatastore # Can be updated, are set when unit is first loaded in

var attack: int
var health: int
var speed: int
var max_speed: int
var max_health: int
var energy: int

var is_spectated: bool
var team: int

var card_place: Game.CardPlaces
var turn_state: Game.TurnStates

var draw_order: int
var Tile: TileGD

var attacks: int
var attack_range: int
var status_effects: Array = []

var delayed_stats: Array # Can be [StatInfo] or [HealAction]
var ability_save: Dictionary
var active_effects: Array[ActiveEffectDatastore]
var field_effects: Array[FieldEffectGD]

var anibility_datastore: AnibilityDatastore
var is_temporary: bool

var Tool: ToolGD
var is_awakened_in_combat: bool
var overworld_traits: Array[OverworldTrait] = []
var bounty_kills: BountyKills
var is_card_change_level_visible: bool # Not saved
var ai_datastore: AIDatastore
var level_visible_not_in_vision: bool # Not saved
var boss_datastore: BossDatastore # Null in here
var is_knockback: bool # Not saved
var card_offset: CardOffset # Offset of ronotation and position
var tier: int
var death_ids: Array[int] # id's of every unit this killed, used for blade
#endregion

#region Globals
const DEFAULT_ANIMATION_BLEND_TIME: float = 0.2
const IDLE_RARE_MIN_TIME: int = 12
const IDLE_RARE_MAX_TIME: int = 80
const ALPHAGREY_CHANGE_SPEED: float = 0.5
#endregion

#region Signals
signal inspect_screen_created
signal tool_updated
signal mouse_entered
signal mouse_exited
signal is_temporary_updated
@warning_ignore("unused_signal")
signal update_active_effect_description
signal awakened_in_combat
@warning_ignore("unused_signal")
signal update_stats
signal card_turn_passed
signal tier_updated
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
	if Model == null: return
	Model.rotation.y = (tile_rotation * (PI / 3)) + (PI / 6) + card_offset.getRotationOffset().y
	
func setModelRotationToTile(OtherTile: TileGD) -> void:
	var model_rotation: Vector3 = Model.rotation
	Model.look_at(OtherTile.global_position)
	Model.rotation = Vector3(model_rotation.x, Model.rotation.y + PI, model_rotation.z)
	
func setIdleModifier(idle_modifier: String) -> void:
	anibility_datastore.setIdleModifier(idle_modifier)
	if AniPlayer != null and AniPlayer.current_animation.begins_with("Idle"):
		onIdle()
		
func onResetIdleModifier() -> void:
	setIdleModifier("")
	
func setAnimationModifier(animation_name: String, modifier: String) -> void:
	match animation_name:
		"Idle": setIdleModifier(modifier)
		"Jump": anibility_datastore.setJumpModifier(modifier)
		"Hurt": anibility_datastore.setHurtModifier(modifier)
		"Attack": anibility_datastore.setAttackModifier(modifier)
		"Death": anibility_datastore.setDeathModifier(modifier)
		
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
func getDescription(use_default_values: bool = false) -> String:
	return info.getDescription(tier, use_default_values)
	
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
func setAniPlayer(AniModel: Node3D) -> void:
	for child in Helper.getChildrenRecursive(AniModel):
		if child is AnimationPlayer and !child.is_queued_for_deletion():
			AniPlayer = child
			AniPlayer.animation_finished.connect(onAnimationFinished)
			AniPlayer.playback_default_blend_time = DEFAULT_ANIMATION_BLEND_TIME
			return

var AniPlayer: AnimationPlayer

func onPlayAnimation(animation_name: String, play_backwards: bool = false) -> void:
	if AniPlayer != null:
		match animation_name:
			"Walk": if AniPlayer.current_animation == "Walk": return
		
		if !play_backwards: AniPlayer.play(animation_name)
		else: AniPlayer.play_backwards(animation_name)
		
		AniPlayer.set_current_animation(animation_name)
		
func onAnimationFinished(ani_name: String) -> void:
	if !ani_name.begins_with("Death") and !AniPlayer.is_playing():
		onIdle()
		
func onJump() -> void:
	AniPlayer.stop()
	onPlayAnimation("Jump" + anibility_datastore.getJumpModifier())
		
func onAttack(DefenderTile: TileGD, delay: float) -> void:
	onPlayAnimation("Attack" + anibility_datastore.getAttackModifier())
	
	if Game.getCoordsDistance(DefenderTile.getCoords(), Tile.getCoords()) > 1 and delay > 0: # If is level visible
		setModelRotationToTile(DefenderTile)
		
func onWalk() -> void:
	onPlayAnimation("Walk" + anibility_datastore.getWalkModifier())
	
func onIdle() -> void:
	onPlayAnimation("Idle" + anibility_datastore.getIdleModifier())
	
func onDeath() -> void:
	onPlayAnimation("Death" + anibility_datastore.getDeathModifier())
	
func onHurt() -> void:
	onPlayAnimation("Hurt" + anibility_datastore.getHurtModifier())
	
func onAbility() -> void:
	onPlayAnimation("Ability")
	
func onIdleRare() -> void:
	onPlayAnimation("IdleRare")
	
func isWalking() -> bool:
	return isAlive() and AniPlayer.current_animation.begins_with("Walk")
	
func onPauseAnimation(state: bool = true) -> void:
	if state: AniPlayer.pause()
	else: AniPlayer.play()
	
func onPauseAnimationWithDelay(delay: float) -> void:
	AniPlayer.pause()
	await get_tree().create_timer(delay).timeout
	AniPlayer.play()
#endregion

#region Card
func onCreateCardUI(parent: Control, highlight_on_hover: bool = false, ui_inspectable: bool = true, DraggableParent: Control = null) -> Control:
	var CardUI: Control = load(info.CARD_UI_SCENE_PATH).instantiate()
	parent.add_child(CardUI)
	CardUI.setInfo(self, highlight_on_hover, ui_inspectable, DraggableParent)
	return CardUI
#endregion

#region Save/Load/Clear
func getDuplicateData() -> SavedDataCard:
	var data := onSave()
	var dupe_data: SavedDataCard = data.duplicate()
	var dupe_tool_data: SavedDataTool = Tool.getDuplicateData() if Tool != null else null
	dupe_data.tool_data = dupe_tool_data
	dupe_data.public_id = 0
	return dupe_data


func onSave() -> SavedDataCard:
	onPreSave()
	return SavedDataCard.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, team, \
	attack, health, speed, max_speed, max_health, energy, draw_order, card_place, turn_state, SavedData.onSaveGroup(status_effects), attacks, attack_range, delayed_stats,\
	ability_save, active_effects, Tool.onSave() if Tool != null else null, SavedData.onSaveGroup(field_effects), anibility_datastore,\
	is_temporary, is_awakened_in_combat, ai_datastore, base_stats,
	overworld_traits, bounty_kills, boss_datastore, card_offset, tier, death_ids)

func onPreSave() -> void:
	for delayed: Variant in delayed_stats: delayed.onSave()
	for overworld_trait in overworld_traits: overworld_trait.onSave()

	vision_datastore.onSave()
	ai_datastore.onSave()
	
	if boss_datastore != null: boss_datastore.onSave()

func onLoadData(data: SavedData) -> void:
	super(data)
	coords = data.coords
	team = data.team
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
	is_temporary = data.is_temporary
	draw_order = data.draw_order
	card_offset = data.card_offset
	tier = data.tier
	death_ids = data.death_ids
	
	if data.tool_data != null:
		Tool = SavedData.onLoadModel(data.tool_data, self)
		Tool.Card = self
		onAddTool(Tool)
	
	for active_effect in active_effects:
		active_effect.owner = self
	
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
	boss_datastore = data.boss_datastore
	if boss_datastore != null: boss_datastore.onLoad()
	
	onChangeCardPlace(data.card_place)
	add_to_group("CardsGD")
	
func onLoadDataLevel() -> void:
	super()
	if card_place == Game.CardPlaces.FIELD:
		Tile = Game.getTile(coords)
		
		for delayed: Variant in delayed_stats: delayed.onLoad()
		
		onAwaken()
		onLoadTraits()
		onLoadStatusEffects()
		onLoadFieldEffects()
		vision_datastore.onLoad()
		ai_datastore.onLoad()
	
func onLoadDataLevelFofInit() -> void:
	super()
	onReset()
	
func onFofInit() -> void:
	super()
	base_stats = StatsDatastore.new(attack, max_health, max_speed, energy)
	onRegularReset()
	
	if self is not EpicCardGD:
		var tier_datastore: CardTierDatastore = info.getTierDatastore(tier)
		var initial_traits: Array[SavedDataTrait] = tier_datastore.getTraits()

		for trait_data: SavedDataTrait in initial_traits:
			var added_by := OverworldTrait.AddedBy.REGULAR
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
	
	Model = getModelFromInfo().instantiate()
	add_child(Model)
	
	var body := StaticBody3D.new()
	Model.add_child(body)
	
	var collision_shape_packed: PackedScene = getCollisionShapeFromInfo()
	if collision_shape_packed != null:
		body.add_child(collision_shape_packed.instantiate())
	body.collision_mask = 0
	body.mouse_entered.connect(func(): mouse_entered.emit(self))
	body.mouse_exited.connect(func(): mouse_exited.emit(self))
		
	setDefaultCollisionLayers()
	setAniPlayer(Model)
	setBaseMaterials()
	setTileRotation(tile_rotation)
	
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
	return info.getPoints()

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
func setPositionToTile(_Tile: TileGD = Tile) -> void:
	position = _Tile.getCardPosition() + card_offset.getPositionOffset()
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
func setTurnState(_turn_state: Game.TurnStates, instant: bool = false) -> void:
	turn_state = _turn_state
	if FieldInfo != null: FieldInfo.onUpdateTurnState(instant)
		
func onCardTurnPassed(Card: CardGD) -> void:
	if self != Card: return
	
	for delayed: Variant in delayed_stats.duplicate():
		delayed.onCardTurnPassed()
		
	if Tool != null: Tool.onCardTurnPassed()
	
	for overworld_trait: OverworldTrait in overworld_traits:
		overworld_trait.onCardTurnPassed()
	
	ai_datastore.onCardTurnPassed()
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.SPEED, Card.max_speed, 0, false, false, true)))
	card_turn_passed.emit()
	
#endregion

#region Actions
func onProcessAction(action: Action) -> void:
	super(action)
	if Game.CardPlaces.FIELD == card_place:
		if action.post:
			if action is MovementFinishAction and action.Card == self: Tile.setOutlineMaterial()
			elif action is AttackAction and action.Attacker.isEnemy(team) and action.Attacker in getVisibleFieldCardsEnemies():
				ai_datastore.setLastSeenViolence(0)
			elif isValidRampage(action):
				onBountyKill(action) # Needs to be here instead of in death action
				death_ids.append(action.Defender.info.id)
			elif action is AddToolAction and action.Tool == Tool:
				tool_updated.emit(action.Tool)
			elif action is ToolRetieredAction and action.Tool == Tool:
				tool_updated.emit(action.Tool)
			elif action is RemoveToolAction and action.Card == self:
				tool_updated.emit(null)
			
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
var MovementTween: Tween
func onMoveToTile(action: MoveToTileAction, delay: float) -> void:
	if isLevelVisible():
		if MovementTween != null: MovementTween.kill()
		MovementTween = create_tween()
		if !action.isJumpFall(): # Regular = Ramp movement
			onWalk()
			
			if action.movement_type == MoveToTileAction.MOVEMENT_TYPES.REGULAR:
				MovementTween.tween_property(self, "position", action.DestinationTile.getCardPosition(), delay)
			elif action.DestinationTile.isRamp():
				MovementTween.tween_property(self, "position", Tile.getHalfwayCardPosition(action.DestinationTile), delay / 2.0)
				MovementTween.tween_property(self, "position", action.DestinationTile.getCardPosition(), delay / 2.0)
			elif Tile.isRamp():
				MovementTween.tween_property(self, "position", action.DestinationTile.getHalfwayCardPosition(Tile), delay / 2.0)
				MovementTween.tween_property(self, "position", action.DestinationTile.getCardPosition(), delay / 2.0)
			return
		
		if action.movement_type == MoveToTileAction.MOVEMENT_TYPES.JUMP: onJumpTween(action, delay)
		elif action.movement_type == MoveToTileAction.MOVEMENT_TYPES.FALL: onFallTween(action, delay)
	#else: setPositionToTile(action.DestinationTile)
	
const JUMP_MULTIPLIER: float = 1.25
const JUMP_SPEEDSCALE: float = 2.5
func onJumpTween(action: MoveToTileAction, delay: float) -> void:
	var height_diff: int = abs(action.DestinationTile.getHeight() - action.OriginalTile.getHeight())
	var jump_time: float = 1
	var jump_start: Vector3 = action.OriginalTile.getCardPosition()
	var jump_end: Vector3 = action.DestinationTile.getCardPosition()
	var jump_height: float = -3.5 - (height_diff * JUMP_MULTIPLIER)
	var start_highest: Vector3 = jump_start + Vector3(0, jump_height, 0)
	var end_highest: Vector3 = jump_end + Vector3(0, jump_height, 0)
	
	AniPlayer.speed_scale = JUMP_SPEEDSCALE
	
	onTweenJumpFall(jump_start, jump_end, start_highest, end_highest, jump_time)
	await get_tree().create_timer(delay).timeout
	
	AniPlayer.speed_scale = 1
	
const FALL_MULTIPLIER: float = 2.3
const FALL_SPEEDSCALE: float = 3.5
func onFallTween(action: MoveToTileAction, delay: float) -> void:
	var height_diff: int = abs(action.DestinationTile.getHeight() - action.OriginalTile.getHeight())
	var jump_start: Vector3 = action.OriginalTile.getCardPosition()
	var jump_end: Vector3 = action.DestinationTile.getCardPosition()
	var jump_height: float = 3 + (height_diff * FALL_MULTIPLIER)
	var start_highest: Vector3 = jump_start + Vector3(0, -jump_height, 0)
	var end_highest: Vector3 = jump_end + Vector3(0, -jump_height, 0)
	
	AniPlayer.speed_scale = FALL_SPEEDSCALE - ((action.fall_time - 1) * FALL_MULTIPLIER)
	onTweenJumpFall(jump_start, jump_end, start_highest, end_highest, action.fall_time)
	await get_tree().create_timer(delay).timeout
	
	AniPlayer.speed_scale = 1
	
func onTweenJumpFall(jump_start: Vector3, jump_end: Vector3, start_highest: Vector3, end_highest: Vector3, jump_time: float) -> void:
	MovementTween.tween_method(onJumpFall.bind(jump_start, jump_end, start_highest, end_highest), 0.0, 1.0, jump_time)
	onJump()
	
func onJumpFall(time: float, jump_start: Vector3, jump_end: Vector3, start_highest: Vector3, end_highest: Vector3) -> void:
	position = jump_start.cubic_interpolate(jump_end, start_highest, end_highest, time)
#endregion

#region Spectated
func onSpectated(state: bool) -> void:
	is_spectated = state
	if FieldInfo != null: FieldInfo.onSpectated(state)
#endregion

#region Field Info
var FieldInfo: Node3D
func onCreateFieldInfo() -> void:
	FieldInfo = load(info.FIELD_INFO_SCENE_PATH).instantiate()
	add_child(FieldInfo)
	FieldInfo.setInfo(self)
	
func onRemoveFieldInfo() -> void:
	if FieldInfo != null:
		FieldInfo.queue_free()
	
func setFieldInfoVisible(state: bool) -> void:
	FieldInfo.visible = state
	
func onCameraPositionUpdated(pos: Vector3) -> void:
	if FieldInfo != null: FieldInfo.onCameraPositionUpdated(pos)
#endregion

#region Awaken
func onAwaken() -> void:
	onCreateModel()
	onIdle()
	onCreateFieldInfo()
	onCreateVisionRay()
	setPositionToTile()
	setTileRotation(tile_rotation)
	setTurnState(turn_state, true)
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
	var tile_to_card: Dictionary = {}

	var vision_range_game_objects: Array = Game.getAdjacentOrCloserTiles(Tile, getVisionRange()) + [Tile]
	var visibles: Dictionary = vision_datastore.getVisibles()
	var previous_direct_game_objects: Array = []
	for GameObject in visibles:
		if visibles[GameObject].direct:
			previous_direct_game_objects.append(GameObject)

	for Card: CardGD in cards.duplicate(): # Because it's erasing inside
		var tile_in_vision_range: bool = Card.Tile in vision_range_game_objects
		Card.setDetectableByRay(tile_in_vision_range and Card.isNotInvisibleOrIsAdjacent(Tile))
		if !tile_in_vision_range:
			cards.erase(Card)
			
	for FieldCard in cards:
		tile_to_card[FieldCard.Tile] = FieldCard
	
	for obj_array in vision_range_game_objects.map(func(x: GameObjectGD): return x.occupied_objects):
		for Obj in obj_array: vision_range_game_objects.append(Obj)
		
	var adjacent_tiles_and_center: Array = Game.getAdjacentTiles(Tile, 1) + [Tile]
	#for AdjacentTile: TileGD in adjacent_tiles_and_center:
		#vision_range_game_objects.erase(AdjacentTile)
		
	vision_range_game_objects += cards
	
	var direct_game_objects_dict: Dictionary = {}
	var point_batches: Dictionary = {}
	for GameObject in vision_range_game_objects:
		point_batches[GameObject] = GameObject.getAdjustedPoints()
	
	#var t: float = Time.get_ticks_msec()
	for GameObject: GameObjectGD in point_batches:
		for point: Vector3 in point_batches[GameObject]:
			VisionRay.target_position = (point - VisionRay.global_position) * EXTRA_RAY_LENGTH
			VisionRay.force_raycast_update()
			if VisionRay.is_colliding():
				var DirectGameObject: GameObjectGD = Helper.getCollision(VisionRay.get_collider(), GameObjectGD)
				
				direct_game_objects_dict[DirectGameObject] = null
				if GameObject == DirectGameObject: break
	#var post_t: float = Time.get_ticks_msec() - t
	#print("Points:" + str(post_t))
	#pass
	
	for AdjacentTile: TileGD in adjacent_tiles_and_center:
		direct_game_objects_dict[AdjacentTile] = null
		
	direct_game_objects_dict[Tile] = null
	direct_game_objects_dict[self] = null
	
	var direct_game_objects: Array = direct_game_objects_dict.keys()\
		.filter(func(x: GameObjectGD): return x in vision_range_game_objects)
		
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
			for ObjTile: TileGD in GameObject.occupied_tiles:
				visibles[ObjTile].onRemoveObject(GameObject)
		
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
			for ObjTile: TileGD in GameObject.occupied_tiles:
				visibles[ObjTile].onAddObject(GameObject)
	
func onTileOccupiedIsInVision(OccupiedTile: TileGD, PreviousTile: TileGD, Card: CardGD) -> void:
	var visibles: Dictionary = vision_datastore.getVisibles()
	
	if PreviousTile != null: visibles[PreviousTile].setByUnit(false)
	
	var new_tile_in_vision: bool = OccupiedTile != null and OccupiedTile in getVisibleGameObjects()
	
	if OccupiedTile != null: visibles[OccupiedTile].setByUnit(new_tile_in_vision)
	if Card != null and Card.isAlive(): visibles[Card].setByTile(new_tile_in_vision)
	
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
	VisionRay.position.y = getEyeFromInfo()
	
func onUpdateLevelVisible() -> void:
	visible = true if Helper.admin_datastore.see or is_card_change_level_visible else isLevelVisible()
	
func isLevelVisible() -> bool:
	return isAlly(0) or super()
	
func setLevelVisible(state: bool) -> void:
	if state != vision_datastore.level_visible:
		is_card_change_level_visible = true
		super(state)
		await setAlphagreyMaterial(1.0 if state else 0.0)
		is_card_change_level_visible = false
		onUpdateLevelVisible()
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
	
func setLevelVisibleNotInVision(state: bool) -> void: # Also gets set by vision mode
	level_visible_not_in_vision = state
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

func setEnemyInMovementRange(_state: bool) -> void:
	pass

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
func getAttacks() -> int: return attacks
	
func getAttackablesInAttackRange(AttackTile: TileGD) -> Dictionary:
	if !canAttack(): return {}
	var cards: Array = get_tree().get_nodes_in_group("FieldCardsGD")
	cards.erase(self)
	
	var attackables: Dictionary = {}
	var game_objects: Array = cards.filter(isValidAttackableInRange.bind(AttackTile))
	for GameObject: GameObjectGD in game_objects:
		if isValidAttackTile(AttackTile, GameObject):
			attackables[GameObject] = GameObject.getAttackableTile()
	return attackables
	
func getAttackablesInVision() -> Array:
	if !canAttack(): return []
	var cards: Array = get_tree().get_nodes_in_group("FieldCardsGD")
	cards.erase(self)
	var game_objects: Array = cards.filter(isValidAttackableInVision)
	return game_objects
	
func getAttackableTile() -> TileGD: # Simplifying function for iobjects
	return Tile
		
func isValidAttackableInVision(GameObject: GameObjectGD) -> bool:
	if !GameObject.isAttackable(self): return false
	if !(GameObject in getVisibleGameObjects()): return false
	return true
	
func isValidAttackableInRange(GameObject: GameObjectGD, StartTile: TileGD) -> bool:
	var in_vision: bool = isValidAttackableInVision(GameObject)
	if !in_vision: return false
	
	var in_attack_range: bool = Game.getCoordsDistance(StartTile.getCoords(), GameObject.getAttackableTile().getCoords()) <= getAttackRange()
	return in_attack_range
	
func isValidAttackableInRangeSpeed(GameObject: GameObjectGD, StartTile: TileGD) -> bool:
	var in_vision: bool = isValidAttackableInVision(GameObject)
	if !in_vision: return false
	
	var in_attack_range: bool = Game.getCoordsDistance(StartTile.getCoords(), GameObject.getAttackableTile().getCoords()) <= getAttackRange() + speed
	return in_attack_range
		
func isValidAttackTile(AttackTile: TileGD, GameObject: GameObjectGD) -> bool:
	var EnemyTile: TileGD = GameObject.getAttackableTile()
	var hdiff: int = abs(EnemyTile.getHeight() - AttackTile.getHeight())
	var is_in_height: bool = hdiff in [0, 1]
	
	var bot_y: float = GameObject.position.y
	var top_y: float = bot_y + (GameObject.getTopFromInfo() if GameObject is CardGD else GameObject.getTopVertexY())
	
	var bot_self_y: float = position.y
	var top_self_y: float = position.y + getTopFromInfo()
	
	var is_in_unit_height: bool = max(bot_y, bot_self_y) <= min(top_y, top_self_y)
	return (is_in_height or is_in_unit_height)
		
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
	
	if FieldInfo != null: FieldInfo.onUpdateStat(type, value, difference, isLevelVisible(), show_particles)
#endregion

#region Traits
func onCreateInitialTraits() -> void:
	var actions: Array = overworld_traits.map(func(x: OverworldTrait): return AddTraitAction.new(self, x))
	onPushAction(actions)
	
func onAddOverworldTrait(overworld_trait: OverworldTrait) -> void:
	overworld_traits.append(overworld_trait)
	
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
	var armor_data := SavedDataTrait.new(1, true, 0, armor)
	return SavedData.onLoadModel(armor_data, self)
	
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
	
func getOverworldTraits() -> Array:
	return overworld_traits
#endregion

#region Tools
func onAddTool(_Tool: ToolGD) -> void:
	Tool = _Tool

func onRemoveTool() -> void:
	onAddTool(null)

func getTool() -> ToolGD:
	return Tool

#region Active Effects
func onAddActiveEffect(active_effect: ActiveEffectDatastore) -> void:
	active_effects.append(active_effect)
	active_effect.owner = self
	
func onRemoveActiveEffect(active_effect: ActiveEffectDatastore) -> void:
	active_effects.erase(active_effect)

func onCreateInitialActiveAbilities() -> void:
	var tier_datastore := getCardTierDatastore(tier)
	var new_active_effects: Array = tier_datastore.getActiveAbilities()
	onPushAction(new_active_effects.map(func(x: ActiveEffectDatastore): return AddActiveEffectAction.new(self, x)))
	
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
	return active_effects
	
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

#region Advance Turn
func onAdvanceTurn(turn_team: int) -> void:
	super(turn_team)
	if team != turn_team or !is_in_group("FieldCardsGD"): return
	
	var actions: Array = [StatAction.new(
		StatInfo.new(self, Game.Stats.SPEED, max_speed - int(Tile.isDeepwater()), 0, true, false, true)),
		ChangeTurnStateAction.new(self, Game.TurnStates.INACTIVE, true)]
		
	actions += active_effects.map(func(x: ActiveEffectDatastore): return ChangeActiveEffectUsedAction.new(x, false))
	onPushAction(actions)
		
	if FieldInfo != null: FieldInfo.onUpdateDelayedStats()
#endregion

#region Delayed Stats
func onAddDelayedStatInfo(stat_info: StatInfo) -> void:
	delayed_stats.append(stat_info)
	if FieldInfo != null: FieldInfo.onUpdateDelayedStats()
	
func onRemoveDelayedStatInfo(stat_info: StatInfo) -> void:
	delayed_stats.erase(stat_info)
	if FieldInfo != null: FieldInfo.onUpdateDelayedStats()
	
func onAddDelayedHealDatastore(heal_datastore: HealDatastore) -> void:
	delayed_stats.append(heal_datastore)
	if FieldInfo != null: FieldInfo.onUpdateDelayedStats()
	
func onRemoveDelayedHealDatastore(heal_datastore: HealDatastore) -> void:
	delayed_stats.erase(heal_datastore)
	if FieldInfo != null: FieldInfo.onUpdateDelayedStats()
#endregion

#region Action Checker
func isValidEndOfTurn(action: Action) -> bool:
	return action.post and action is ChangeTurnStateAction and\
	action.Card == self and action.turn_state == Game.TurnStates.PASSED and (action.owner is not StatusEffectGD or (action.owner == null or action.owner.info.id != FATIGUE_ID))
	
func isValidTrauma(action: Action) -> bool:
	return action.post and action is DeathAction and isAlly(action.Defender.team) and card_place == Game.CardPlaces.FIELD and action.getCardSawDefenderDie(self)

func isValidLastWill(action: Action) -> bool:
	return action.post and action is DeathAction and action.Defender == self and card_place == Game.CardPlaces.GRAVEYARD

func isValidRampage(action: Action) -> bool:
	return action.post and action is DeathAction and action.Damager == self and card_place == Game.CardPlaces.FIELD and action.Defender.team != 2

func isValidOnHit(action: Action) -> bool:
	return action.post and action is DamageAction and action.owner is AttackAction and action.Damager == self and card_place == Game.CardPlaces.FIELD\
		and action.Defenders.any(func(x: GameObjectGD): return x is CardGD)

func isValidForceOnHit(action: Action) -> bool:
	return !action.post and action is DamageAction and action.owner is AttackAction and action.Damager == self and card_place == Game.CardPlaces.FIELD\
		and action.Defenders.any(func(x: GameObjectGD): return x is CardGD)

func isValidRevenge(action: Action) -> bool:
	return action.post and action is StatAction and action.owner is DamageAction and action.owner.damage > 0 and\
	action.owner.damage_type != Game.DamageTypes.FALL_DAMAGE and self in action.owner.Defenders and card_place == Game.CardPlaces.FIELD

func isValidBloodthirst(action: Action) -> bool:
	return action.post and action is DeathAction and action.Damager != self and isEnemy(action.Defender.team)\
	and card_place == Game.CardPlaces.FIELD and action.getCardSawDefenderDie(self) and action.Defender.team != 2

func isValidArrive(action: Action) -> bool:
	return action.post and action is AwakenAction and action.Card == self

func isValidWhenHealed(action: Action) -> bool:
	return action.post and action is StatAction and action.owner is HealAction and action.hasCard(self) and card_place == Game.CardPlaces.FIELD
#endregion

#region Heal
func isHealable() -> bool:
	return health < max_health
	
func isInjured() -> bool:
	return health < max_health
#endregion

#region Field Effect
func onAddFieldEffect(FieldEffect: FieldEffectGD) -> void:
	field_effects.append(FieldEffect)
	FieldEffect.Card = self
	
	if FieldInfo != null:
		FieldInfo.onAddIcon(FieldEffect)
	
func onCreateBaseFieldEffect(id: int, charges: int = -1, turns: int = -1, FofObject: FofGD = self) -> FieldEffectGD:
	var field_effect_data: SavedDataFieldEffect = SavedDataFieldEffect.new(id, true)
	field_effect_data.charges = charges
	field_effect_data.turns = turns
	
	var FieldEffect: FieldEffectGD = SavedData.onLoadModel(field_effect_data, self)
	FieldEffect.Card = self
	
	onPushAction(AddFieldEffectAction.new(FieldEffect, FofObject))
	return FieldEffect
	
func onCreateBaseFieldEffectAction(id: int, charges: int = -1, turns: int = -1, FofObject: FofGD = self) -> AddFieldEffectAction:
	var field_effect_data: SavedDataFieldEffect = SavedDataFieldEffect.new(id, true)
	field_effect_data.charges = charges
	field_effect_data.turns = turns
	
	var FieldEffect: FieldEffectGD = SavedData.onLoadModel(field_effect_data, self)
	FieldEffect.Card = self
	return AddFieldEffectAction.new(FieldEffect, FofObject)
	
func onRemoveFieldEffect(FieldEffect: FieldEffectGD) -> void:
	if FieldEffect == null: return
	field_effects.erase(FieldEffect)
	if FieldInfo != null: FieldInfo.onRemoveIcon(FieldEffect)
	FieldEffect.onClear()
	
func onRemoveFieldEffectsByOwner(FofObject: FofGD) -> void:
	var actions: Array = onFindFieldEffectsByOwner(FofObject).map(func(x: FieldEffectGD): return RemoveFieldEffectAction.new(x))
	onPushAction(actions)
	
func onFindFieldEffectsByOwner(FofObject: FofGD) -> Array:
	return field_effects.filter(func(x: FieldEffectGD): return x.FofObject == FofObject)
	
func getFirstFieldEffect(id: int) -> FieldEffectGD:
	for FieldEffect: FieldEffectGD in field_effects:
		if FieldEffect.info.id == id: return FieldEffect
	return null
	
func getFieldEffectsById(id: int) -> Array:
	return field_effects.filter(func(x: FieldEffectGD): return x.info.id == id)
#endregion

#region Status Effects
func onRemoveStatusEffect(status_effect: StatusEffectGD) -> void: # Access via action
	if status_effect == null: return
	
	status_effects.erase(status_effect)
	if FieldInfo != null: FieldInfo.onRemoveIcon(status_effect)
	
func onAddStatusEffect(status_effect: StatusEffectGD) -> void: # Access via action
	status_effects.append(status_effect)
	status_effect.Card = self
	if FieldInfo != null:
		FieldInfo.onAddIcon(status_effect)
	
func onCreateBaseStatusEffect(id: int, turns: int = 1) -> void:
	onPushAction(onCreateBaseStatusEffectAction(id, turns))
	
func onCreateBaseStatusEffectAction(id: int, turns: int = 1, Creator: FofGD = null) -> AddStatusEffectAction:
	var status_data := SavedDataStatusEffect.new(id, true, 0, turns)
	var status_effect: StatusEffectGD = SavedData.onLoadModel(status_data, self)
	status_effect.Card = self
	status_effect.Creator = Creator
	return AddStatusEffectAction.new(status_effect)
	
func getBaseStatusEffectAction(id: int, turns: int = 1, Creator: FofGD = null) -> AddStatusEffectAction:
	var status_data := SavedDataStatusEffect.new(id, true, 0, turns)
	var status_effect: StatusEffectGD = SavedData.onLoadModel(status_data, self)
	status_effect.Card = self
	status_effect.Creator = Creator
	return AddStatusEffectAction.new(status_effect)
	
func onStun(turns: int = 1) -> void:
	onCreateBaseStatusEffect(4, turns)
	onCreateBaseStatusEffect(5, turns)
	
func getStunActions(turns: int = 1) -> Array:
	return [getBaseStatusEffectAction(4, turns), getBaseStatusEffectAction(5, turns)]
	
func isInvisible() -> bool:
	return status_effects.any(func(x: StatusEffectGD): return x.info.id == 2)
	
func isNotInvisibleOrIsAdjacent(_Tile: TileGD) -> bool:
	return !isInvisible() or Game.isAdjacent(_Tile, Tile)
	
func isBlind() -> bool:
	return status_effects.any(func(x: StatusEffectGD): return x.info.id == 1)
	
func getStatusEffect(id: int, Creator: FofGD = null) -> StatusEffectGD:
	for status_effect: StatusEffectGD in status_effects:
		if status_effect.info.id == id and (Creator == null or status_effect.Creator == Creator):
			return status_effect
	return null
#endregion

#region Revenge
func onRevenge(_action: DamageAction) -> void:
	if AniPlayer.has_animation("HurtAbility"):
		onPlayAnimation("HurtAbility")
#endregion

#region Tiered Up
func onTierUp() -> void:
	onRetiered(min(tier + 1, 4))

func onRetiered(_tier: int) -> void: # This doesn't account for tiering down as of yet
	# Stat Region
	tier = _tier
	var stat_datastore: StatsDatastore = getStatsFromInfo()
	var plus_attack: int = stat_datastore.attack - base_stats.attack
	var plus_health: int = stat_datastore.health - base_stats.health
	var plus_speed: int = stat_datastore.speed - base_stats.speed
	var plus_energy: int = stat_datastore.energy - base_stats.energy
	
	var types: Array = [Game.Stats.ATTACK, Game.Stats.HEALTH, Game.Stats.MAX_HEALTH, Game.Stats.MAX_SPEED, Game.Stats.ENERGY]
	var values: Array = [plus_attack, plus_health, plus_health, plus_speed, plus_energy]
	var actions: Array = [BaseStatAction.new(self, types, values)]
	
	# Trait Region
	var tier_datastore: CardTierDatastore = info.getTierDatastore(tier)
	var new_traits: Array = tier_datastore.getTraits()
	actions += new_traits.map(func(x: SavedDataTrait):\
		return AddOverworldTraitAction.new(self, OverworldTrait.new(x, OverworldTrait.AddedBy.REGULAR), true))
		
	var old_traits: Array = getOverworldTraits()
	actions += old_traits.map(func(x: OverworldTrait): return RemoveOverworldTraitAction.new(self, x.data.id, OverworldTrait.AddedBy.REGULAR))
		
	# Active Effect Region
	var new_active_effects: Array = tier_datastore.getActiveAbilities()
	actions += active_effects.map(func(x: ActiveEffectDatastore): return RemoveActiveEffectAction.new(self, x))
	actions += new_active_effects.map(func(x: ActiveEffectDatastore): return AddActiveEffectAction.new(self, x))
	onPushAction(actions)
	tier_updated.emit(tier)

#region Temp Card
	
func setIsTemporary(_is_temporary: bool) -> void:
	is_temporary = _is_temporary
	is_temporary_updated.emit()
	
func isTemporary() -> bool:
	return is_temporary
#endregion

#region Elites
func isValidEliteLevelSpawns(_enemy_cards: Array) -> bool:
	return true
#endregion

#region Level Ended
func onLevelEnded(_win: bool) -> void:
	onReset(true)
	if card_place == Game.CardPlaces.STASH: return
	if isAlly(0) and !is_awakened_in_combat:
		if card_place != Game.CardPlaces.DECK:
			onChangeCardPlace(Game.CardPlaces.DECK)
	else: onChangeCardPlace(Game.CardPlaces.GRAVEYARD)
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
func setActiveArchetype(archetype_info: ArchetypeInfo) -> void:
	ai_datastore.setActiveArchetype(archetype_info)

func onUnitSpecificTransforms(_tiles_to_value: Dictionary, _DFL: DefaultFightLogic) -> void:
	pass
	
func getArchetypeEnum(archetype_id: int = info.archetype.id) -> Game.Archetypes: # Useful for boss cards
	match archetype_id:
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
		11: return Game.Archetypes.RECEIVER
		12: return Game.Archetypes.MERCENARY
	return Game.Archetypes.NULL
	
func getActiveArchetype() -> ArchetypeInfo:
	return ai_datastore.getActiveArchetype()
	
# True if active effect used
func onAICheckActiveEffects(DFL: DefaultFightLogic, allies: Array, enemies: Array, after_action: MovementFinishAction = null) -> bool:
	var tool_active_effects: Array = Tool.getActiveEffects() if Tool != null else []
	var ai_active_effects: Array = getActiveEffects() + tool_active_effects
	
	if getTile() != null:
		for IObject in Game.get_tree().get_nodes_in_group("LevelIObjectsGD")\
			.filter(func(x: ObjectGD): return !x.is_queued_for_deletion()):
			
			ai_active_effects += IObject.getValidActiveEffects(self)
		
	for active_effect in ai_active_effects:
		var active_effect_tiles: ActiveEffectTiles = active_effect.owner.onAIAbilityCheckerDefault(active_effect)\
			if active_effect.owner is not IObjectGD else active_effect.owner.onAIAbilityCheckerDefault(active_effect, self)
		if active_effect_tiles == null: continue
		
		var ChosenTile: TileGD = active_effect.owner.onAIAbilityChecker(active_effect, active_effect_tiles, DFL)
		if ChosenTile == null: continue
		
		var actions: Array = [ChangeTurnStateAction.new(self, Game.TurnStates.ACTIVE),\
			ActiveEffectUsedAction.new(active_effect, ChosenTile, active_effect_tiles, self),\
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
	if is_in_alphagrey: return
		
	var mat: Material = load(info.BASE_MATERIAL_SPECULAR_PATH)
	if level_visible_not_in_vision:
		mat = info.getColoredBaseMaterial(team)
	setMeshesMaterial(mat, Model)

var AlphagreyTween: Tween
var is_in_alphagrey: bool # Important so setBaseMaterials doesnt ov
func setAlphagreyMaterial(start_value: float) -> void:
	if !isAlive() or Helper.admin_datastore.see: return
	if AlphagreyTween != null: AlphagreyTween.stop()
	
	
	is_in_alphagrey = true
	
	await onTweenAlphagreyValue(start_value, ALPHAGREY_CHANGE_SPEED)
	
	is_in_alphagrey = false
	setBaseMaterials()
	
func onTweenAlphagreyValue(start_value: float, time: float) -> void:
	setMeshesMaterial(load(info.BASE_MATERIAL_ALPHAGREY_PATH), Model)
	setAlphagreyMaterialValue(start_value)
	AlphagreyTween = get_tree().create_tween()
	AlphagreyTween.tween_method(setAlphagreyMaterialValue, start_value, abs(start_value - 1), time)
	await AlphagreyTween.finished
	
func setAlphagreyMaterialValue(value: float) -> void: # 0.0 is visible, 1.0 is invisible
	if Model == null: return
	
	for mesh in getMeshes(Model):
		mesh.set_instance_shader_parameter("time_value", value)
#endregion

func getAdjustedPoints() -> Array:
	return getLevelPoints().map(func(x: Vector3): return (Game.onRotatePosition(x, rotation.y)) + position)
	
func onReset(override: bool = false) -> void: # Called when unit enters level (not awakened) and level ends, override for when level ends
	setStats(base_stats)
			
	if !override and !(isAlly(0) or is_awakened_in_combat): return
	
	level_visible_not_in_vision = false
	attacks = 1
	attack_range = 1
	tile_rotation = 0
	delayed_stats = []
	
	active_effects = []
	status_effects = []
	field_effects = []
	ability_save = {}
	turn_state = Game.TurnStates.NULL
	vision_datastore = VisionDatastoreCard.new()
	
	if Tool != null:
		if Tool.info.rarity != Game.Rarities.MINI:
			Tool.onReset(override)
	
	ai_datastore.onReset()
	Tile = null
	onRemoveModel()
	
	for overworld_trait in overworld_traits:
		overworld_trait.onReset(self)
		
	onRegularReset()
	
func onRegularReset() -> void: # Fof Init, Awakened, Death, Level Start, Level End
	if Tool != null:
		Tool.onRegularReset()
	onPushAction(ChangeArchetypeAction.new(self, getArchetypeFromInfo()))
	
func getModel() -> Node3D:
	return Model
	
#region Info Getters
func getTopFromInfo() -> float:
	return info.top
	
func getEyeFromInfo() -> float:
	return info.eye
	
func getNameFromInfo() -> String:
	return info.name
	
func getModelFromInfo() -> PackedScene:
	return info.model
	
func getCollisionShapeFromInfo() -> PackedScene:
	return info.collision_shape
	
func getPointsFromInfo() -> Array:
	return info.points
	
func getArchetypeFromInfo() -> ArchetypeInfo:
	return info.archetype
	
func getIcon() -> Texture2D: return info.art_mini

func getStatsFromInfo() -> StatsDatastore:
	return info.getStats(tier)
#endregion

#region Knockback
func setIsKnockback(state: bool) -> void:
	is_knockback = state
#endregion

#region Base Stats
func setBaseStats(types: Array, values: Array) -> void:
	var stat_info := StatInfo.new(self, [], [])
	var actions: Array = []
	for i in range(types.size()):
		var type: Game.Stats = types[i]
		match type:
			Game.Stats.ATTACK: base_stats.attack += values[i]
			Game.Stats.MAX_HEALTH:
				base_stats.health += values[i]
			Game.Stats.MAX_SPEED: base_stats.speed += values[i]
			Game.Stats.ENERGY:
				base_stats.energy += values[i]
				actions.append(CardEnergyAction.new(self, values[i]))
			
		if type in [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.MAX_SPEED]:
			stat_info.types.append(type)
			stat_info.values.append(values[i])
			
			if type == Game.Stats.MAX_HEALTH:
				stat_info.types.append(Game.Stats.HEALTH)
				stat_info.values.append(values[i])
			
	onPushAction(StatAction.new(stat_info))
	
func onCanCreateInspectScreen() -> bool: return true

func onCanHoverOnTile(): return true

#region Movement Range
func getsetMovementRange(speed_override: int = -1) -> Array:
	if Tile == null: return []
	get_tree().call_group("FieldCardsGD", "setEnemyInMovementRange", false)
	get_tree().call_group("LevelTilesGD", "setMovementPath", null)
	
	var CenterTile: TileGD = Tile
	var new_speed: int = getMovementSpeed()
	if speed_override != -1:
		new_speed = speed_override
		
	var tiles: Array = Game.getAdjacentOrCloserTiles(Tile, speed) # Gather all tiles
	var visible_cards_tiles: Array = []
	
	if isAlly(0):
		visible_cards_tiles = get_tree().get_nodes_in_group("FieldCardsGD")\
			.filter(func(x: CardGD): return x.isLevelVisible())\
			.map(func(x: CardGD): return x.getTile())
	else:
		visible_cards_tiles = get_tree().get_nodes_in_group("FieldCardsGD").map(func(x: CardGD): return x.getTile())
	
	#tiles = tiles.filter(func(x: TileGD): return !x.isSolid() and x not in all_cards_tiles and x.isBelowMaxMovementHeight(self)) # Check for solidity
	tiles = tiles.filter(func(x: TileGD): return !x.isSolid() and x not in visible_cards_tiles and x.isBelowMaxMovementHeight(self)) # Check for solidity
	for AstarTile: TileGD in tiles:
		var astar := AStar3D.new()
		# Limits tiles to those in movement range
		var add_to_astar_tiles: Array = tiles.filter(func(x: TileGD): return Game.getCoordsDistance(AstarTile.getCoords(), x.getCoords()) <= new_speed)
		add_to_astar_tiles.append(CenterTile)
		for _Tile: TileGD in add_to_astar_tiles: astar.add_point(_Tile.get_instance_id(), _Tile.getCoordsHeightless())
		
		for StartTile: TileGD in add_to_astar_tiles:
			for EndTile: TileGD in add_to_astar_tiles.filter(func(x: TileGD): return Game.isAdjacent(x, StartTile)):
				var height_diff: int = EndTile.getHeight() - StartTile.getHeight()
				if StartTile.isRamp():
					if StartTile.isValidRampRelation(EndTile, height_diff):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif EndTile.isRamp():
					if EndTile.isValidRampRelation(StartTile, height_diff):
						astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
					
				elif height_diff <= 1:
					astar.connect_points(StartTile.get_instance_id(), EndTile.get_instance_id(), false)
						
		var valid_path: bool = false
		var point_path: Array = []
		var movement_path: Array = []
		
		while(!valid_path):
			point_path = astar.get_id_path(CenterTile.get_instance_id(), AstarTile.get_instance_id())
			if point_path.is_empty(): break
			if point_path.size() > new_speed + 1:
				astar.disconnect_points(point_path[point_path.size() - 1], point_path[point_path.size() - 2])
				continue
			
			movement_path = point_path.map(func(x: int): return instance_from_id(x))
			if movement_path.size() > new_speed + 2:
				astar.disconnect_points(point_path[point_path.size() - 1], point_path[point_path.size() - 2])
				continue
			if !onSurviveFallDamage(self, movement_path, point_path, astar): continue
			valid_path = true
			
		AstarTile.setMovementPath(MovementPathGD.new(movement_path, isAlly(0)) if valid_path else null)
	
	var available_tiles: Array = tiles.filter(func(x: TileGD): return x.getMovementPath() != null)
	available_tiles.append(CenterTile)
	
	var attackables: Array = getAttackablesInVision()
	for GameObject: GameObjectGD in attackables:
		var GameObjectTile: TileGD = GameObject.getAttackableTile()
		var game_object_coords: Vector4i = GameObjectTile.getCoords()
		
		var tiles_in_range: Array = available_tiles\
			.filter(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), game_object_coords) <= getAttackRange())
		tiles_in_range = tiles_in_range.filter(isValidAttackTile.bind(GameObject))
			
		if tiles_in_range.is_empty(): continue
		var AttackFromTile: TileGD
		var attack_from_path: Array = []
		if CenterTile not in tiles_in_range:
			tiles_in_range.sort_custom(func(x: TileGD, y: TileGD): return x.getMovementPathSize() < y.getMovementPathSize())
			AttackFromTile = tiles_in_range[0]
			attack_from_path = AttackFromTile.getMovementPathTiles().duplicate()
		else: # Closest tile is always the center tile as it's distance is 0, has to have unique logic as it doesn't generate paths
			AttackFromTile = CenterTile
			attack_from_path = [CenterTile]
		
		available_tiles.append(GameObjectTile)
		attack_from_path.append(GameObjectTile)
		
		GameObjectTile.setMovementPath(MovementPathGD.new(attack_from_path, isAlly(0)))
		if GameObject is CardGD:
			GameObject.setEnemyInMovementRange(true)
	
	available_tiles.erase(CenterTile)
	return available_tiles
	
func onSurviveFallDamage(Card: CardGD, movement_path: Array, point_path: Array, astar: AStar3D) -> bool:
	Card.temp_fall_damage = 0
	for i in range(1, movement_path.size()):
		var fall_damage: int = movement_path[i].getFallDamage(movement_path[i - 1])
		if fall_damage > 0:
			var survive_fall_damage: bool = Card.isCardSurviveFallDamage(fall_damage)
			if !survive_fall_damage and i != movement_path.size() - 1:
				astar.disconnect_points(point_path[i - 1], point_path[i])
				return false
	return true
#endregion

func getOverrideSpeed(limit: int) -> int:
	return min(speed, limit)

func getStatValue(stat: Game.Stats) -> int:
	match stat:
		Game.Stats.ATTACK: return attack
		Game.Stats.HEALTH: return health
		Game.Stats.MAX_HEALTH: return max_health
		Game.Stats.SPEED: return speed
		Game.Stats.MAX_SPEED: return max_speed
		Game.Stats.ENERGY: return energy
	return Game.Stats.ATTACK

const SHIELD_ID: int = 3
func onGainShield(FofObject: FofGD = null) -> FieldEffectGD:
	if getFirstFieldEffect(SHIELD_ID) != null: return null # Shield can't stack
	return onCreateBaseFieldEffect(SHIELD_ID, -1, -1 , FofObject)
	
func onGainShieldAction(FofObject: FofGD = null) -> AddFieldEffectAction:
	if getFirstFieldEffect(SHIELD_ID) != null: return null
	return onCreateBaseFieldEffectAction(SHIELD_ID, -1, -1, FofObject)
	
func getTier() -> int:
	return tier
	
func getCardTierDatastore(_tier: int = tier) -> CardTierDatastore:
	return info.getTierDatastore(_tier)

func getAttack() -> int:
	return attack
	
func getHealth() -> int:
	return health
	
func getMaxHealth() -> int:
	return max_health
	
func getSpeed() -> int:
	return speed
	
func getEnergy() -> int:
	return energy

func getTeam() -> int:
	return team

func getDeathIds() -> Array[int]:
	return death_ids

func getTurnState() -> Game.TurnStates:
	return turn_state
