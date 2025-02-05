extends GPUParticles3D

const NOT_SPAWN_FX_AMOUNT_RATIO: float = 0.2
var is_occupied: bool
var is_spawn_fx: bool
func onSpawnFX(state: bool) -> void:
	is_spawn_fx = state
	setAmountRatio()

func onOccupy(state: bool) -> void:
	is_occupied = state
	setAmountRatio()
	
func setAmountRatio() -> void:
	amount_ratio = (1.0 if is_spawn_fx else NOT_SPAWN_FX_AMOUNT_RATIO) if !is_occupied else 0.0
