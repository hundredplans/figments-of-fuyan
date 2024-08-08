class_name ModelGD
extends Node3D

var mesh: MeshInstance3D
var collision_shape: CollisionShape3D
var static_body: StaticBody3D

var Unit: UnitGD
var AniPlayer: AnimationPlayer
signal unit_fell
var rot: int
@export var collision_points: PackedVector3Array # dont use these

var IdleRareTimer: Timer

var death: String = "Death"
var idle: String = "Idle"
const IDLE_RARE_MINIMUM: int = 8
const IDLE_RARE_MAXIMUM: int = 100
const UNIT_ANIMATION_BLEND_TIME: float = 0.2
const WALK_TRAVEL_TIME: float = 1.0

var idle_speedup: float = 1

func on_idle_rare_timer_timeout() -> void:
	if AniPlayer.current_animation == idle and AniPlayer.has_animation("IdleRare"):
		on_play_animation("IdleRare")
	IdleRareTimer.start(Unit.Units.Random.RNG.randi_range(IDLE_RARE_MINIMUM, IDLE_RARE_MAXIMUM))

func _ready() -> void:
	mesh = get_child(0).get_child(0).get_child(0)
	static_body = get_child(0).get_child(0).get_child(1)
	collision_shape = static_body.get_child(0)
	
	onCreateBaseMaterials()
	AniPlayer = get_node("AnimationPlayer")
	
	if Unit != null:
		IdleRareTimer = Timer.new()
		add_child(IdleRareTimer)
		IdleRareTimer.timeout.connect(on_idle_rare_timer_timeout)
		on_idle_rare_timer_timeout()
	
	on_play_animation(idle)
	rot = (rot + 2) % 6
		
	if Unit != null:
		on_set_rotation()

	onSetOverrideMaterial("Regular")
	AniPlayer.playback_default_blend_time = UNIT_ANIMATION_BLEND_TIME
	AniPlayer.animation_finished.connect(func(__: String): on_play_animation("Idle"))

func setDisabled(x: bool) -> void: collision_shape.disabled = x

var is_vfx_ani_playing: bool = false
var previous_ani: String
func on_play_animation(ani_name: String) -> void:
	if previous_ani != "Death" and !is_vfx_ani_playing:
		previous_ani = ani_name
		if ani_name not in ["Idle", "Jump"]: AniPlayer.speed_scale = 1
		match ani_name:
			"Attack": ani_name = Unit.getAttackAnimation() if AniPlayer.has_animation("AttackAbility") else "Attack"
			"Idle":
				ani_name = idle
				AniPlayer.speed_scale = idle_speedup
			"Walk": on_play_walk_sfx()
			
		if AniPlayer.is_playing(): onAnimationFinished(AniPlayer.current_animation)
		AniPlayer.play(ani_name)
	
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
		1: sfx = Helper.area_to_default_ground[Unit.Units.GameState.save_info.area_info.id]
		3,4: sfx = "WaterWalk"
	return sfx
	
func onAnimationFinished(ani_name: String) -> void:
	match ani_name:
		"Attack", "AttackAbility": if Unit != null: AudioMaster.play_sfx(Unit.AudioDict.ATTACK)
		"Jump": is_jump = false

var materials: Array = []
const DEFAULT_MULT_VALUE: float = 1
func onCreateBaseMaterials() -> void:
	pass
	#if Unit != null:
		#var next_pass: Material = load("res://assets/materials/unit_material/unit_material_outline.tres").duplicate()
		#if Unit.team == 0: next_pass.set_shader_parameter("green_multiply", DEFAULT_MULT_VALUE)
		#else: next_pass.set_shader_parameter("red_multiply", DEFAULT_MULT_VALUE)
		#for i in mesh.mesh.get_surface_count():
			#var unit_material: Material = load("res://assets/materials/unit_material/unit_material.tres").duplicate()
		#
			#var img: Image = ImageTexture.create_from_image(img)
			#var tx: ImageTexture = load(mesh.get_active_material(i).albedo_texture.resource_path)
			#
			#unit_material.next_pass = next_pass
			#unit_material.set_shader_parameter("texture_albedo", tx)
			#mesh.set_surface_override_material(i, unit_material)
			#materials.append(unit_material)
			#
		#onSetOutlineProperties(false)
		
