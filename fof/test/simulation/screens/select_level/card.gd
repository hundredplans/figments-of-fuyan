extends Control

@export var downscale_scale: float = 0.5
const RED := Color(1,0,0,1)
const DEF := Color(1,1,1,1)
var default_state: Array = []
var can_drag: bool = false
var eye_mode: bool = false
var held: bool = true
var team: int = 0

signal refresh_vision

func _ready():
	on_team_buttons_modulate()
	on_scale_buttons_modulate()
	$ScaleMe/Downscaled.text = str(downscale_scale)

func _on_destroy_pressed():
	queue_free()

func _on_drag_zone_mouse_entered():
	can_drag = true

func _on_drag_zone_mouse_exited():
	can_drag = false
	
func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - (($Out.size.x / 2)) * scale.x
			position.y = (get_viewport().get_mouse_position().y) - (($Out.size.y / 2) - 100) * scale.y
		else:
			held = false

func _on_eye_button_pressed():
	eye_mode = !eye_mode
	match eye_mode:
		false: $EyeButton.modulate = Color(1,1,1,1)
		true: $EyeButton.modulate = Color(1,0,0,1)
		
	refresh_vision.emit()

func _on_default_state_pressed():
	$Name.text = default_state[0]
	$Text.text = default_state[1]
	$ArtMax.texture = load("res://test/simulation/assets/sprites/%s" % default_state[2])
	$Att.text = default_state[3]
	$Hp.text = default_state[4]
	$Spd.text = default_state[5]
	$Energy.text = default_state[6]
	var rarity: int = 0
	if default_state.size() > 7: rarity = int(default_state[7])
	match rarity:
		0: $In.color = Color(0.43,0.43,0.43,1)
		1: $In.color = Color(0.31, 0.478, 0.439,1)
		2: $In.color = Color(0.966, 0.697, 0.253,1)
		3: $In.color = Color(0.639, 0.075, 0.722,1)
		4: $In.color = Color(0.773, 0.031, 0.141, 1)
		5: $In.color = Color(0.374, 0.6, 1, 1)

func _on_team_zero_pressed():
	team = 0
	on_team_buttons_modulate()
	
func _on_team_one_pressed():
	team = 1
	on_team_buttons_modulate()

func on_team_buttons_modulate():
	match team:
		0: get_node("Team/0").modulate = RED; get_node("Team/1").modulate = DEF
		1: get_node("Team/0").modulate = DEF; get_node("Team/1").modulate = RED
	refresh_vision.emit()


func on_scale_buttons_modulate():
	match scale:
		Vector2.ONE: $ScaleMe/Downscaled.modulate = DEF; $ScaleMe/Fullscale.modulate = RED
		_: $ScaleMe/Downscaled.modulate = RED; $ScaleMe/Fullscale.modulate = DEF

func _on_fullscale_pressed():
	scale = Vector2.ONE
	on_scale_buttons_modulate()

func _on_downscaled_pressed():
	scale = Vector2(downscale_scale, downscale_scale)
	on_scale_buttons_modulate()
