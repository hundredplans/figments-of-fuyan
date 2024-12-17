class_name FofGD extends Node3D

signal clear
signal push_action
signal append_action
signal force_action
signal remove_move_and_attack_actions

var info: FofInfo
var groupsave: bool = true
var public_id: int

#region Save / Load
func onSave() -> SavedData: return SavedData.new(info.id, false, public_id)
func onLoadData(data: SavedData) -> void:
	add_to_group("FofGD")
	public_id = data.public_id
		
func onClear() -> void: queue_free(); clear.emit()

func onPushAction(actions: Variant, action_owner: Variant = self) -> void:
	if actions is Action:
		actions = [actions]
		actions.reverse()
		
	for action in actions:
		action.owner = action_owner
		push_action.emit(action)
	
func onAppendAction(actions: Variant, action_owner: Variant = self) -> void:
	if actions is Action: actions = [actions]
	
	for action in actions:
		action.owner = action_owner
		append_action.emit(action)
		
func onForceAction(action: Action) -> void:
	action.owner = self
	force_action.emit(action)

func onProcessAction(_action: Action) -> void: pass

func onRemoveMoveAndAttackActions(Card: CardGD) -> void:
	remove_move_and_attack_actions.emit(Card)
#endregion

func onLevelEnded(_win: bool) -> void: pass