func onSetOutlineProperties(is_spectating_or_enemy_in_range: bool) -> void:
	var team_color: Color
	if Unit != null:
		match Unit.team:
			0: team_color = Color(0, 1, 0) if !is_spectating_or_enemy_in_range else Color("c5ffc5")
			1: team_color = Color(1, 0, 0) if !is_spectating_or_enemy_in_range else (Color("ffc5c5"))
			
		for mat in materials: mat.next_pass.set_shader_parameter("albedo", team_color)
		
func onSetOverrideMaterial(type: String) -> void:
	match type:
		"Regular": onSetShaderParameter(0)
		"FromGrey", "IntoGrey":
			var start_value: float = 0
			var end_value: float = 0
			match type:
				"FromGrey": start_value = 1; end_value = 0
				"IntoGrey": start_value = 0; end_value = 1
				
			var MaterialTween: Tween = create_tween()
			MaterialTween.tween_method(onSetShaderParameter, start_value, end_value, WALK_TRAVEL_TIME)
			MaterialTween.finished.connect(onRemoveTransformMaterial.bind(type))
			if type == "FromGrey": setVisible(true)
		"GreyInstant": onSetShaderParameter(0.5)

func onRemoveTransformMaterial(type: String) -> void:
	if type == "IntoGrey": setVisible(false)

func onSetShaderParameter(value: float) -> void:
	for mat in materials:
		mat.set_shader_parameter("time_value", value)
		mat.next_pass.set_shader_parameter("time_value", value)

var walk_to_info: Dictionary = {}
func onMoveToTile(fneighbour: FneighbourGD, movement_path: MovementPathGD, movement_type: int = VisInfoGD.REGULAR) -> void:
	walk_to_info = {"fneighbour": fneighbour, "movement_type": movement_type, "movement_path": movement_path}
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
	if !walk_to_info.is_empty(): onBeginMovingToTile()
	if is_jump:
		jump_time += delta
		if jump_time <= JUMP_TIME:
			Unit.global_position =  jump_start.cubic_interpolate(jump_end, Vector3(jump_start.x, jump_start.y + JUMP_HEIGHT, jump_start.z),\
			Vector3(jump_end.x, jump_end.y + JUMP_HEIGHT, jump_end.z), jump_time / JUMP_TIME)
		else:
			Unit.global_position = jump_end
		
func onBeginMovingToTile() -> void:
	var fneighbour: FneighbourGD = walk_to_info.fneighbour
	var movement_type: int = walk_to_info.movement_type
	var movement_path: MovementPathGD = walk_to_info.movement_path
	_look_at(fneighbour.Tile)
	if Unit.team == 1:
		match movement_type:
			VisInfoGD.REGULAR: onSetOverrideMaterial("Regular")
			VisInfoGD.EXIT: onSetOverrideMaterial("IntoGrey")
			VisInfoGD.ENTER: onSetOverrideMaterial("FromGrey")
	
	match fneighbour.movement_type:
		FneighbourGD.JUMP: onCreateJump(fneighbour.Tile)
		FneighbourGD.FALL: onCreateFall(fneighbour.Tile, fneighbour.hdiff, movement_path.fall_damages[fneighbour.Tile])
		_: onCreateMoveTween(fneighbour.Tile)
	walk_to_info = {}
	
func onCalculateEndPosition(Tile: TileGD) -> Vector3:
	var climb_slope: float = 0.9 if (Tile.tile.type in [1, 2]) else 0.3
	var water_deslope: float = 0.1 if Tile.isWater() else 0.0
	return Vector3(Tile.global_position.x, Tile.global_position.y + climb_slope - water_deslope, Tile.global_position.z)

var is_jump: bool = false
func onCreateJump(Tile: TileGD) -> void:
	JUMP_TIME = 1
	JUMP_HEIGHT = -4
	jump_start = Unit.global_position
	jump_end = onCalculateEndPosition(Tile)
	is_jump = true
	jump_time = 0
	AniPlayer.speed_scale = 2
	on_play_animation("Jump")
	
const JUMP_HEIGHT_MULTIPLIER: float = 2.3
func onCreateFall(Tile: TileGD, hdiff: int, dmg: int) -> void:
	hdiff *= -1
	JUMP_TIME = 1 - (hdiff * 0.1)
	JUMP_HEIGHT = -3 + (hdiff * JUMP_HEIGHT_MULTIPLIER)
	jump_start = Unit.global_position
	jump_end = onCalculateEndPosition(Tile)
	is_jump = true
	AniPlayer.speed_scale = 2.0 / JUMP_TIME
	jump_time = 0
	on_play_animation("Jump")
	
	get_tree().create_timer((3 / AniPlayer.speed_scale) / 1.5).timeout\
	.connect(func(): unit_fell.emit(dmg, (3 / AniPlayer.speed_scale) / 6))
	
