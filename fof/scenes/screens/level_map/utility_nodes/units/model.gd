extends Node3D

@onready var Unit: UnitGD = get_parent()
var UnitModel: Node3D
var AniPlayer: AnimationPlayer
signal movement_finished
signal attack_finished
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
	rotation_degrees.y = (rot * 60) + 30

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
	match ani_name:
		"Walk": movement_finished.emit()
		"Attack": attack_finished.emit()
		
	if ani_name != "Walk": on_play_animation("Idle")

func move_to_tile(Tile: TileGD) -> void:
	walk_to = Tile
	on_play_animation("Walk")
	
func attack_tile(Tile: TileGD) -> void:
	_look_at(Tile)
	on_play_animation("Attack")
	
var walk_to: TileGD
func _process(_delta: float) -> void:
	if walk_to != null:
		_look_at(walk_to)
		var MoveTween: Tween = get_tree().create_tween()
		MoveTween.tween_property(Unit, "global_position", 
		Vector3(walk_to.global_position.x, walk_to.global_position.y + 0.3, walk_to.global_position.z),
		Unit.Units.WALK_TRAVEL_TIME)
		
		MoveTween.finished.connect(on_finish_animation.bind("Walk"))
		walk_to = null

func _look_at(Tile: TileGD) -> void: #will rotate the object
	rot = Unit.Units.Tiles.neighbour_rotation(Tile, Unit.Tile)
	rotation_degrees.y = (rot * 60) - 30
