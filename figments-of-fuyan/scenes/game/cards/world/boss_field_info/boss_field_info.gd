extends Node3D

@onready var BossIntentSprite: Sprite3D = %BossIntentSprite

@export var attack_texture: Texture2D
@export var buff_texture: Texture2D
@export var debuff_texture: Texture2D
@export var misc_texture: Texture2D
@export var movement_texture: Texture2D
@export var movement_attack_texture: Texture2D
@export var hammer_texture: Texture2D

const INTENT_CHANGE_TIME: float = 0.5

var Card: EpicCardGD
func setInfo(_Card: EpicCardGD) -> void:
	Card = _Card
	BossIntentSprite.position.y = Card.getStatFromInfo()
	onUpdateBossIntent()

func onUpdateBossIntent() -> void:
	if Card.boss_intent == null: return
	
	var tx: Texture
	match Card.boss_intent.type:
		BossIntent.IntentType.ATTACK: tx = attack_texture
		BossIntent.IntentType.BUFF: tx = buff_texture
		BossIntent.IntentType.DEBUFF: tx = debuff_texture
		BossIntent.IntentType.MISC: tx = misc_texture
		BossIntent.IntentType.MOVEMENT: tx = movement_texture
		BossIntent.IntentType.MOVEMENT_ATTACK: tx = movement_attack_texture
		BossIntent.IntentType.HAMMER: tx = hammer_texture
	
	var scale_tween := create_tween()
	scale_tween.tween_property(BossIntentSprite, "scale:x", -1.0, INTENT_CHANGE_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	await scale_tween.finished
	
	scale_tween = create_tween()
	BossIntentSprite.texture = tx
	scale_tween.tween_property(BossIntentSprite, "scale:x", 1.0, INTENT_CHANGE_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
