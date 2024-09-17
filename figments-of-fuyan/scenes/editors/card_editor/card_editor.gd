extends Node

const START_X: int = -12
const OFFSET: int = 3
const CARD_UI_OFFSET := Vector2(-120, -400)
@onready var World: Node3D = %World
@onready var AnimationNames: Container = %AnimationNames
@onready var CardUIHolder: Control = %CardUIHolder
@onready var BackgroundMap: Node3D = %BackgroundMap
@onready var CardGrid: GridContainer = %CardGrid
@export var Background: DecorationDatastore

func _ready() -> void:
	var start_x: int = START_X
	var start_z: int = 0
	var unique_animation_names: Dictionary = {}
	
	for data in Background.data:
		SavedData.onLoadModel(data, BackgroundMap)
	
	for card_info in Helper.getFofInfoArray(CardInfo):
		var Card: CardGD = SavedData.onLoadModel(SavedDataCard.new(card_info.id), World)
		Card.onCreateModel()
		Card.onIdle()
		Card.onCreateCardUI(CardGrid)
		Card.mouse_entered.connect(onCreateCardUI)
		Card.mouse_exited.connect(onRemoveCardUI)
		
		for ani_name in Card.AniPlayer.get_animation_list():
			unique_animation_names[ani_name] = true
		
		Card.position = Vector3(start_x, 0, start_z)
		start_x += OFFSET
		if start_x == -START_X: start_z += OFFSET; start_x = START_X

	for animation_name in unique_animation_names:
		var btn := Button.new()
		AnimationNames.add_child(btn)
		btn.text = animation_name
		btn.pressed.connect(onAnimationNameButtonPressed.bind(animation_name))

func onAnimationNameButtonPressed(ani_name: String) -> void:
	for Card in get_tree().get_nodes_in_group("CardsGD"):
		if Card.AniPlayer.has_animation(ani_name): Card.AniPlayer.play(ani_name)

var CardUI: Control
func onCreateCardUI(Card: CardGD) -> void:
	CardUI = Card.onCreateCardUI(CardUIHolder)
	setCardUIPosition()
	
func onRemoveCardUI(_Card: CardGD) -> void:
	if CardUI != null: CardUI.queue_free()
	
func setCardUIPosition() -> void:
	CardUI.position = get_viewport().get_mouse_position() + CARD_UI_OFFSET
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and CardUI != null:
		setCardUIPosition()


func _on_hide_button_pressed() -> void:
	AnimationNames.visible = !AnimationNames.visible


func _on_ascend_button_pressed() -> void:
	for child in CardGrid.get_children(): child.queue_free()
	for Card in get_tree().get_nodes_in_group("CardsGD"):
		Card.ascended = !Card.ascended
		Card.setBaseStats()
		Card.onCreateCardUI(CardGrid)
