extends Node3D

@onready var BossIntentSprite: Sprite3D = %BossIntentSprite

@export var attack_texture: Texture2D
@export var buff_texture: Texture2D
@export var debuff_texture: Texture2D
@export var misc_texture: Texture2D
@export var movement_texture: Texture2D
@export var movement_attack_texture: Texture2D

var Card: BossCardGD
func setInfo(_Card: BossCardGD) -> void:
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
	
	BossIntentSprite.texture = tx
