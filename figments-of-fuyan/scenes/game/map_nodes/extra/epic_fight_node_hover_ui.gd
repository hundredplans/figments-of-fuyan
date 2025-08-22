extends HoverUI

@export var FofUIBoxPacked: PackedScene
@onready var FofUIControl: Control = %FofUIControl
@onready var BossNameLabel: Label = %BossNameLabel

func setInfo(map_node: MapNodeGD) -> void:
	var FofUIBox: Control = FofUIBoxPacked.instantiate()
	FofUIBox.disable_tooltip = true
	FofUIControl.add_child(FofUIBox)
	FofUIBox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if Game.getArea().getProgress() < 5 and map_node.map_location.progress > 5: queue_free(); return
	
	var boss_data := SavedDataEpicCard.new(map_node.boss_id)
	FofUIBox.setInfo(boss_data)
	FofUIBox.scale = Vector2(2, 2)
	
	var boss_info: EpicCardInfo = Helper.getFofInfoID(EpicCardInfo, boss_data.id)
	BossNameLabel.text = boss_info.name
	
	var theme_path: String = ""
	if map_node is MinibossFightNodeGD:
		theme_path = "PurplePanelContainer"
		BossNameLabel.modulate = Game.getRarityColor(Game.Rarities.MINIBOSS)
	elif map_node is BossFightNodeGD:
		theme_path = "RedPanelContainer"
		BossNameLabel.modulate = Game.getRarityColor(Game.Rarities.BOSS)
	
	theme_type_variation = theme_path
	setMouseCenter(get_viewport().get_mouse_position())
	
	
