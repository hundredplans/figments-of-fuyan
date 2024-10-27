extends Control

signal start
signal cancel

#region Globals
@onready var CardSpot: Control = %CardSpot
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var ChampionEpithetLabel: Label = %ChampionEpithetLabel
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var DescriptionContainer: VBoxContainer = %DescriptionContainer
@onready var ChampionBoonTitleLabel: FancyTextLabel = %ChampionBoonTitleLabel
@onready var UltimateTitleLabel: FancyTextLabel = %UltimateTitleLabel
@onready var ChampionBoonLabel: FancyTextLabel = %ChampionBoonLabel
@onready var UltimateLabel: Label = %UltimateLabel
@onready var FlavorLabel: Label = %FlavorLabel

@onready var HideButtonLabelUlt: Label = %HideButtonLabelUlt
@onready var HideButtonLabelBoon: Label = %HideButtonLabelBoon
#endregion
func setInfo(Card: CardGD) -> void:
	var area: AreaInfo = Card.getArea()
	ChampionNameLabel.text = Card.info.name
	CardSpot.get_child(0).queue_free()
	Card.onCreateCardUI(CardSpot).set_anchors_preset(PRESET_CENTER)
	AreaNameLabel.text = area.name
	ChampionEpithetLabel.text = Card.info.epithet
	
	for child in DescriptionContainer.get_children(): DescriptionContainer.remove_child(child); child.queue_free()
	DescriptionContainer.add_child(Control.new())
	for description_text in Card.info.description:
		var label := Label.new()
		label.text = "- " + description_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		DescriptionContainer.add_child(label)
		
	ChampionBoonTitleLabel.setText("BOON: " + Card.info.boon_info.name)
	ChampionBoonLabel.setText(Card.info.boon_info.description)
	UltimateTitleLabel.setText("ULT: " + Card.info.ultimate_name)
	UltimateLabel.text = Card.info.ultimate_description
	FlavorLabel.text = "\"" + Card.info.flavor_text + "\" "

func _on_cancel_button_pressed() -> void:
	queue_free()
	cancel.emit()

func _on_start_button_pressed() -> void:
	start.emit()
