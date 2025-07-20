extends MapNodeGD

var encounter: EncounterGD
var encounter_data: SavedDataEncounter


#region Load / Save
func onLoadData(data: SavedData) -> void:
	super(data)
	encounter_data = data.encounter_data
	
func onSave() -> SavedDataMapNode:
	if encounter_data == null and encounter != null: encounter_data = encounter.onSave()
	return SavedDataEncounterNode.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, encounter_data)
#endregion

#region Enteringe
func onEntered() -> void:
	super()
	
	if is_finished: return
	
	var screen: Control = info.screen.instantiate()
	screen.finished.connect(onFinished)
	
	if encounter_data == null: # If first time entering
		if Helper.admin_datastore.force_encounter_id == 0: encounter = onGenerateEncounter()
		else: # Admin command to change encounter to specific id for testing
			encounter = SavedData.onLoadModel(SavedDataEncounter.new(Helper.admin_datastore.force_encounter_id, true), self)
		encounter.onFirstEntered(screen)
	else: encounter = SavedData.onLoadModel(encounter_data, self)
	
	create_screen.emit(self, screen) # Important order
	
	encounter.load_level.connect(onLoadLevel)
	encounter.onEntered(screen)
	
	encounter_data = null
	if encounter == null: # Means a fight encounter was created or there's none available
		onFinished()
		return
	
func onGenerateEncounter() -> EncounterGD:
	var encounter_count: int = Game.save_file.getSafeEncounterCount()
	var fight_roll: bool = Random.rollFloat(Game.area.getWorld().ENCOUNTER_COUNT_FIGHT_ODDS[str(encounter_count)])
	if fight_roll:
		Game.save_file.onUpdateSafeEncounterCount(-encounter_count)
		return onCreateFightEncounter()
		
	var encounter_infos: Array = Helper.getFofInfoArray(EncounterInfo).filter(\
		func(x: EncounterInfo): return (x.id not in Game.area.encountered_encounter_ids and x.id in Game.area.info.encounter_ids) or x.is_global)
	
	return onCreateEncounterThatCanShowUp(encounter_infos)

func onCreateEncounterThatCanShowUp(encounter_infos: Array) -> EncounterGD:
	if !encounter_infos.is_empty():
		var encounter_info: EncounterInfo = getRandomEncounterInfo(encounter_infos)
		encounter_infos.pick_random()
		encounter_infos.erase(encounter_info)
		
		encounter = SavedData.onLoadModel(encounter_info.saved_data.new(encounter_info.id, true), Game.area)
		
		if !encounter.canShowUp():
			encounter.queue_free()
			return onCreateEncounterThatCanShowUp(encounter_infos)
			
		Game.area.onAppendToEncouteredEncounterIds(encounter.info.id)
		Game.save_file.onUpdateSafeEncounterCount(-Game.save_file.getSafeEncounterCount() if encounter_info.id == 7 else 1) # Mirror dimension
		
		return encounter
	#assert(false) # No valid encounters found
	onFinished()
	return null
	
func onCreateFightEncounter() -> EncounterGD:
	return SavedData.onLoadModel(SavedDataEncounter.new(8, true), Game.area)
	
func getRandomEncounterInfo(encounters: Array) -> EncounterInfo: # Divinus not on holy path more likely to be negative
	return encounters.pick_random()
	
#endregion

#region Finishing
func onFinished() -> void:
	super()
	if encounter != null: encounter.queue_free(); encounter_data = null
#endregion	

#region Level
func onLoadLevel(level_data: SavedDataLevel) -> void:
	onFinished()
	load_level.emit(level_data)
#endregion
