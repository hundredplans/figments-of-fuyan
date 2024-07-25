class_name ToolGD
extends Node

var Unit: UnitGD
var tool_info: ToolInfoGD
var is_ascended: bool

var Tools: ToolsGD
var Tiles: TilesGD
var Combat: CombatGD
var Units: UnitsGD
var VFX: VFXGD
var ActionManager: ActionManagerGD
var Vision: VisionGD
var GameEffects: GameEffectsGD

func setInfo(_tool_info: ToolInfoGD = null, _is_ascended: bool = false) -> void:
	tool_info = _tool_info
	is_ascended = _is_ascended
	
	for tool_ability in tool_info.tool_abilities:
		tool_ability.charges = tool_ability.max_charges
	
	Helper.onCreateChildReferences(self)

func getDescription() -> String:
	if !is_ascended: return tool_info.description
	else: return tool_info.ascended_description

func getAbilityDescription(tool_ability_info: ToolAbilityInfoGD) -> String:
	if !is_ascended: return tool_ability_info.description
	else: return tool_ability_info.ascended_description

func onUnitAwakened(_Unit: UnitGD) -> void:
	Unit = _Unit
	
func getToolAbilities() -> Array:
	return tool_info.tool_abilities.filter(func(x: ToolAbilityInfoGD): return x.ability_type > 0 if !is_ascended else x.ascended_ability_type > 0)

func onStartTurnTrigger(team: int) -> void:
	if Unit != null and Unit.team == team:
		for tool_ability in tool_info.tool_abilities:
			tool_ability.used = false

func getCanAffect(tool_ability: ToolAbilityInfoGD) -> bool:
	if tool_ability.ability_type == ToolAbilityInfoGD.ABILITY_TYPES.ABILITY and !is_ascended or \
	tool_ability.ascended_ability_type == ToolAbilityInfoGD.ABILITY_TYPES.ABILITY:
		return true
		
	if tool_ability.ability_type == ToolAbilityInfoGD.ABILITY_TYPES.ABILITY_SELECT and !is_ascended or \
	tool_ability.ascended_ability_type == ToolAbilityInfoGD.ABILITY_TYPES.ABILITY_SELECT:
		return tool_ability.can_affect
		
	return false

func onRemoveSelf() -> void:
	queue_free()

func getAbilityType(tool_ability: ToolAbilityInfoGD) -> int:
	if is_ascended: return tool_ability.ascended_ability_type
	else: return tool_ability.ability_type

func onCondition(_ability: ToolAbilityInfoGD) -> bool: return true
