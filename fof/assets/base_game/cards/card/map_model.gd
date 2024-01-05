extends Node3D

signal champion_arrived
@export var ROTATION_TIME: float = 2
@export var BLEND_TIME: float = 0.3
@export var TRAVEL_TIME: float = 1.2

@onready var AniP: AnimationPlayer = $AnimationPlayer
func _ready() -> void:
	AniP.animation_finished.connect(on_anip_animation_finished)
	AniP.play("Idle")
	rotation_degrees.y = -180

var move_position: Vector3
var is_walk_animation: int = 0
func move_to(pos: Vector3) -> void:
	look_at(pos, Vector3(0, 1, 0), true)
	is_walk_animation = 1
	move_position = pos
	
func _physics_process(_delta: float) -> void:
	match is_walk_animation:
		1:
			var MoveTween: Tween = get_tree().create_tween()
			MoveTween.tween_property(self, "global_position", move_position, TRAVEL_TIME)
			MoveTween.finished.connect(on_walk_animation_finished)
			AniP.play("Walk", BLEND_TIME)
			is_walk_animation = 0
	
var t: float = 0
var rotate_interpolate: bool = false
func _process(delta: float) -> void:
	if rotate_interpolate:
		t += delta
		rotation.y = rotation.y + (PI - rotation.y) * min((t / ROTATION_TIME), 1)
		if t >= ROTATION_TIME: t = 0; rotate_interpolate = false
	
func on_walk_animation_finished() -> void:
	on_anip_animation_finished("Walk")
	champion_arrived.emit()
	
func on_anip_animation_finished(ani_name: String = "") -> void:
	if ani_name != "Death": AniP.play("Idle", BLEND_TIME)
	if rotation.y < 0: rotation.y += (2 * PI)
	rotate_interpolate = true

func on_add_walk_sfx(area_id: int) -> void:
	AniP.animation_started.connect(on_animation_play_walk_sfx.bind(area_id))

func on_animation_play_walk_sfx(ani_name: String, area_id: int) -> void:
	if ani_name == "Walk":
		AudioMaster.play_sfx(Helper.area_to_default_ground[area_id], 0, TRAVEL_TIME)
