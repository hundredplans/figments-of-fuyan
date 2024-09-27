extends Node3D

@onready var FloatingStats: Node3D = %FloatingStats
@onready var AttackSpot: Node3D = %AttackSpot
@onready var HealthSpot: Node3D = %HealthSpot
@onready var SpeedSpot: Node3D = %SpeedSpot

@onready var Numbers: Node3D = %Numbers
@export var number_to_model: Array[PackedScene]

@export var green_material: Material
@export var white_material: Material
@export var red_material: Material

@export var green_top_material: Material
@export var white_top_material: Material
@export var red_top_material: Material

@export var top_base_material: Material
var Card: CardGD

func setInfo(_Card: CardGD) -> void:
	Card = _Card
	position.y = Card.info.stat
	onResetStats()
	
func onResetStats() -> void:
	var mat: Material = null if !is_spectated else top_base_material
	print(mat)
	print()
	for mesh in Helper.getNodeTypeRecursive(FloatingStats, MeshInstance3D):
		mesh.set_surface_override_material(0, mat)
	onCreateFloatingNumbers()
	
func onCreateFloatingNumbers() -> void:
	onCreateStat(AttackSpot, Card.attack, Card.info.attack, Card.info.attack)
	onCreateStat(HealthSpot, Card.health, Card.info.health, Card.max_health)
	onCreateStat(SpeedSpot, Card.speed, Card.info.speed, Card.speed)

func onCreateStat(spot: Node3D, value: int, above_green_value: int, below_red_value: int) -> void:
	for child in spot.get_children(): child.queue_free()
	var string_value: String = str(value)
	var numbers: Array = []
	
	for char in string_value: numbers.append(int(char))
	numbers = numbers.map(func(x: int): return number_to_model[x].instantiate())
	
	var mat: Material = white_material if !is_spectated else white_top_material
	if value < below_red_value: mat = red_material if !is_spectated else white_top_material
	elif value > above_green_value: mat = green_material if !is_spectated else green_top_material
	
	for NumberModel in numbers:
		spot.add_child(NumberModel)
		Helper.getNodeTypeRecursive(NumberModel, MeshInstance3D)[0].set_surface_override_material(0, mat)
	
	spot.scale = Vector3.ONE if numbers.size() == 1 else Vector3(0.75, 0.75, 0.75)
	if numbers.size() == 2:
		numbers[0].position.x = -0.125
		numbers[1].postiion.x = 0.125
		
var is_spectated: bool = false
func onSpectated(state: bool) -> void:
	is_spectated = state
	onResetStats()
