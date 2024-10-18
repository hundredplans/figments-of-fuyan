class_name StatusEffectInfo extends FofInfo

enum States {NEUTRAL, NEGATIVE, POSITIVE}

@export var icon: Texture2D
@export_multiline var description: String
@export var state: States
@export var is_negative: bool
