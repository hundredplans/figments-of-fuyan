extends VBoxContainer

@export var UnitStatusUIPacked: PackedScene
@export var SpectatedUnitStatusUI: Control
@export var AbilityBoxes: Control

var unit_status_uis: Array = []

func onCreateUnitStatusUI(Card: CardGD) -> void:
	var UnitStatusUI: Control = UnitStatusUIPacked.instantiate()
	add_child(UnitStatusUI)
	UnitStatusUI.setInfo(Card)
	unit_status_uis.append(UnitStatusUI)
	
func onUpdateSpectatedUnitStatusUI(SpectateObject: GameObjectGD) -> void:
	var PreviousCard: CardGD = SpectatedUnitStatusUI.getCard()
	if PreviousCard != null:
		var PreviousUnitStatusUI: Control = getUnitStatusUI(PreviousCard)
		if PreviousUnitStatusUI != null:
			PreviousUnitStatusUI.setSpectated(false)
	
	if SpectateObject == null or SpectateObject is SpawnGD:
		SpectatedUnitStatusUI.visible = false
		AbilityBoxes.visible = false
		return
		
	SpectatedUnitStatusUI.setInfo(SpectateObject)
	SpectatedUnitStatusUI.setSpectated(true)
	
	onUpdateAbilityBoxes(SpectateObject)
	
func onUpdateAbilityBoxes(Card: CardGD) -> void:
	pass

func getUnitStatusUI(Card: CardGD) -> Control:
	for UnitStatusUI: Control in unit_status_uis:
		if UnitStatusUI.getCard() == Card: return UnitStatusUI
	return null
