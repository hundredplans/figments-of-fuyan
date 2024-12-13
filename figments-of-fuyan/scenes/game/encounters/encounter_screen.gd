extends MapNodeScreen

@export var exit_option: EncounterOptionDatastore
@export var EncounterOptionButtonUIPacked: PackedScene

@onready var NameLabel: Label = %NameLabel
@onready var DescriptionLabel: Label = %DescriptionLabel
@onready var OptionsContainer: Container = %OptionsContainer

var encounter: EncounterGD

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, map_node: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, map_node)
	encounter = map_node.encounter
	encounter.continue_to_next_page.connect(onContinueToNextPage)
	encounter.temp_disable_options.connect(onTempDisableOptions)
	NameLabel.text = encounter.info.name
	onLoadPage(encounter.loaded_page_name)

func onLoadPage(page_title: String) -> void:
	for child in OptionsContainer.get_children(): child.queue_free()
	var page: EncounterPageDatastore = encounter.getPageByTitle(page_title)
	DescriptionLabel.text = page.description
	
	var options: Array = page.options
	if options.is_empty(): options = [exit_option]
	
	for option in options:
		var encounter_option_ui: Control = EncounterOptionButtonUIPacked.instantiate()
		OptionsContainer.add_child(encounter_option_ui)
		var is_requirement_met: bool = encounter.isRequirementMet(option)
		encounter_option_ui.setInfo(option, is_requirement_met)
		encounter_option_ui.pressed.connect(onOptionPressed)
		
func onOptionPressed(option: EncounterOptionDatastore) -> void:
	encounter.onOptionPressed(option, self)
	
func onContinueToNextPage(page_title: String) -> void:
	if page_title == "Exit": finished.emit(); queue_free(); return
	onLoadPage(page_title)
	
func onDimBackground() -> bool:
	return true
	
func onTempDisableOptions(state: bool) -> void:
	for OptionUI in OptionsContainer.get_children():
		OptionUI.setDisabled(state)
