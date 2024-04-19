extends Node3D

var mesh: MeshInstance3D
var collision_shape: CollisionShape3D
var static_body: StaticBody3D

var Unit: UnitGD
var AniPlayer: AnimationPlayer
signal movement_finished
signal attack_finished
signal death_finished
signal hurt_finished
signal drop_calculate_damage
var rot: int
@export var collision_points: PackedVector3Array # dont use these

var IdleRareTimer: Timer

const IDLE_RARE_MINIMUM: int = 8
const IDLE_RARE_MAXIMUM: int = 100
const UNIT_ANIMATION_BLEND_TIME: float = 0.2
const WALK_TRAVEL_TIME: float = 1.0 # 1.0

func on_idle_rare_timer_timeout() -> void:
	if AniPlayer.current_animation == "Idle" and AniPlayer.has_animation("IdleRare"):
		on_play_animation("IdleRare")
	IdleRareTimer.start(Unit.Units.Random.RNG.randi_range(IDLE_RARE_MINIMUM, IDLE_RARE_MAXIMUM))

func _ready() -> void:
	mesh = get_child(0).get_child(0).get_child(0)
	static_body = get_child(0).get_child(0).get_child(1)
	collision_shape = static_body.get_child(0)
	
	onCreateGreyMaterials()
	AniPlayer = get_node("AnimationPlayer")
	AniPlayer.animation_finished.connect(on_finish_animation)
	
	if Unit != null:
		IdleRareTimer = Timer.new()
		add_child(IdleRareTimer)
		IdleRareTimer.timeout.connect(on_idle_rare_timer_timeout)
		on_idle_rare_timer_timeout()
	
	on_play_animation("Idle")
	rot = (rot + 2) % 6
		
	if Unit != null:
		on_set_rotation()

func on_play_animation(ani_name: String) -> void:
	AniPlayer.play(ani_name, UNIT_ANIMATION_BLEND_TIME)
	if ani_name == "Walk": on_play_walk_sfx()
	
var current_walk_stream_player: AudioStreamPlayer
func on_play_walk_sfx() -> void:
	var sfx: String = on_find_walk_sfx(Unit.Tile.tile.id)
	var is_null: bool = current_walk_stream_player == null 
	if is_null or sfx != current_walk_stream_player.playing_sfx:
		if !is_null: AudioMaster.on_cutoff_sfx(current_walk_stream_player)
		current_walk_stream_player = AudioMaster.play_sfx(sfx)
	
func on_find_walk_sfx(id: int) -> String:
	var sfx: String
	match id:
		1: sfx = Helper.area_to_default_ground[Unit.Units.GameState.area_info.id]
		3,4: sfx = "WaterWalk"
	return sfx
	
func on_finish_animation(ani_name: String) -> void:
	AniPlayer.speed_scale = 1
	if ani_name != "Walk" and ani_name != "Death" and (ani_name != "Jump"): on_play_animation("Idle")
	match ani_name:
		"Walk": movement_finished.emit()
		"Attack": attack_finished.emit(); if Unit != null: AudioMaster.play_sfx(Unit.AudioDict.ATTACK)
		"Death": death_finished.emit()
		"Jump": movement_finished.emit(); is_jump = false; jump_time = 0
		"Hurt": hurt_finished.emit();

func onCreateGreyMaterials() -> void:
	for i in mesh.mesh.get_surface_count():
		var transform_greyscale_mat: Material = load("res://assets/materials/transform_grey/transform_grey.tres").duplicate()
		var grey_instant_mat: Material = load("res://assets/materials/grey_instant/grey_instant.tres").duplicate()
		
		var tx: ImageTexture = load(mesh.get_active_material(i).albedo_texture.resource_path)
		transform_greyscale_mat.set_shader_parameter("texture_albedo", tx)
		grey_instant_mat.set_shader_parameter("texture_albedo", tx)
		
		transform_grey_materials.append(transform_greyscale_mat)
		grey_instant_materials.append(grey_instant_mat)
		
var grey_instant_materials: Array
var transform_grey_materials: Array
func onSetOverrideMaterial(type: String) -> void:
	if type.begins_with("Transform"):
		if type != "TransformInstant":
			var start_value: float = 0.0 if type == "TransformGrey" else 1.0
			var end_value: float = 1.0 if type == "TransformGrey" else 0.0
			
			var MaterialTween: Tween = create_tween()
			MaterialTween.tween_method(onSetShaderParameter, start_value, end_value, WALK_TRAVEL_TIME)
			MaterialTween.finished.connect(onRemoveTransformMaterial.bind(type))
			if type == "TransformRegular": setVisible(true)
		
		for i in mesh.mesh.get_surface_count():
			mesh.set_surface_override_material(i, transform_grey_materials[i])
	
	elif type == "GreyInstant":
		for i in mesh.mesh.get_surface_count():
			mesh.set_surface_override_material(i, grey_instant_materials[i])
	else:
		for i in mesh.mesh.get_surface_count():
			mesh.set_surface_override_material(i, null)

func onRemoveTransformMaterial(type: String) -> void:
	if type == "TransformGrey": setVisible(false)
	onSetOverrideMaterial("null")

func onSetShaderParameter(value: float) -> void:
	for mat in transform_grey_materials:
		mat.set_shader_parameter("time_value", value)

var walk_to_info: Array = []
func onMoveToTile(Tile: TileGD, type: Variant, movement_type: String) -> void:
	walk_to_info = [Tile, type, movement_type]
	on_play_animation("Walk")
	
func attack_tile(Tile: TileGD) -> void:
	_look_at(Tile)
	on_play_animation("Attack")

var jump_start: Vector3
var jump_end: Vector3

