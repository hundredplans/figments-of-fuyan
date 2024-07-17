class_name PalmFireplaceGD
extends IObjectGD

var particles: GPUParticles3D
var wood_count: int = 10

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if wood_count < 10 and trigger == TriggerGD.START_TURN_GLOBAL and args.team_relation.onTeam() == 0:
		var i: int = abs(wood_count - 10)
		var obj_model: Node3D = BaseTile.types[1].model
		obj_model.meshes[i].visible = true
		obj_model.bodies[i].visible = true
		wood_count += 1
		
		if wood_count == 10:
			for _ability in info.abilities:
				_ability.charges += 1
				_ability.used = false
		
func onCondition(Unit: UnitGD) -> bool: return Unit.Tile in interactable_tiles
func onAbilityTrigger(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> void:
	var units: Array = Units.onFindAdjacentUnits(Unit, 2).filter(func(x: UnitGD): return x.team == Unit.team)
	var AppliedBy := AppliedByGD.new("IObject", Unit)
	for _Unit in units:
		match info.abilities.find(ability):
			0: Combat.onApplyBuffNextTurn(BuffInfoGD.new(_Unit, AppliedBy, "speed", 1))
			1: Combat.onApplyBuffNextTurn(BuffInfoGD.new(_Unit, AppliedBy, "attack", 1))
			2: Combat.onHeal(HealInfoGD.new(_Unit, AppliedBy, 1))
	
	GameEffects.onDefaultStun(Unit)
	for _ability in info.abilities:
		_ability.charges -= 1
		_ability.used = true

	onRemoveWood(ability)

func onRemoveWood(ability: IObjectAbilityInfoGD) -> void:
	await Units.get_tree().create_timer(ability.delay / 12).timeout
	var i: int = abs(wood_count - 10) + 1
	var obj_model: Node3D = BaseTile.types[1].model
	obj_model.meshes[i].visible = false
	obj_model.bodies[i].visible = false
	if wood_count == 10:
		particles = preload("res://scenes/screens/level_map/utility_nodes/vfx/default_particles/palm_fireplace_particles.tscn").instantiate()
		obj_model.add_child(particles)
		
	wood_count -= 1
	if wood_count > 0:
		onRemoveWood(ability)
	elif particles != null:
		particles.amount_ratio = 0
		await Units.get_tree().create_timer(1).timeout
		particles.queue_free()
