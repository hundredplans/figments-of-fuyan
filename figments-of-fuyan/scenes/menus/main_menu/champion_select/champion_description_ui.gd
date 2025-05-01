extends Control

signal start
signal cancel

#region Globals
@onready var CardSpot: Control = %CardSpot
@onready var ChampionNameLabel: Label = %ChampionNameLabel
@onready var ChampionEpithetLabel: Label = %ChampionEpithetLabel
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var DescriptionContainer: VBoxContainer = %DescriptionContainer
@onready var ChampionBoonLabel: FancyTextLabel = %ChampionBoonLabel
@onready var UltimateLabel: Label = %UltimateLabel
@onready var FlavorLabel: Label = %FlavorLabel
#endregion
func setInfo(Card: CardGD) -> void:
	var area: AreaInfo = Card.getArea()
	ChampionNameLabel.text = Card.info.name
	CardSpot.get_child(0).queue_free()
	Card.onCreateCardUI(CardSpot).set_anchors_preset(PRESET_CENTER)
	AreaNameLabel.text = area.name
	ChampionEpithetLabel.text = Card.info.epithet
	
	for child in DescriptionContainer.get_children(): DescriptionContainer.remove_child(child); child.queue_free()
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	DescriptionContainer.add_child(spacer)
	
	for description_text in Card.info.champion_description:
		var label := Label.new()
		label.text = "- " + description_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		DescriptionContainer.add_child(label)
		
	var end_spacer := Control.new()
	end_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	DescriptionContainer.add_child(end_spacer)
	
	ChampionBoonLabel.setText(Card.info.boon_info.description)
	UltimateLabel.text = Card.info.ultimate_description
	FlavorLabel.text = "\"" + Card.info.flavor_text + "\" "

func _on_cancel_button_pressed() -> void:
	queue_free()
	cancel.emit()

func _on_start_button_pressed() -> void:
	start.emit()
