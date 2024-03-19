extends Node3D

var SpectateCamera: Node3D

var Unit: UnitGD
@export var NUMBER_SCALE_TIME: float = 0.15
@export var NUMBER_SHAKE_SPEED: int = 12
@onready var FloatingStats: Node3D = %FloatingStats
@onready var Numbers: Node3D = %Numbers
@onready var Effects: Node3D = %Effects

var unit_set: bool = false
func _process(delta: float) -> void:
	if visible and unit_set:
		for child in Numbers.get_children() + FloatingStats.get_children() + Effects.get_children():
			child.rotation_degrees.z += NUMBER_SHAKE_SPEED * delta
			
		var child_zero: Node3D = Numbers.get_child(0)
		if child_zero.rotation_degrees.z < -10 or child_zero.rotation_degrees.z > 10: NUMBER_SHAKE_SPEED *= -1
		
		look_at(SpectateCamera.global_position)
		
var attack: int = -1
var health: int = -1
var speed: int = -1

func on_set_stats(att: int, hp: int, spd: int, att_mod: String, hp_mod: String, spd_mod: String) -> void:
	for stat_info in [[att, "attack", att_mod, att], [hp, "health", hp_mod, health], [spd, "speed", spd_mod, speed]]:
		if stat_info[0] != get(stat_info[1]):
			var stat_str: String = str(stat_info[0])
			var stat_array: Array = []
			for i in range(stat_str.length()):
				stat_array.append(int(stat_str[i]))
			
			if stat_info[1] == "speed" and spd == 0: on_move_boot(0, -1)
			var ScaleTween := get_tree().create_tween()
			ScaleTween.tween_property(Numbers.get_node(stat_info[1]), "scale:y", 0, NUMBER_SCALE_TIME)
			ScaleTween.finished.connect(on_create_new_stats.bind(stat_array, stat_info[1], stat_info[2], stat_info[3]))

			match stat_info[1]:
				"attack": attack = att
				"health": health = hp
				"speed": speed = spd

var stat_type_mod_types: Dictionary = {
	"attack": "",
	"health": "",
	"speed": "",
}
func on_create_new_stats(stat_array: Array, stat_type: String, mod_type: String, original_stat: int) -> void:
	for child in Numbers.get_node(stat_type).get_children():
		child.queue_free()
		
	for stat in stat_array:
		if !(stat_type == "speed" and stat == 0):
			var loaded_number: Node3D = load("res://scenes/screens/level_map/floating_stats/numbers/" + Helper.NUM_TO_STRING_NUM[stat] + ".glb").instantiate()
			loaded_number.position.y -= 0.1
			stat_type_mod_types[stat_type] = mod_type
			Numbers.get_node(stat_type).add_child(loaded_number)
			
			var ScaleTween := get_tree().create_tween()
			ScaleTween.tween_property(Numbers.get_node(stat_type), "scale:y", 1, NUMBER_SCALE_TIME)
					
			if stat_type == "speed" and original_stat == 0: on_move_boot(1, 1)
			Numbers.get_node(stat_type).on_sort_children()
		on_set_number_materials(stat_type, spectate_state)
		
func on_move_boot(boot_scale: int, offset_multiplier: int) -> void:
	var GeneralTween := get_tree().create_tween()
	GeneralTween.tween_property(FloatingStats.get_node("speed"), "scale:y", boot_scale, NUMBER_SCALE_TIME)
	for _stat in ["attack", "health"]:
		for node in [FloatingStats.get_node(_stat), Numbers.get_node(_stat)]:
			var NewTween := get_tree().create_tween()
			NewTween.tween_property(node, "position:y", node.position.y + (0.25 * offset_multiplier), NUMBER_SCALE_TIME)
	
var spectate_state: bool = false
func on_unit_spectated(state: bool) -> void:
	spectate_state = state
	for child in [%attack.get_child(0), %health.get_child(0), %speed.get_child(0)]:
		child.set_surface_override_material(0, null if !state else preload("res://assets/materials/base_materials/base_material_on_top.tres"))
	
	for _stat in ["attack", "health", "speed"]:
		on_set_number_materials(_stat, state)

func on_set_number_materials(stat_type: String, state: bool) -> void:
	for child in Numbers.get_node(stat_type).get_children():
		for grandchild in child.get_children():
			grandchild.set_surface_override_material(0, \
			Unit.Units.unit_field_status_materials[stat_type_mod_types[stat_type]][int(state)])

	Effects.get_node("TurnUsed").no_depth_test = state
