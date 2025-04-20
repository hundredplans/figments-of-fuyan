class_name LevelRewards extends Resource

@export var card_datas: Array
@export var chief_data: SavedDataCard

func _init(_card_datas: Array = [], _chief_data: SavedDataCard = null) -> void:
	card_datas = _card_datas
	chief_data = _chief_data

func setCardDatas(_card_datas: Array = []) -> void:
	card_datas = _card_datas
	
func getCardDatas() -> Array:
	return card_datas
	
func setChiefData(_chief_data: SavedDataCard) -> void:
	chief_data = _chief_data
	
func getChiefData() -> SavedDataCard:
	return chief_data
