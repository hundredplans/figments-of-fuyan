extends IObjectGD

var particles: GPUParticles3D
var wood_count: int = 10

func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if wood_count < 10 and trigger == TriggerGD.START_TURN_GLOBAL and args.team_relation.onTeam() == 0:
		if attack_turns > 0:
			attack_turns -= 1
			if attack_turns == 0:
				for Unit in attack_buffed_units: StatusManager.onRemoveUnitFX(Unit, "PalmFireplace")
		if wood_count < 10:
			var i: int = abs(wood_count - 10)
			var obj_model: Node3D = BaseTile.types[1].model
			obj_model.meshes[i].visible = true
			obj_model.bodies[i].visible = true
			wood_count += 1
			
			if wood_count == 10:
				for _ability in info.abilities:
					_ability.charges += 1
					_ability.used = false

var attack_buffed_units: Array = []
var attack_turns: int = 0
	
func onCondition(Unit: UnitGD) -> bool: return Unit.Tile in interactable_tiles
func onAbilityTrigger(Unit: UnitGD, ability: IObjectAbilityInfoGD) -> void:
	attack_buffed_units = []
	var units: Array = Units.getAdjacentUnits(BaseTile, 2).filter(func(y: UnitGD): return y.team == Unit.team)
	var AppliedBy := AppliedByGD.new(AppliedByGD.IOBJECT, self)
	for _Unit in units:
		match info.abilities.find(ability):
			0: Units.changeStats(StatInfoGD.new(_Unit, AppliedBy, StatsGD.BOTH_SPEED, 1, 1))
			1:
				attack_turns = 2
				Units.changeStats(StatInfoGD.new(_Unit, AppliedBy, StatsGD.ATTACK, 1, 2))
				StatusManager.onAddUnitFX(Unit, "PalmFireplace", AppliedBy, attack_turns)
				attack_buffed_units.append(Unit)
			2: Combat.onHeal(HealInfoGD.new(_Unit, 1, AppliedBy))
	
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
