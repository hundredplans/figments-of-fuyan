class_name OverworldTrait extends Resource

enum AddedBy {NULL, REGULAR, ASCENDED, CRAB, BUCKLER, ELDER_PALMER, LONE_RIDER}

signal clear

@export var data: SavedDataTrait
@export var added_by: AddedBy
@export var level_trait_data: SavedDataTrait # Reload / save
@export var only_for_level: bool
@export var turns: int
var Trait: TraitGD

func getData() -> SavedDataTrait:
	return data

func _init(_data: SavedDataTrait = null, _added_by: AddedBy = AddedBy.NULL, _only_for_level: bool = false, _turns: int = -1):
	data = _data
	added_by = _added_by
	only_for_level = _only_for_level
	turns = _turns

func isUnregularAdded() -> bool:
	return !(added_by == AddedBy.REGULAR or added_by == AddedBy.ASCENDED)

func onSave() -> void:
	if Trait != null:
		level_trait_data = Trait.onSave()
	
func onLoad(Card: CardGD) -> void:
	if level_trait_data == null: return
	SavedData.onLoadModel(level_trait_data, Card)
	
func onRemoveFieldTrait() -> void:
	level_trait_data = null
	Trait.onClear()
	Trait = null
	
func getAddedByString() -> String:
	match added_by:
		AddedBy.NULL: return "Null"
		AddedBy.REGULAR: return "Regular"
		AddedBy.ASCENDED: return "Ascended"
	return ""
	
func isActive() -> bool:
	return Trait != null
	
func onReset() -> void:
	if Trait != null and (only_for_level or turns != -1): # If for level or turn based (so automatically for level)
		clear.emit()
		
func onCardTurnPassed() -> void:
	if turns == -1: return
	turns -= 1
	
	if turns == 0 and Trait != null:
		Trait.onPushAction(RemoveOverworldTraitAction.new(Trait.Card, Trait.info.id, added_by))
