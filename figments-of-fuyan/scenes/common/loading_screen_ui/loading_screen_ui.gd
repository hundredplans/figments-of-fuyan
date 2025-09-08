extends Control

@export_multiline var tips: Array[String]
@onready var MainLabel: Label = %MainLabel
@onready var CurseIcon: TextureRect = %CurseIcon
@onready var DescriptionLabel: FancyTextLabel = %DescriptionLabel
@onready var CurseNameLabel: Label = %CurseNameLabel
@onready var TipLabel: FancyTextLabel = %TipLabel

func setInfo(action: StartLoadingScreenAction) -> void:
	get_viewport().update_mouse_cursor_state()
	var loading_type: Game.LoadingType = action.getLoadingType()
	match loading_type:
		Game.LoadingType.LEVEL: setForLevel(action)
		Game.LoadingType.MAP: setForMap()
	TipLabel.setText(tips.pick_random())
	
func setForLevel(action: StartLoadingScreenAction) -> void:
	MainLabel.text = "%s-%s: %s" % [Game.getArea().getWorldDifficulty(), action.getProgress(), action.getLevelName()]
	MainLabel.modulate = Game.getArea().getAreaColor()
	
	var curse_id: int = action.getCurseID()
	if curse_id == 0: return
	var curse_info: BoonInfo = Helper.getFofInfoID(BoonInfo, curse_id)
	CurseNameLabel.text = curse_info.name
	CurseIcon.texture = curse_info.icon
	DescriptionLabel.setText(curse_info.getDescription(Game.getArea().getWorldDifficulty(), true))
	
func setForMap() -> void:
	MainLabel.text = "Travelling to map..."
	MainLabel.modulate = Game.getArea().getAreaColor()