func onCreateMoveTween(Tile: TileGD) -> void:
	var MoveTween: Tween = create_tween()
	var half_position := Vector3(Tile.global_position + global_position) * 0.5
	var climb_slope: float = 0.9 if Tile.tile.type == 1 else (1.5 if (Tile.tile.type == 2 and Tile.w != Unit.Tile.w) else 0.3)
	var water_deslope: float = 0.1 if Tile.isWater() else 0.0
	MoveTween.tween_property(Unit, "global_position",
	Vector3(half_position.x, Tile.global_position.y + climb_slope - water_deslope, half_position.z),
	WALK_TRAVEL_TIME * 0.5)
	MoveTween.finished.connect(onCreateSecondMoveTween.bind(Tile))
	
func onCreateSecondMoveTween(Tile: TileGD) -> void:
	var end_position: Vector3 = onCalculateEndPosition(Tile)
	var MoveTween: Tween = create_tween()
	MoveTween.tween_property(Unit, "global_position",
	end_position,
	WALK_TRAVEL_TIME * 0.5)
	MoveTween.finished.connect(onAnimationFinished.bind("Walk"))

func _look_at(Tile: TileGD) -> void: #will rotate the object
	rot = Unit.Units.Tiles.neighbour_rotation(Tile, Unit.Tile)
	on_set_rotation()

func _look_at_body(Tile: TileGD) -> void:
	rot = Unit.Units.Tiles.neighbour_rotation(Tile, Unit.Tile)
	onSetCollisionRotation()

func on_death() -> void:
	on_play_animation(death)
	AudioMaster.play_sfx(Unit.AudioDict.DEATH)

func on_hurt() -> void:
	if AniPlayer.has_animation("Hurt"):
		on_play_animation("Hurt")
		AudioMaster.play_sfx(Unit.AudioDict.HURT)

func onGetAdjustedPoints() -> PackedVector3Array:
	return Array(collision_points)\
	.map(getRotationPoint.bind(deg_to_rad(-rotation_degrees.y), global_position))\
	as PackedVector3Array

func on_set_rotation() -> void:
	rotation_degrees.y = 270 + (rot * 60)
	Unit.VFX.setUnitVFXRot(Unit)
	
func setCustomRotation(radians: float) -> void:
	rotation.y = radians
	Unit.VFX.setUnitVFXRot(Unit)
	
func onSetCollisionRotation() -> void:
	static_body.global_rotation_degrees.y = 270 + (rot * 60)
	
func getRotationPoint(xyz: Vector3, r: float, pos: Vector3) -> Vector3:
	return Vector3(xyz.x * (cos(r)) - xyz.z * (sin(r)), xyz.y, xyz.z * (cos(r)) + xyz.x * (sin(r))) + pos

func setVisible(state: bool) -> void:
	mesh.visible = state
	Unit.UnitVFX.visible = state
	Unit.StatusManager.setUnitStatusVisible(Unit, state)
	Unit.setVisibleState(state)
	onSetShaderParameter(0)
	

var idle_array: Array = ["Idle", "IdleAbility", "IdleRare"]
func onActivateIdleAbility() -> void:
	if idle != "IdleAbility" and AniPlayer.has_animation("IdleAbility"):
		idle = "IdleAbility"
		if AniPlayer.current_animation in idle_array:
			on_play_animation(idle)

func onRemoveIdleAbility() -> void:
	if idle != "Idle":
		idle = "Idle"
		if AniPlayer.current_animation in idle_array:
			on_play_animation(idle)

func setRedMultiply(state: bool) -> void:
	var val: float = DEFAULT_MULT_VALUE if (!state) else 15.0
	for mat in materials: mat.next_pass.set_shader_parameter("red_multiply", val)

func onVFXAnimation(ani: Animation) -> void:
	var lib: AnimationLibrary = AniPlayer.get_animation_library("")
	var ani_name: String = ani.resource_name
	lib.add_animation(ani_name, ani)
		
	on_play_animation(ani_name)
	is_vfx_ani_playing = true
	await AniPlayer.animation_finished
	onVFXAnimationFinished(ani)
	
func onVFXAnimationFinished(ani: Animation) -> void:
	is_vfx_ani_playing = false
	var lib: AnimationLibrary = AniPlayer.get_animation_library("")
	AniPlayer.current_animation = ""
	lib.remove_animation(ani.resource_name)
	on_play_animation("Idle")
	
