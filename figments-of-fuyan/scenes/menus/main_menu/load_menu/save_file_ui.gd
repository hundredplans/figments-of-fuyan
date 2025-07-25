extends DefaultButton
signal remove_save
signal save_file_pressed

@onready var ArtMiniRect: TextureRect = %ArtMiniRect
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var TimeLabel: Label = %TimeLabel
@onready var ShillingLabel: FancyTextLabel = %ShillingLabel
@onready var LocationLabel: Label = %LocationLabel

@onready var MainContainer: Container = %MainContainer
@onready var NewGameLabel: Label = %NewGameLabel

var save_file_data: SavedDataSaveFile
func setInfo(_save_file_data: SavedDataSaveFile) -> void:
	save_file_data = _save_file_data
	if save_file_data != null: setSaveFileData()
	else: setNewGameLabel()

func setSaveFileData() -> void:
	MainContainer.visible = true
	NewGameLabel.visible = false
	
	var champion_data: SavedDataCard = save_file_data.getChampionData()
	var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, champion_data.id)
	
	ArtMiniRect.texture = champion_info.getArtMini()
	ChampionNameLabel.text = champion_info.name

	var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(save_file_data.time)
	for key in ["hour", "minute", "second"]:
		datetime[key] = str(datetime[key]) if datetime[key] >= 10 else "0" + str(datetime[key])
		
	TimeLabel.text = "Time: " + datetime.hour + ":" + datetime.minute + ":" + datetime.second
	ShillingLabel.setText("SH: " + str(save_file_data.shillings))
	
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, save_file_data.area_data.id)
	var area_location: int = save_file_data.world_difficulty
	var level_location: int = clamp(save_file_data.area_data.getEnteredMapLocationProgress(), 0, 10)
	
	LocationLabel.text = area_info.name + " | " + str(area_location) + "-" + str(level_location)
	LocationLabel.modulate = area_info.area_color
	
func setNewGameLabel() -> void:
	MainContainer.visible = false
	NewGameLabel.visible = true

func onRemoveButtonPressed() -> void:
	remove_save.emit(save_file_data)
	MainContainer.visible = false
	NewGameLabel.visible = true
	save_file_data = null

func onPressed() -> void:
	super()
	save_file_pressed.emit(save_file_data)
