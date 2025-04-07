class_name AwakenBossAction extends Action

var id: int
var Tile: TileGD
var boss_datastore: BossDatastore

func _init(_id: int = 0, _Tile: TileGD = null, _boss_datastore: BossDatastore = null) -> void:
	super()
	id = _id
	Tile = _Tile
	boss_datastore = _boss_datastore
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var info: EpicCardInfo = Helper.getFofInfoID(EpicCardInfo, id)
	var data := SavedDataEpicCard.new(id, true)
	data.attack = info.getAttack(boss_datastore.phase)
	data.health = info.getHealth(boss_datastore.phase)
	data.speed = info.getSpeed(boss_datastore.phase)
	
	data.max_health = data.health
	data.max_speed = data.speed
	
	data.boss_datastore = boss_datastore
	data.team = 1
	
	var BossCard: EpicCardGD = SavedData.onLoadModel(data, Game.getLevel())
	
	onForceAction(AwakenAction.new(BossCard, Tile))
	onForceAction(ChangeBossIntentAction.new(BossCard.getBossIntentByName()))
