class_name HurtAction extends Action

const HURT_DEFAULT_DELAY: float = 1.8

var Damager: FofGD
var Defender: GameObjectGD
var damage: int
var health_damage: int

func _init(_Damager: FofGD = null, _Defender: GameObjectGD = null, _damage: int = 0, _health_damage: int = 0) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage
	health_damage = _health_damage
	
func onPreAction() -> void:
	setActionDelay(HURT_DEFAULT_DELAY if (Defender.isLevelVisible() and health_damage > 0) else 0.0)

func onPostAction() -> void:
	if health_damage > 0: Defender.onHurt()
	Audio.onSoundEffect(Defender.getInfo().getHurtAudio())
