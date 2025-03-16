extends Control

@export var FofUIBoxPacked: PackedScene
@onready var FofUIControl: Control = %FofUIControl
@onready var BossNameLabel: Label = %BossNameLabel

func setInfo(map_node_data: SavedDataEpicFight) -> void:
	var FofUIBox: Control = FofUIBoxPacked.instantiate()
	FofUIControl.add_child(FofUIBox)
	
	var boss_data := SavedDataBossCard.new(map_node_data.boss_id)
	FofUIBox.setInfo(boss_data)
	FofUIBox.scale = Vector2(2, 2)
	
	var boss_info: EpicCardInfo = Helper.getFofInfoID(EpicCardInfo, boss_data.id)
	BossNameLabel.text = boss_info.name
	
	var theme_path: String = ""
	if map_node_data is SavedDataMiniBossFight:
		theme_path = "PurplePanelContainer"
		BossNameLabel.modulate = Game.getRarityColor(Game.Rarities.MINIBOSS)
	elif map_node_data is SavedDataBossFight:
		theme_path = "RedPanelContainer"
		BossNameLabel.modulate = Game.getRarityColor(Game.Rarities.BOSS)
	
	theme_type_variation = theme_path
	setMouseCenter(get_viewport().get_mouse_position())

func _process(_delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: queue_free()

func setMouseCenter(mouse_position: Vector2) -> void:
	global_position = mouse_position - (size / 2) - Vector2(0, 120)
	global_position.x = clamp(global_position.x, 0, get_viewport().size.x - size.x - 10)
	global_position.y = clamp(global_position.y, 0, get_viewport().size.y - size.y - 10)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		setMouseCenter(get_viewport().get_mouse_position())
