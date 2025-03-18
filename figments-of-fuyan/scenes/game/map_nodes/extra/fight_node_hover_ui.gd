extends Control

@export var UIBoxPacked: PackedScene
@onready var LevelLabel: Label = %LevelLabel
@onready var UIBoxParent: Control = %UIBoxParent

const CHIEF_UI_BOX_SEPERATION: int = 30

func _process(_delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: queue_free()

func setInfo(map_node_data: SavedDataFight) -> void:
	var area: AreaGD = Game.getArea()
	if area.getProgress() < 5 and map_node_data.map_location.progress > 5: queue_free(); return
	
	var level_info: LevelInfo = Helper.getFofInfoID(LevelInfo, map_node_data.level_info.id)
	
	LevelLabel.text = str(area.getWorldDifficulty()) + "-" + str(clamp(map_node_data.map_location.progress, 0, 10)) + ": " + str(level_info.name)
	
	var enemy_cards: Array = map_node_data.enemy_cards.duplicate()
	
	var chief_data: SavedDataCard
	if map_node_data is SavedDataEliteFight:
		chief_data = enemy_cards.pop_back()
		
	var reward_amount: int = Game.CARD_REWARD_DEFAULT_AMOUNT
	enemy_cards.resize(reward_amount)
	enemy_cards = enemy_cards.filter(func(x: SavedDataCard): return x != null)
	
	var valid_infos: Dictionary = {}
	for saved_data_card: SavedDataCard in enemy_cards:
		valid_infos[saved_data_card] = Helper.getFofInfoID(CardInfo, saved_data_card.id)
	
	enemy_cards.sort_custom(func(x: SavedDataCard, y: SavedDataCard): return valid_infos[x].rarity > valid_infos[y].rarity)
	enemy_cards.sort_custom(func(x: SavedDataCard, y: SavedDataCard): return valid_infos[x].energy > valid_infos[y].energy)
	
	for card_data in enemy_cards:
		onAddUIBox(card_data)
			
	if chief_data != null:
		var UIBox: Control = onAddUIBox(chief_data)
		var filler := Control.new()
		filler.custom_minimum_size.x = CHIEF_UI_BOX_SEPERATION
		UIBoxParent.add_child(filler)
		UIBoxParent.move_child(filler, 0)
		UIBoxParent.move_child(UIBox, 0)
			
	match map_node_data.get_script():
		SavedDataBossFight: theme_type_variation = "RedPanelContainer"
		SavedDataMiniBossFight: theme_type_variation = "PurplePanelContainer"
		SavedDataEliteFight: theme_type_variation = "DarkBrownPanelContainer"
		
	setMouseCenter(get_viewport().get_mouse_position())
	
func onAddUIBox(card_data: SavedDataCard) -> Control:
	var UIBox: Control = UIBoxPacked.instantiate()
	
	UIBoxParent.add_child(UIBox)
	UIBox.setInfo(card_data)
	return UIBox
	
func setMouseCenter(mouse_position: Vector2) -> void:
	global_position = mouse_position - (size / 2) - Vector2(0, 100)
	global_position.x = clamp(global_position.x, 0, get_viewport().size.x - size.x - 10)
	global_position.y = clamp(global_position.y, 0, get_viewport().size.y - size.y - 10)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		setMouseCenter(get_viewport().get_mouse_position())
