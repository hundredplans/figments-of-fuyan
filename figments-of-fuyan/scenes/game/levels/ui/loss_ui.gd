extends Control

signal mouse_in_ui
signal exit

func _on_loss_button_pressed() -> void:
	Game.save_file.onGameLost()
	exit.emit()
	
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)

@onready var ArtMiniRect: TextureRect = %ArtMiniRect
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var TimeLabel: Label = %TimeLabel
@onready var ShillingLabel: FancyTextLabel = %ShillingLabel

@onready var AreaLabel: Label = %AreaLabel
@onready var LevelLabel: Label = %LevelLabel
@onready var LocationLabel: Label = %LocationLabel

@onready var BoonContainer: GridContainer = %BoonContainer
@onready var CardContainer: GridContainer = %CardContainer

@export var FofUIBoxPacked: PackedScene

func _ready() -> void:
	var save_file_data: SavedDataSaveFile = Game.getSaveFile().onSave()
	
	var champion_data: SavedDataCard = save_file_data.getChampionData()
	var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, champion_data.id)
	
	ArtMiniRect.texture = champion_info.getArtMini()
	ChampionNameLabel.text = champion_info.name
	
	var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(save_file_data.time)
	for key in ["hour", "minute", "second"]:
		datetime[key] = str(datetime[key]) if datetime[key] > 10 else "0" + str(datetime[key])
	
	TimeLabel.text = "TIME: " + datetime.hour + ":" + datetime.minute + ":" + datetime.second
	ShillingLabel.setText("SH: " + str(save_file_data.shillings))
	
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, save_file_data.area_data.id)
	AreaLabel.text = "AREA: " + area_info.name
	
	LevelLabel.text = "LEVEL: " + (area_info.overworld_decoration.name\
	if save_file_data.area_data.level_data == null else \
	Helper.getFofInfoID(LevelInfo, save_file_data.area_data.level_data.id).name)
	LocationLabel.text = "LOCATION: " + str(area_info.world.world) + "-" + str(clamp(save_file_data.area_data.getEnteredMapLocationProgress(), 0, 10))
	
	for card_data in save_file_data.deck:
		var FofUIBox: Control = FofUIBoxPacked.instantiate()
		CardContainer.add_child(FofUIBox)
		FofUIBox.setInfo(card_data, true)
	
	for boon_data in save_file_data.boons:
		var FofUIBox: Control = FofUIBoxPacked.instantiate()
		BoonContainer.add_child(FofUIBox)
		FofUIBox.setInfo(boon_data)
