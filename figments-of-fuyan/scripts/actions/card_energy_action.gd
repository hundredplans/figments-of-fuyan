class_name CardEnergyAction extends Action

var Card: CardGD
var energy: int

func _init(_Card: CardGD = null, _energy: int = 0) -> void:
	super()
	Card = _Card
	energy = _energy
	
func onPreAction() -> void:
	if energy == 0: onFailAction()
	
func onPostAction() -> void:
	Card.energy += energy
	Card.update_stats.emit()
