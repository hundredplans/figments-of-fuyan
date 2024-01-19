extends Node3D

@onready var Unit: UnitGD = get_parent()
var UnitModel: Node3D
var AniPlayer: AnimationPlayer
# controls all stuff related to animation and maybe movement of character

func on_add_model() -> void:
	var model_path: String = "res://assets/base_game/cards/card_ui/default_model.glb"
	var card_model_path: String = "res://assets/base_game/cards/" + Unit.base_card.bgfn + "/model.glb"
	if FileAccess.file_exists(card_model_path):
		model_path = card_model_path
		
	UnitModel = load(model_path).instantiate()
	AniPlayer = UnitModel.get_node("AnimationPlayer")
	on_play_animation("Idle")
	add_child(UnitModel)

func on_play_animation(ani_name: String) -> void:
	AniPlayer.play(ani_name)
