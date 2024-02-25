extends Node3D

@onready var Unit: UnitGD = get_parent()
var UnitModel: Node3D
var AniPlayer: AnimationPlayer
signal movement_finished
signal attack_finished
signal death_finished
signal drop_calculate_damage
var rot: int

func on_add_model() -> void:
	var model_path: String = "res://assets/base_game/cards/card_ui/default_model.glb"
	var card_model_path: String = "res://assets/base_game/cards/" + Unit.base_card.bgfn + "/model.glb"
	if FileAccess.file_exists(card_model_path):
		model_path = card_model_path
		
	UnitModel = load(model_path).instantiate()
	AniPlayer = UnitModel.get_node("AnimationPlayer")
	AniPlayer.animation_finished.connect(on_finish_animation)
	on_play_animation("Idle")
	add_child(UnitModel)
	
	rot = (rot + 2) % 6
	on_set_rotation()

func on_play_animation(ani_name: String) -> void:
	AniPlayer.play(ani_name, Unit.Units.UNIT_ANIMATION_BLEND_TIME)
	if ani_name == "Walk": on_play_walk_sfx()
	
var current_walk_stream_player: AudioStreamPlayer
func on_play_walk_sfx() -> void:
	var sfx: String = on_find_walk_sfx(Unit.Tile.info.tile.id)
	var is_null: bool = current_walk_stream_player == null 
	if is_null or sfx != current_walk_stream_player.playing_sfx:
		if !is_null: AudioMaster.on_cutoff_sfx(current_walk_stream_player)
		current_walk_stream_player = AudioMaster.play_sfx(sfx)
	
func on_find_walk_sfx(id: int) -> String:
	var sfx: String
	match id:
		1: sfx = Helper.area_to_default_ground[Unit.Units.GameState.area_info.id]
		3,4: sfx = "water_walk"
	return sfx
	
func on_finish_animation(ani_name: String) -> void:
	AniPlayer.speed_scale = 1
	match ani_name:
		"Walk": movement_finished.emit()
		"Attack": attack_finished.emit()
		"Death": death_finished.emit()
		"Jump": movement_finished.emit(); is_jump = false; jump_time = 0
		
	if ani_name != "Walk" and ani_name != "Death" and ani_name != "Jump": on_play_animation("Idle")

var walk_to_info: Array = []
func move_to_tile(Tile: TileGD, type: Vector2i) -> void:
	walk_to_info = [Tile, type]
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
	match walk_to_info[1].x:
		3: on_create_regular_jump(walk_to_info[0])
		4: on_create_drop_jump(walk_to_info[0], walk_to_info[1].y)
		_: on_create_move_tween(walk_to_info[0], walk_to_info[1])
	walk_to_info = []
		
var is_jump: bool = false
func on_create_regular_jump(Tile: TileGD) -> void:
	JUMP_TIME = 1
	JUMP_HEIGHT = -4
	jump_start = Unit.global_position
	jump_end = Vector3(Tile.global_position.x, Tile.global_position.y + (0.75 if Tile.info.tile.type == 1 else 0.3), Tile.global_position.z)
	is_jump = true
	AniPlayer.speed_scale = 2
	
	on_play_animation("Jump")
	
const JUMP_HEIGHT_MULTIPLIER: float = 1.5
func on_create_drop_jump(Tile: TileGD, hdiff: int) -> void:
	JUMP_TIME = 1 - (hdiff * 0.1)
	JUMP_HEIGHT = -3 + (hdiff * JUMP_HEIGHT_MULTIPLIER)
	jump_start = Unit.global_position
	jump_end = Vector3(Tile.global_position.x, Tile.global_position.y + (0.75 if Tile.info.tile.type == 1 else 0.3), Tile.global_position.z)
	is_jump = true
	AniPlayer.speed_scale = 2.0 / JUMP_TIME
	on_play_animation("Jump")
	
	get_tree().create_timer((3 / AniPlayer.speed_scale) / 1.5).timeout\
	.connect(func(): drop_calculate_damage.emit(hdiff, (3 / AniPlayer.speed_scale) / 6))
		
func on_create_move_tween(Tile: TileGD, type: Vector2i) -> void:
	var MoveTween: Tween = get_tree().create_tween()
	var half_position := Vector3(Tile.global_position + global_position) * 0.5
	var climb_slope: float = 0.75 if Tile.info.tile.type == 1 else 0.3
	if type.x == 2 and type.y == -1: climb_slope = 1.5
		
	MoveTween.tween_property(Unit, "global_position",
	Vector3(half_position.x, Tile.global_position.y + climb_slope, half_position.z),
	Unit.Units.WALK_TRAVEL_TIME * 0.5)
	
	MoveTween.finished.connect(on_create_second_move_tween.bind(Tile, type))
func on_create_second_move_tween(Tile: TileGD, type: Vector2i) -> void:
	var MoveTween: Tween = get_tree().create_tween()
	var climb_slope: float = 0.75 if Tile.info.tile.type == 1 else 0.3
	if type.x == 2: climb_slope = 0.9
	
	MoveTween.tween_property(Unit, "global_position",
	Vector3(Tile.global_position.x, Tile.global_position.y + climb_slope, Tile.global_position.z),
	Unit.Units.WALK_TRAVEL_TIME * 0.5)
	MoveTween.finished.connect(on_finish_animation.bind("Walk"))
func _look_at(Tile: TileGD) -> void: #will rotate the object
	rot = Unit.Units.Tiles.neighbour_rotation(Tile, Unit.Tile)
	on_set_rotation()

func on_death() -> void:
	on_play_animation("Death")

func on_set_rotation() -> void:
	rotation_degrees.y = 270 + (rot * 60)
