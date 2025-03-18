extends Node

@onready var BackgroundMap: Node3D = %BackgroundMap
@onready var World: Node3D = %World
@onready var AnimationNames: Container = %AnimationNames

const X_OFFSET: float = 3
const Z_OFFSET: float = 3
const X_STOP: int = 30
func _ready() -> void:
	var x: int
	var z: int
	var unique_animation_names: Dictionary = {}
	
	for card_info in Helper.getFofInfoArray(CardInfo):
		var card_data := SavedDataCard.new(card_info.id, true)
		Game.setCardDataFromInfo(card_data, card_info)
		var Card: CardGD = SavedData.onLoadModel(card_data, World)
		Card.onCreateModel()
		Card.getModel().rotation.y = 0
		
		if Card.AniPlayer != null:
			for animation_name in Card.AniPlayer.get_animation_list():
				unique_animation_names[animation_name] = null
		
		Card.position = Vector3(x, 0, z)
		
		x += X_OFFSET
		if x >= X_STOP:
			z += Z_OFFSET
			x = 0
	
	for ani_name in unique_animation_names.keys():
		var btn := Button.new()
		btn.text = ani_name
		btn.pressed.connect(onAnimationNamePressed.bind(ani_name))
		AnimationNames.add_child(btn)
		
func onAnimationNamePressed(ani_name: String) -> void:
	for Card: CardGD in get_tree().get_nodes_in_group("CardsGD"):
		if Card.AniPlayer != null and Card.AniPlayer.has_animation(ani_name):
			Card.AniPlayer.play(ani_name)
		
