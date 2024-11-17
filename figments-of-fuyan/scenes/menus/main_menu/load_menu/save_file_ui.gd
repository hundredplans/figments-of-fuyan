extends Control
signal remove_save
signal start

@onready var ArtMiniRect: TextureRect = %ArtMiniRect
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var TimeLabel: Label = %TimeLabel
@onready var ShillingLabel: FancyTextLabel = %ShillingLabel

@onready var AreaLabel: Label = %AreaLabel
@onready var LevelLabel: Label = %LevelLabel
@onready var LocationLabel: Label = %LocationLabel

var save_file_data: SavedDataSaveFile
func setInfo(_save_file_data: SavedDataSaveFile) -> void:
	save_file_data = _save_file_data
	var champion_data: SavedDataCard = save_file_data.getChampionData()
	var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, champion_data.id)
	
	ArtMiniRect.texture = champion_info.getArtMini()
	ChampionNameLabel.text = champion_info.name

	var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(save_file_data.time)
	for key in ["hour", "minute", "second"]:
		datetime[key] = str(datetime[key]) if datetime[key] >= 10 else "0" + str(datetime[key])
		
	TimeLabel.text = "TIME: " + datetime.hour + ":" + datetime.minute + ":" + datetime.second
	ShillingLabel.setText("SH: " + str(save_file_data.shillings))
	
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, save_file_data.area_data.id)
	AreaLabel.text = "AREA: " + area_info.name
	LevelLabel.text = "LEVEL: " + (area_info.overworld_decoration.name\
	if save_file_data.area_data.level_data == null else \
	Helper.getFofInfoID(LevelInfo, save_file_data.area_data.level_data.id).name)
	LocationLabel.text = "LOCATION: " + str(area_info.world.world) + "-" + str(save_file_data.area_data.getEnteredMapLocationProgress())


func _on_remove_save_button_pressed() -> void:
	queue_free()
	remove_save.emit(save_file_data)

func _on_start_button_pressed() -> void:
	start.emit(save_file_data)