var JUMP_HEIGHT: float = -3
var JUMP_TIME: float = 1

var jump_time: float = 0.0

func _process(delta: float) -> void:
	if !walk_to_info.is_empty(): on_begin_all_movement_between_tiles()
	if is_jump:
		jump_time += delta
		if jump_time <= JUMP_TIME:
			Unit.global_position =  jump_start.cubic_interpolate(jump_end, Vector3(jump_start.x, jump_start.y + JUMP_HEIGHT, jump_start.z),\
			Vector3(jump_end.x, jump_end.y + JUMP_HEIGHT, jump_end.z), jump_time / JUMP_TIME)
		else:
			Unit.global_position = jump_end
		
func on_begin_all_movement_between_tiles() -> void:
	_look_at(walk_to_info[0])
	if Unit.team == 1:
		match walk_to_info[2]:
			"Regular": onSetOverrideMaterial("null")
			"OutOfVision": onSetOverrideMaterial("TransformGrey")
			"IntoVision": onSetOverrideMaterial("TransformRegular")
	
	match walk_to_info[1].x:
		3: on_create_regular_jump(walk_to_info[0])
		4: on_create_drop_jump(walk_to_info[0], walk_to_info[1].y, walk_to_info[1].z)
		_: on_create_move_tween(walk_to_info[0], walk_to_info[1])
	walk_to_info = []
	
func onCalculateEndPosition(Tile: TileGD, type: int) -> Vector3:
	match type:
		3: 
			return Vector3(Tile.global_position.x, Tile.global_position.y + (0.9 if Tile.tile.type == 1 else 0.3), Tile.global_position.z)
		4:
			return Vector3(Tile.global_position.x, Tile.global_position.y + (0.75 if Tile.tile.type == 1 else 0.3), Tile.global_position.z)
		_:
			var climb_slope: float = 0.9 if (type == 2 or Tile.tile.type == 1) else 0.3
			return Vector3(Tile.global_position.x, Tile.global_position.y + climb_slope, Tile.global_position.z)
		
var is_jump: bool = false
func on_create_regular_jump(Tile: TileGD) -> void:
	JUMP_TIME = 1
	JUMP_HEIGHT = -4
	jump_start = Unit.global_position
	jump_end = onCalculateEndPosition(Tile, 3)
	is_jump = true
	AniPlayer.speed_scale = 2
	
	on_play_animation("Jump")
	
const JUMP_HEIGHT_MULTIPLIER: float = 2.3
func on_create_drop_jump(Tile: TileGD, hdiff: int, new_health: int) -> void:
	JUMP_TIME = 1 - (hdiff * 0.1)
	JUMP_HEIGHT = -3 + (hdiff * JUMP_HEIGHT_MULTIPLIER)
	jump_start = Unit.global_position
	jump_end = onCalculateEndPosition(Tile, 4)
	is_jump = true
	AniPlayer.speed_scale = 2.0 / JUMP_TIME
	on_play_animation("Jump")
	
	get_tree().create_timer((3 / AniPlayer.speed_scale) / 1.5).timeout\
	.connect(func(): drop_calculate_damage.emit(new_health, (3 / AniPlayer.speed_scale) / 6))
func on_create_move_tween(Tile: TileGD, type: Vector2i) -> void:
	var MoveTween: Tween = create_tween()
	var half_position := Vector3(Tile.global_position + global_position) * 0.5
	var climb_slope: float = 0.9 if Tile.tile.type == 1 else (1.5 if (type.x == 2 and type.y == -1) else 0.3)
	MoveTween.tween_property(Unit, "global_position",
	Vector3(half_position.x, Tile.global_position.y + climb_slope, half_position.z),
	WALK_TRAVEL_TIME * 0.5)
	MoveTween.finished.connect(on_create_second_move_tween.bind(Tile, type))
	
func on_create_second_move_tween(Tile: TileGD, type: Vector2i) -> void:
	var end_position: Vector3 = onCalculateEndPosition(Tile, type.x)
	var MoveTween: Tween = create_tween()
	MoveTween.tween_property(Unit, "global_position",
	end_position,
	WALK_TRAVEL_TIME * 0.5)
	MoveTween.finished.connect(on_finish_animation.bind("Walk"))

func onLookAtRelative(Tile: TileGD, _Tile: TileGD) -> void:
	rot = Unit.Units.Tiles.neighbour_rotation(Tile, _Tile)
	on_set_rotation()

func _look_at(Tile: TileGD) -> void: #will rotate the object
	rot = Unit.Units.Tiles.neighbour_rotation(Tile, Unit.Tile)
	on_set_rotation()

func on_death() -> void:
	on_play_animation("Death")
	AudioMaster.play_sfx(Unit.AudioDict.DEATH)

func on_hurt() -> void:
	if AniPlayer.has_animation("Hurt"):
		on_play_animation("Hurt")
		AudioMaster.play_sfx(Unit.AudioDict.HURT)
	else:
		await get_tree().create_timer(0.1).timeout
		hurt_finished.emit()

func onGetAdjustedPoints() -> PackedVector3Array:
	return Array(collision_points)\
	.map(getRotationPoint.bind(deg_to_rad(-rotation_degrees.y), global_position))\
	as PackedVector3Array

func on_set_rotation() -> void:
	rotation_degrees.y = 270 + (rot * 60)
	
func getRotationPoint(xyz: Vector3, r: float, pos: Vector3) -> Vector3:
	return Vector3(xyz.x * (cos(r)) - xyz.z * (sin(r)), xyz.y, xyz.z * (cos(r)) + xyz.x * (sin(r))) + pos

func setVisible(state: bool) -> void:
	mesh.visible = state
	Unit.UnitFieldStatus.visible = state
