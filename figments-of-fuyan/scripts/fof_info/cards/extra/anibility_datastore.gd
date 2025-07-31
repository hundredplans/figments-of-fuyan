class_name AnibilityDatastore extends Resource

@export var idle_modifier: String
@export var attack_modifier: String
@export var walk_modifier: String
@export var death_modifier: String
@export var jump_modifier: String

func setIdleModifier(_idle_modifier: String) -> void:
	idle_modifier = _idle_modifier
	
func setAttackModifier(_attack_modifier: String) -> void:
	attack_modifier = _attack_modifier

func setWalkModifier(_walk_modifier: String) -> void:
	walk_modifier = _walk_modifier
	
func setDeathModifier(_death_modifier: String) -> void:
	death_modifier = _death_modifier
	
func setJumpModifier(_jump_modifier: String) -> void:
	jump_modifier = _jump_modifier

func getWalkModifier() -> String:
	return walk_modifier
	
func getDeathModifier() -> String:
	return death_modifier
	
func getAttackModifier() -> String:
	return attack_modifier
	
func getIdleModifier() -> String:
	return idle_modifier
	
func getJumpModifier() -> String:
	return jump_modifier
	
func onResetWalkModifier() -> void:
	setWalkModifier("")

func onResetIdleModifier() -> void:
	setIdleModifier("")
	
func onResetAttackModifier() -> void:
	setAttackModifier("")

func onResetJumpModifier() -> void:
	setJumpModifier("")
