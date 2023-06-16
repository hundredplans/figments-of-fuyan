extends CharacterBody3D

const direction_vectors: Dictionary = {
		"Forward": Vector3(0,0,-1),
		"Back": Vector3(0,0,1),
		"Left": Vector3(-1,0,0),
		"Right": Vector3(1,0,0)
	}
	
const height_vectors: Dictionary = {
	"Up": Vector3(0,1,0),
	"Down": Vector3(0,-1,0),
}

var total_pitch: float = rotation.x

enum {CAMERA_DISABLED, CAMERA_HOLD, CAMERA_TOGGLE}
enum {MOVEMENT_DISABLED, MOVEMENT_HOLD_TOGGLE, MOVEMENT_ALWAYS}
var current_camera = CAMERA_HOLD
var current_movement = MOVEMENT_HOLD_TOGGLE
var current_state = [CAMERA_DISABLED, MOVEMENT_DISABLED]

const camera_speed: float = 5
const camera_sensitivity: float = 0.1
@export var camera_speed_multiplier: float = 1
@export var camera_sensitivity_multiplier: float = 1

func _input(event) -> void:
	if event is InputEventMouseButton:
		match current_state[0]:
			CAMERA_HOLD:
				if Input.is_action_pressed("InputB"):
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			CAMERA_TOGGLE:
				if Input.is_action_just_pressed("InputB"):
					if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
						Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					else:
						Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			CAMERA_DISABLED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			move_camera(event.relative * camera_sensitivity_multiplier * camera_sensitivity)
func move_camera(movement: Vector2):
	var pitch = clamp(movement.y, -90 - total_pitch, 90 - total_pitch)
	total_pitch += pitch 
	rotate_y(deg_to_rad(-movement.x))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
func _physics_process(_delta):
	velocity = Vector3.ZERO
	match current_state[1]:
		MOVEMENT_HOLD_TOGGLE:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				move_character()
		MOVEMENT_ALWAYS:
			move_character()
	move_and_slide()
func move_character() -> void:
	for key in direction_vectors:
		if Input.is_action_pressed("Input%s" % key):
			var rotated_vector: Vector3  = direction_vectors[key].normalized().rotated(Vector3.UP, rotation.y)
			velocity += rotated_vector * camera_speed * camera_speed_multiplier
			
	for key in height_vectors:
		if Input.is_action_pressed("Input%s" % key):
			velocity += height_vectors[key] * camera_speed * camera_speed_multiplier
func set_current_state(new_state: int) -> void:
	match new_state:
		0:
			current_state = [CAMERA_DISABLED, MOVEMENT_DISABLED]
		1:
			current_state = [current_camera, current_movement]
