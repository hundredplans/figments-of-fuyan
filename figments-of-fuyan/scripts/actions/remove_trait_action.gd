class_name RemoveTraitAction extends Action

var Card: CardGD
var id: int
var added_by: OverworldTrait.AddedBy

func _init(_Card: CardGD = null, _id: int = 0, _added_by := OverworldTrait.AddedBy.NULL) -> void:
	super()
	Card = _Card
	id = _id
	added_by = _added_by
	
func onPreAction() -> void:
	var overworld_trait: OverworldTrait = Card.getOverworldTraitByID(id)
	if overworld_trait == null or overworld_trait.added_by != added_by:
		onFailAction()
	
func onPostAction() -> void:
	Card.onRemoveFieldTrait(Card.getOverworldTraitByID(id))

func getDelay() -> float:
	return super()
