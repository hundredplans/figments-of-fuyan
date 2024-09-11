extends Control

@onready var ArtMiniRect: TextureRect = %ArtMiniRect
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var TimeLabel: Label = %TimeLabel
@onready var ShillingLabel: FancyTextLabel = %ShillingLabel

@onready var AreaLabel: Label = %AreaLabel
@onready var LevelLabel: Label = %LevelLabel
@onready var LocationLabel: Label = %LocationLabel

@onready var BoonContainer: GridContainer = %BoonContainer
@onready var CardContainer: GridContainer = %CardContainer

func _ready() -> void:
	
	var DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
	var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
	if !files.is_empty():
		var time_values: Array = files.map(func(x: String): return FileAccess.get_modified_time(DIR_PATH + "/" + x))
		
		var recent_save_file_path: String = files[time_values.find(time_values.max())]
		var save_file: SavedDataSaveFile = load(DIR_PATH + recent_save_file_path)
		
		var champion_data: SavedDataCard = save_file.getChampionData()
		var champion_info: ChampionCardInfo = Helper.getFofInfoID(ChampionCardInfo, champion_data.id)
		
		ArtMiniRect.texture = champion_info.getArtMini()
		ChampionNameLabel.text = champion_info.name
		
		print(save_file.time)
		var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(save_file.time)
		TimeLabel.text = "TIME: " + str(datetime.hour) + ":" + str(datetime.minute) + ":" + str(datetime.second)
		ShillingLabel.setText("SH: " + str(save_file.shillings))
		
		var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, save_file.area_data.id)
		AreaLabel.text = "AREA: " + area_info.name
		LevelLabel.text = "LEVEL: " + Helper.getFofInfoID(OverworldLevelInfo, save_file.area_data.overworld_level_id).name
		LocationLabel.text = "LOCATION: " + str(area_info.world.world) + ":" + str(max(save_file.area_data.map_location.progress, 0))
		
		for data in save_file.deck:
			var card_info: CardInfo = Helper.getFofInfoID(CardInfo, data.id)
			var tx_rect := TextureRect.new()
			var panel_container := PanelContainer.new()
			panel_container.theme_type_variation = "WhitePanelContainer"
			
			CardContainer.add_child(panel_container)
			
			tx_rect.texture = card_info.getArtMini()
			panel_container.add_child(tx_rect)
		
		
func _on_start_button_pressed() -> void:
	pass # Replace with function body.
