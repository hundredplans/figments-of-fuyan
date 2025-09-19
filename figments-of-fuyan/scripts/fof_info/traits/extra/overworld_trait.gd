class_name OverworldTrait extends Resource

enum AddedBy {NULL, REGULAR, CRAB, BUCKLER, ELDER_PALMER, LONE_RIDER, HAVEL_ROCKFOOT, JIBBEN,
	VAROMA_RACK, DOUBLE_GLAIVE}

@export var data: SavedDataTrait
@export var added_by: AddedBy
@export var level_trait_data: SavedDataTrait # Reload / save
@export var only_for_level: bool
var Trait: TraitGD

func getData() -> SavedDataTrait:
	return data

func _init(_data: SavedDataTrait = null, _added_by: AddedBy = AddedBy.NULL, _only_for_level: bool = false, turns: int = -1):
	data = _data
	added_by = _added_by
	only_for_level = _only_for_level
	data.turns = turns

func isUnregularAdded() -> bool:
	return !(added_by == AddedBy.REGULAR)

func onSave() -> void:
	if Trait != null:
		level_trait_data = Trait.onSave()
	
func onLoad(Card: CardGD) -> void:
	if level_trait_data == null: return
	SavedData.onLoadModel(level_trait_data, Card)
	
func onRemoveFieldTrait() -> void:
	level_trait_data = null
	
	if Trait == null: return
	Trait.onClear()
	Trait = null
	
func getAddedByString() -> String:
	match added_by:
		AddedBy.NULL: return "Null"
		AddedBy.REGULAR: return "Regular"
	return ""
	
func isActive() -> bool:
	return Trait != null
	
func onReset(Card: CardGD) -> void:
	if Trait != null and (only_for_level or Trait.getTurns() != -1): # If for level or turn based (so automatically for level)
		Trait.onPushAction(RemoveOverworldTraitAction.new(Card, data.id, added_by))
		
func onCardTurnPassed() -> void:
	if Trait == null: return
	Trait.onCardTurnPassed(added_by)
