extends GridContainer

const MAX_ICON_COLUMN_COUNT: int = 3
@export var GameEffectIconPacked: PackedScene

func onAddIcon(GameEffect: GameEffectGD) -> void:
	var GameEffectIcon: Control = GameEffectIconPacked.instantiate()
	add_child(GameEffectIcon)
	setColumns()
	GameEffectIcon.setInfo(GameEffect)
	
func onRemoveIcon(GameEffect: GameEffectGD) -> void:
	var GameEffectIcon: Control = getGameEffectIconFromGameEffect(GameEffect)
	if GameEffectIcon == null: return
	
	GameEffectIcon.queue_free()
	setColumns()

func getGameEffectIconFromGameEffect(GameEffect: GameEffectGD) -> Control:
	for child: Control in get_children():
		if child.getGameEffect() == GameEffect: return child
	return null 

func onCreateGameEffects(SpectateObject: GameObjectGD) -> void:
	for child: Control in get_children(): child.queue_free()
	if SpectateObject is CardGD:
		var game_effects: Array = SpectateObject.getGameEffects()
		for GameEffect: GameEffectGD in game_effects: onAddIcon(GameEffect)

func getChildSize() -> int: return get_children().filter(func(x: Control): return !x.is_queued_for_deletion()).size()
func setColumns() -> void: columns = ceil(float(getChildSize()) / 3.0)
