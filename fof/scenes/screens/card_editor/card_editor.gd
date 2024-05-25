extends Control

var model_path: String
@onready var ModelArea: Control = %ModelArea
@onready var GameCard: GameCardGD
@onready var DisplayCard: Control = %DisplayCard
@onready var CardFileloader: Control = %CardFileloader

func _on_card_fileloader_game_card_pressed(__GameCard: GameCardGD):
	var _GameCard: GameCardGD = preload("res://assets/base_game/cards/game_card/game_card.tscn").instantiate()
	GameCard = _GameCard
	GameCard.set_info(__GameCard.base_card)
	DisplayCard.onDisplayCard(GameCard)
	
	ModelArea.onCreateModel(GameCard.base_card)
	model_path = ModelArea.model_path

@onready var CompileGameCardText: CompileGameCardTextGD = %CompileGameCardText
func _on_compile_button_pressed():
	CompileGameCardText.setBaseCardFromGameCard(GameCard)
	GameCard.setText(GameCard.base_card.text)
	CardFileloader.setGameCardText(GameCard.base_card)
	
func isMainScene() -> bool:
	return get_tree().get_root().get_children().any(func(x: Node): return x == self)

func _on_vision_button_pressed():
	if !model_path.is_empty():
		if !isMainScene():
			get_tree().get_root().get_node("Main/UI").visible = false
			get_tree().get_root().get_node("Main/World").visible = false
		else: visible = false
		var CreateModelBox: Node3D = preload("res://scenes/screens/card_editor/create_model_box.tscn").instantiate()
		CreateModelBox.path = model_path
		get_tree().get_root().add_child(CreateModelBox)
		CreateModelBox.escape.connect(onCreateModelBoxEscaped)

func onCreateModelBoxEscaped() -> void:
	if !isMainScene():
		get_tree().get_root().get_node("Main/UI").visible = true
		get_tree().get_root().get_node("Main/World").visible = true
	else: visible = true

func _on_save_button_pressed():
	if GameCard != null:
		GameCard.base_card.eye = float(ModelArea.EyeControl.HeightLabel.text)
		GameCard.base_card.top = float(ModelArea.TopControl.HeightLabel.text)
		GameCard.base_card.stat = float(ModelArea.StatControl.HeightLabel.text)
		ResourceSaver.save(GameCard.base_card)
