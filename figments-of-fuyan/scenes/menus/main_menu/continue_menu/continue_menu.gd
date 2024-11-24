extends Control

signal load_game
signal mouse_in_ui

@onready var ArtMiniRect: TextureRect = %ArtMiniRect
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var TimeLabel: Label = %TimeLabel
@onready var ShillingLabel: FancyTextLabel = %ShillingLabel

@onready var AreaLabel: Label = %AreaLabel
@onready var LevelLabel: Label = %LevelLabel
@onready var LocationLabel: Label = %LocationLabel

@onready var BoonContainer: GridContainer = %BoonContainer
@onready var CardContainer: GridContainer = %CardContainer

var save_file_data: SavedDataSaveFile
func _ready() -> void:
	var DIR_PATH: String = SaveFileInfo.SAVE_DIRECTORY
	var files: Array = Array(DirAccess.get_files_at(DIR_PATH))
	if !files.is_empty():
		var time_values: Array = files.map(func(x: String): return FileAccess.get_modified_time(DIR_PATH + "/" + x))
		
		var recent_save_file_path: String = files[time_values.find(time_values.max())]
		save_file_data = load(DIR_PATH + recent_save_file_path)
		
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
		LocationLabel.text = "LOCATION: " + str(area_info.world.world) + "-" + str(save_file_data.area_data.getEnteredMapLocationProgress())
		
		for data in save_file_data.deck:
			var card_info: CardInfo = Helper.getFofInfoID(CardInfo, data.id)
			var tx_rect := TextureRect.new()
			var panel_container := PanelContainer.new()
			panel_container.theme_type_variation = "WhitePanelContainer"
			
			CardContainer.add_child(panel_container)
			
			tx_rect.texture = card_info.getArtMini()
			panel_container.add_child(tx_rect)
		
		
func _on_start_button_pressed() -> void:
	load_game.emit(save_file_data)

func _on_quit_button_pressed() -> void:
	queue_free()
	
func onMouseInUI(state: bool) -> void:
	pass
