class_name EncounterGD extends FofGD

var ability_save: Dictionary
var loaded_page_name: String
signal temp_disable_options
signal continue_to_next_page
signal load_level

func onFirstEntered(_screen: Control) -> void: # Equivalent to fof init but with some args
	pass
	
func onEntered(_screen: Control) -> void: # Equivalent to load data but with info
	pass
	
func onSave() -> SavedDataEncounter:
	return SavedDataEncounter.new(info.id, true, public_id, ability_save, loaded_page_name)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	ability_save = data.ability_save
	loaded_page_name = data.loaded_page_name
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
func anyRequirementMet() -> bool:
	var start_page: EncounterPageDatastore = info.pages.filter(func(x: EncounterPageDatastore): return x.title == "StartPage")[0]
	var options: Array = start_page.options.filter(func(x: EncounterOptionDatastore): return !x.requirement.is_empty())
	return options.is_empty() or options.any(isRequirementMet)
	
func allRequirementMet() -> bool:
	var start_page: EncounterPageDatastore = info.pages.filter(func(x: EncounterPageDatastore): return x.title == "StartPage")[0]
	var options: Array = start_page.options.filter(func(x: EncounterOptionDatastore): return !x.requirement.is_empty())
	return options.is_empty() or options.all(isRequirementMet)

func onOptionPressed(_option: EncounterOptionDatastore, _screen: Control) -> void:
	pass
	
func isRequirementMet(_option: EncounterOptionDatastore) -> bool:
	return true

func onContinueToNextPage(option: EncounterOptionDatastore) -> void:
	continue_to_next_page.emit(option.page_title)
	loaded_page_name = option.page_title
	
func onContinueToNextPageForce(page_title: String) -> void:
	continue_to_next_page.emit(page_title)
	loaded_page_name = page_title
	
func getPageByTitle(title: String) -> EncounterPageDatastore:
	for page in info.pages:
		if page.title == title: return page
	assert(false) # Page non existant
	return null
