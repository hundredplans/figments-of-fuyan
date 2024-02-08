extends Node3D

@onready var Unit: UnitGD = get_parent()
var UnitModel: Node3D
var AniPlayer: AnimationPlayer
signal movement_finished
# controls all stuff related to animation and maybe movement of character

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

func on_play_animation(ani_name: String) -> void:
	AniPlayer.play(ani_name, Unit.Units.UNIT_ANIMATION_BLEND_TIME)
	
func on_finish_animation(ani_name: String) -> void:
	if ani_name == "Walk":
		movement_finished.emit()
	else: on_play_animation("Idle")

func move_to_tile(Tile: TileGD) -> void:
	walk_to = Tile
	on_play_animation("Walk")
	
var walk_to: TileGD
func _process(_delta: float) -> void:
	if walk_to != null:
		Unit.look_at(walk_to.global_position, Vector3(0, 1, 0), true)
		var MoveTween: Tween = get_tree().create_tween()
		MoveTween.tween_property(Unit, "global_position", 
		Vector3(walk_to.global_position.x, walk_to.global_position.y + 0.3, walk_to.global_position.z),
		Unit.Units.WALK_TRAVEL_TIME)
		
		MoveTween.finished.connect(on_finish_animation.bind("Walk"))
		walk_to = null
