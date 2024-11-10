class_name Action extends Resource

signal push_action
signal append_action
signal force_action
signal remove_move_and_attack_actions

var owner: Variant # FofGD or another action always
@export var action_delay: float = 0
@export var owner_public_id: int
@export var failed: bool = false
@export var post: bool = false

func _init() -> void:
	push_action.connect(Game.ActionManagerReference.onPushAction)
	append_action.connect(Game.ActionManagerReference.onAppendAction)
	force_action.connect(Game.ActionManagerReference.onForceAction)
	remove_move_and_attack_actions.connect(Game.ActionManagerReference.onRemoveMoveAndAttackActions)
	Game.ActionManagerReference.process_action.connect(onProcessAction)

#region Fillers
func getDelay() -> float: return action_delay
func onPreAction() -> void: pass
func onPostAction() -> void: pass
func onProcessAction(_action: Action) -> void: pass
#endregion
	
func onPushAction(actions: Variant, action_owner: Variant = self) -> void:
	if actions is Action:
		actions = [actions]
		actions.reverse()
		
	for action in actions:
		action.owner = action_owner
		push_action.emit(action)
		
func onForceAction(action: Action) -> void:
	action.owner = self
	force_action.emit(action)
		
func onRemoveMoveAndAttackActions(Card: CardGD) -> void:
	remove_move_and_attack_actions.emit(Card)
	
func onAppendAction(actions: Variant, action_owner: Variant = self) -> void:
	if actions is Action: actions = [actions]
	
	for action in actions:
		action.owner = action_owner
		append_action.emit(action)
	
func onFailAction() -> void:
	failed = true

func onSave() -> void:
	owner_public_id = owner.public_id

func onLoad() -> void:
	owner = Game.onFindPublicIDObject(owner_public_id)
	
func setActionDelay(_action_delay: float) -> void:
	action_delay = _action_delay
	
func getLogInfo() -> Array:
	return []
