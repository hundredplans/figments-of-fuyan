class_name BossIntent extends Resource

@export var name: String
@export_multiline var description: String
@export var type: IntentType
@export var default_cooldown: int = 1
@export var combat_type: CombatType

enum CombatType {BOTH, IN_COMBAT, OUT_OF_COMBAT}
enum IntentType {ATTACK, MOVEMENT_ATTACK, MOVEMENT, DEBUFF, BUFF, MISC}
