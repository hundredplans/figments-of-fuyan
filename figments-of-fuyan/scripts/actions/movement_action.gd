class_name MovementAction extends Action

var Card: CardGD
var movement_path: Array
var destroy_on_occupy: bool

var kill_rolled: bool

func _init(_Card: CardGD = null, _movement_path: Array = [], _destroy_on_occupy: bool = false) -> void:
	super()
	Card = _Card
	movement_path = _movement_path
	destroy_on_occupy = _destroy_on_occupy
	
func setKillRolled(state: bool) -> void:
	kill_rolled = state

func onPreAction() -> void:
	onCheckFail()

func onPostAction() -> void:
	Card.Tile.is_card_moving = true
	Card.Tile.setOutlineMaterial()
	
	var actions: Array = [CameraChangeAction.new(Card)]
	if Card.turn_state == Game.TurnStates.INACTIVE:
		actions.append(ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE))
	
	var ally_cards: Array = Game.getAllyUnits(Card.team)
	for ally_card in ally_cards.filter(func(x: CardGD): return x.turn_state == Game.TurnStates.ACTIVE and x != Card):
		actions.append(ChangeTurnStateAction.new(ally_card, Game.TurnStates.PASSED))
	
	if !movement_path.is_empty():
		for i in range(1, movement_path.size()):
			var MoveToTile: TileGD = movement_path[i]
			
			var Attackables: Array = []
			match MoveToTile.occupy_state:
				TileGD.OccupyStates.NULL: pass
				TileGD.OccupyStates.ATTACKABLE_IOBJECT: Attackables = MoveToTile.getAttackableIObjects()
				_: Attackables.append(Game.getFieldCard(MoveToTile))
			
			if Attackables.is_empty() or destroy_on_occupy:
				MoveToTile.is_card_moving = true
				actions.append(MoveToTileAction.new(Card, MoveToTile, destroy_on_occupy))
				continue
			actions.append(AttackAction.new(Card, Attackables))
			break
		
	var movement_finish_action := MovementFinishAction.new(Card, movement_path)
	movement_finish_action.setKillRolled(kill_rolled)
	actions.append(movement_finish_action)
	#onAppendAction(actions)
	onPushAction(actions)

func onCheckFail() -> void:
	if Card.is_knockback: return
	var is_attackable_on_path: bool = movement_path.any(func(x: TileGD): return x != Card.Tile and x.occupy_state != TileGD.OccupyStates.NULL)
	if !Card.canAttack() and is_attackable_on_path: onFailAction()

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
