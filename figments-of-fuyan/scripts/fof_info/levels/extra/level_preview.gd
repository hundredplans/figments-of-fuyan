class_name LevelPreview extends Resource

@export var card_datas: Array
@export var chief_data: SavedDataCard
@export var total_amount: int

func _init(_card_datas: Array = [], _chief_data: SavedDataCard = null) -> void:
	card_datas = _card_datas
	chief_data = _chief_data

func setCardDatas(_card_datas: Array = []) -> void:
	card_datas = _card_datas
	
func getCardDatas() -> Array:
	return card_datas
	
func setChiefData(_chief_data: SavedDataCard, add_to_total_amount: bool = false) -> void:
	chief_data = _chief_data
	if add_to_total_amount:
		setTotalAmount(total_amount + 1)
	
func getChiefData() -> SavedDataCard:
	return chief_data

func setTotalAmount(_total_amount: int) -> void:
	total_amount = _total_amount

func getTotalAmount() -> int:
	return total_amount
