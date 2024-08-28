extends Control

signal start
signal cancel

#region Globals
@onready var CardSpot: Control = %CardSpot
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var ChampionEpithetLabel: Label = %ChampionEpithetLabel
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var DescriptionContainer: VBoxContainer = %DescriptionContainer
@onready var ChampionBoonTitleLabel: Label = %ChampionBoonTitleLabel
@onready var UltimateTitleLabel: Label = %UltimateTitleLabel
@onready var ChampionBoonLabel: Label = %ChampionBoonLabel
@onready var UltimateLabel: Label = %UltimateLabel
@onready var FlavorLabel: Label = %FlavorLabel
#endregion
func setInfo(Unit: UnitGD) -> void:
	ChampionNameLabel.text = Unit.info.name
	CardSpot.get_child(0).queue_free()
	Unit.onCreateCardUI(CardSpot).set_anchors_preset(PRESET_CENTER)
	AreaNameLabel.text = Unit.getArea().name
	ChampionEpithetLabel.text = Unit.info.epithet
	
	for child in DescriptionContainer.get_children(): DescriptionContainer.remove_child(child); child.queue_free()
	DescriptionContainer.add_child(Control.new())
	for description_text in Unit.info.description:
		var label := Label.new()
		label.text = "- " + description_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		DescriptionContainer.add_child(label)
		
	ChampionBoonTitleLabel.text = Unit.info.boon_info.name
	ChampionBoonLabel.text = Unit.info.boon_info.description
	UltimateTitleLabel.text = Unit.info.ultimate_info.name
	UltimateLabel.text = Unit.info.ultimate_info.description
	FlavorLabel.text = "\"" + Unit.info.flavor_text + "\" "

func _on_cancel_button_pressed() -> void:
	queue_free()
	cancel.emit()

func _on_start_button_pressed() -> void:
	start.emit()
