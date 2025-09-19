class_name AddFieldEffectAction extends Action

var FieldEffect: FieldEffectGD
var FieldEffectOwner: FofGD

func _init(_FieldEffect: FieldEffectGD = null, _FieldEffectOwner: FofGD = null) -> void:
	super()
	FieldEffect = _FieldEffect
	FieldEffectOwner = _FieldEffectOwner
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	FieldEffect.FofObject = FieldEffectOwner
	FieldEffect.Card.onAddFieldEffect(FieldEffect)
	FieldEffect.onFieldEffectAdded()
	
func getLogInfo() -> Array:
	return ["FieldEffect: " + FieldEffect.info.name]

func getCard() -> CardGD:
	if FieldEffect == null: return null
	return FieldEffect.Card
	
func getFieldEffectId() -> int:
	if FieldEffect == null: return -1
	return FieldEffect.info.id

func getGameEffect() -> GameEffectGD: return FieldEffect
