class_name BossIntentConditionResultRoyalBoon extends BossIntentConditionResult

@export var valid_ally_public_id: int

func setValidAllyPublicId(_public_id: int) -> void:
	valid_ally_public_id = _public_id

func getValidAllyPublicId() -> int:
	return valid_ally_public_id
	
func getValidAlly() -> CardGD:
	var Card: CardGD = Game.onFindPublicIDObject(valid_ally_public_id)
	if Card == null: return null
	return Card
