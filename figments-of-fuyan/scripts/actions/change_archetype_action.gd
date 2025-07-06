class_name ChangeArchetypeAction extends Action

var Card: CardGD
var archetype_info: ArchetypeInfo

func _init(_Card: CardGD = null, _archetype_info: ArchetypeInfo = null) -> void:
	super()
	Card = _Card
	archetype_info = _archetype_info
	
func onPreAction() -> void:
	if Card.getActiveArchetype() == archetype_info: onFailAction(); return
	
func onPostAction() -> void:
	Card.setActiveArchetype(archetype_info)
