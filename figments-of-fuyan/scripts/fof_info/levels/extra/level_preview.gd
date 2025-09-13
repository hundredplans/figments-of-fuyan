class_name LevelPreview extends Resource

@export var card_datas: Array
@export var elite_exalt_id: int
@export var curse_id: int
@export var total_amount: int

func _init(_card_datas: Array = [], _total_amount: int = 0, _elite_exalt_id: int = 0, _curse_id: int = 0) -> void:
	card_datas = _card_datas
	total_amount = _total_amount
	elite_exalt_id = _elite_exalt_id
	curse_id = _curse_id

func setCardDatas(_card_datas: Array = []) -> void:
	card_datas = _card_datas
	
func getCardDatas() -> Array:
	return card_datas

func getTotalAmount() -> int:
	return total_amount

func getEliteExaltId() -> int:
	return elite_exalt_id
	
func getCurseId() -> int:
	return curse_id
	
func setEliteExaltId(_elite_exalt_id: int) -> void:
	elite_exalt_id = _elite_exalt_id
	
func setCurseId(_curse_id: int) -> void:
	curse_id = _curse_id
