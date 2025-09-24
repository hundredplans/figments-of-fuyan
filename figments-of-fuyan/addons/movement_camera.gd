class_name FreeLookCamera extends Camera3D
signal camera_panning
signal camera_changed_speed
# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false
var _ctrl = false

@export var disable_movement: bool = false
@export var block_ctrl: bool = false
@export var block_arrows: bool = false
@export_group("Sideways")
@export var enable_only_sideways: bool = false
@export var X_MIN: float = 0
@export var X_MAX: float = 0
@export_group("")

@export_group("Freelook")
@export var disable_freelook: bool = false
@export_range(-90, 0) var freelook_clamp_bottom: int = -90
@export_range(0, 90) var freelook_clamp_top: int = 90
@export_group("")
var ANTI_INTERACT_BUTTON: int = MOUSE_BUTTON_RIGHT
var spawn_camera_mode: bool

const CAMERA_ROTATION_SPEED: float = 3.0

func setDisableFreelook(state: bool) -> void:
	disable_freelook = state
	if disable_freelook:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if !current: return
	# Receives mouse motion
	if spawn_camera_mode and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		setCameraPointAlongCircle((event.relative.x / 10000) * CAMERA_ROTATION_SPEED)
	
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Receives mouse button input
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)
		
		camera_changed_speed.emit()

	# Receives key input
	if event is InputEventKey and !(get_viewport().gui_get_focus_owner() as LineEdit):
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
				
		if !block_arrows:
			match event.keycode:
				KEY_UP:
					_w = event.pressed
				KEY_DOWN:
					_s = event.pressed
				KEY_LEFT:
					_a = event.pressed
				KEY_RIGHT:
					_d = event.pressed
					
		match event.keycode:
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed
			KEY_CTRL:
				_ctrl = event.pressed if block_ctrl else false

# Updates mouselook and movement every frame
func _process(delta):
	if !current: return
	_update_mouselook()
	_update_movement(delta)
	onUpdateFreelookInput()
	
	if spawn_camera_mode: setCameraPointAlongCircle()
	
func onUpdateFreelookInput() -> void:
	if Input.is_action_just_pressed("AltInput") and (!disable_freelook or spawn_camera_mode):
		camera_panning.emit(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().update_mouse_cursor_state()
		
	elif Input.is_action_just_released("AltInput") and (!disable_freelook or spawn_camera_mode):
		camera_panning.emit(false)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().update_mouse_cursor_state()
		
# Updates camera movement
func _update_movement(delta):
	if disable_movement or _ctrl: return
	# Computes desired direction from key states
	_direction = Vector3((_d as float) - (_a as float), 
						(_e as float) - (_q as float), 
						(_s as float) - (_w as float))
						
	if enable_only_sideways: _direction.y = 0; _direction.z = 0
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
		translate(_velocity * delta * speed_multi)
		
		if enable_only_sideways:
			onClampPosition()
		
		get_viewport().warp_mouse(get_viewport().get_mouse_position())
		
func onClampPosition() -> void:
	if X_MIN != 0 and X_MAX != 0: position.x = clamp(position.x, X_MIN, X_MAX)
		
# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !disable_freelook:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, freelook_clamp_bottom - _total_pitch, freelook_clamp_top - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func onDisableMovement(state: bool) -> void:
	disable_movement = state
	_velocity = Vector3.ZERO
	
func setSpawnCameraMode(state: bool) -> void:
	spawn_camera_mode = state
	
const CAMERA_RADIUS: float = 20.0
var total_progress: float
func setCameraPointAlongCircle(progress: float = 0.0) -> void:
	if progress != 0:
		total_progress = clampf(total_progress + progress, 0, 1)
		if total_progress <= 0: total_progress = 1
		elif total_progress >= 1: total_progress = 0
	
	var x: float = (CAMERA_RADIUS * cos(total_progress * TAU))
	var z: float = (CAMERA_RADIUS * sin(total_progress * TAU))

	position.x = x
	position.z = z
	look_at(Vector3.ZERO)
