extends Control

signal team_changed

var remove_aura: bool = false
@onready var utility_ani: AnimationPlayer = $UtilityMenu/UtilityPressed
@export var downscale_scale: float = 0.5
const RED := Color(1,0,0,1)
const DEF := Color(1,1,1,1)
var default_state: Array = []
var can_hold: bool = true
var can_drag: bool = false
var held: bool = true
var team: int = 1
var card_path: String

signal drag_drag_pressed
signal refresh_vision

func _ready():
	on_team_buttons_modulate()
	on_scale_buttons_modulate()
	$ScaleMe/Downscaled.text = str(downscale_scale)

func _on_destroy_pressed():
	queue_free()

func _on_drag_zone_mouse_entered():
	can_drag = true
	print("ENTERED")

func _on_drag_zone_mouse_exited():
	can_drag = false
	print("EXITED")
	
func _process(_delta: float) -> void:
	if can_hold and (can_drag or held):
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - (($Out.size.x / 2)) * scale.x
			position.y = (get_viewport().get_mouse_position().y) - (($Out.size.y / 2) - 100) * scale.y
		else:
			held = false
			
	if remove_aura and Input.is_action_just_pressed("LeftClick"):
		$AuraSelected/AuraArt.texture = null

	if can_drag and Input.is_action_just_pressed("RightClick"):
		if position.x > 1920: 
			position.x -= 1920
		else:
			position.x += 1920

func _on_default_state_pressed():
	$Name.text = default_state[0]
	$Text.text = default_state[1]
	$ArtMax.texture = load("res://test/simulation/assets/sprites/units/%s" % default_state[2])
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
		6: $In.color = Color(0.196, 0.196, 0.196, 1)
		
func _on_save_card_pressed():
	var rarity: int = 0
	match $In.color:
		Color(0.43,0.43,0.43,1): rarity = 0
		Color(0.31, 0.478, 0.439,1): rarity = 1
		Color(0.966, 0.697, 0.253,1): rarity = 2
		Color(0.639, 0.075, 0.722,1): rarity = 3
		Color(0.773, 0.031, 0.141, 1): rarity = 4
		Color(0.374, 0.6, 1, 1): rarity = 5
		Color(0.196, 0.196, 0.196, 1): rarity = 6

	default_state = [$Name.text, $Text.text, $ArtMax.texture.resource_path.get_slice("/", 7), $Att.text, $Hp.text, $Spd.text, $Energy.text, rarity]
	var rpath = $ArtMax.texture.resource_path
	var tex = rpath.right(rpath.length() - rpath.rfind("/") - 1)
	var file := FileAccess.open("user://savefofle/cards/%s.txt" % $Name.get_text(), FileAccess.WRITE)
	var accum: String = $Name.get_text() + "\n"
	accum += ($Text.text.replace("\n", "")) + "\n"
	accum += tex + "\n"
	
	for child in [$Att, $Hp, $Spd, $Energy]:
		accum += child.text + "\n"
	
	match $In.color:
		Color(0.43,0.43,0.43,1): accum += str(0) + "\n"
		Color(0.31, 0.478, 0.439,1): accum += str(1) + "\n"
		Color(0.966, 0.697, 0.253,1): accum += str(2) + "\n"
		Color(0.639, 0.075, 0.722,1): accum += str(3) + "\n"
		Color(0.773, 0.031, 0.141, 1): accum += str(4) + "\n"
		Color(0.374, 0.6, 1, 1): accum += str(5) + "\n"
		Color(0.196, 0.196, 0.196, 1): accum += str(6) + "\n"

	file.store_string(accum)
	file = null
		
func on_team_buttons_modulate():
	$ChangeTeam.text = str(team)
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
func _on_change_team_pressed():
	team = abs(team - 1)
	on_team_buttons_modulate()
	team_changed.emit(self)

func _on_utility_pressed():
	if !utility_ani.is_playing():
		match $UtilityMenu.modulate:
			Color(1,1,1,1): utility_ani.play_backwards("utility_pressed")
			_: utility_ani.play("utility_pressed")

func on_transform_pressed(state: int) -> void:
	var rarity: int = 0
	match $In.color:
		Color(0.43,0.43,0.43,1): rarity = 0
		Color(0.31, 0.478, 0.439,1): rarity = 1
		Color(0.966, 0.697, 0.253,1): rarity = 2
		Color(0.639, 0.075, 0.722,1): rarity = 3
		Color(0.773, 0.031, 0.141, 1): rarity = 4
		Color(0.374, 0.6, 1, 1): rarity = 5
		Color(0.196, 0.196, 0.196, 1): rarity = 6
	
	var filter_call: Callable
	match state:
		0: filter_call = func(x: String): var xs: Array = x.split("\n"); return xs[6] == $Energy.text and xs[0] != $Name.text and xs[7] != "6"
		1: filter_call = func(x: String): var xs: Array = x.split("\n"); return int(xs[7]) == rarity and xs[0] != $Name.text
		2: filter_call = func(x: String): var xs: Array = x.split("\n"); return int(xs[7]) == min(rarity + 1, 4) and xs[0] != $Name.text
		
	var contents: Array = get_directory_file_contents_recursive("user://savefofle/cards/").filter(filter_call)
	if contents.size() > 0:
		default_state = contents[randi() % contents.size()].split("\n")
		_on_default_state_pressed()
	
func get_directory_file_contents_recursive(path: String, contents: Array = []):
	var dir := DirAccess.open(path)
	contents += Array(dir.get_files()).map(func(x: String): return FileAccess.open(path + x, FileAccess.READ).get_as_text())
	for subdir in dir.get_directories():
		if subdir not in ["None", "Champions"]:
			contents = get_directory_file_contents_recursive(path + subdir + "/", contents)
	return contents

func _on_drag_drag_pressed():
	drag_drag_pressed.emit([$ArtMax.texture.resource_path.get_slice("/", 7),self])

func _on_load_aura_pressed():
	var loadcard: Control = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	loadcard.aura_selected.connect(on_aura_selected)
	loadcard.load_state = 2
	get_parent().get_parent().add_child(loadcard)
	
func on_aura_selected(aura_path: String) -> void:
	$AuraSelected/AuraArt.texture = load(FileAccess.open("user://savefofle/auras_boons/auras/" + aura_path, FileAccess.READ).get_as_text().split("\n")[2])

func _on_aura_selected_mouse_entered():
	remove_aura = true

func _on_aura_selected_mouse_exited():
	remove_aura = false

func _on_transform_custom_pressed():
	var loadcard: Control = preload("res://test/simulation/screens/load_stuff/load_stuff.tscn").instantiate()
	loadcard.card_selected.connect(on_card_selected)
	get_parent().get_parent().add_child(loadcard)
	
func on_card_selected(card_name: String) -> void:
	var path: String = "user://savefofle/cards/%s" % card_name
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		var card_info: Array = file.get_as_text().split("\n")
		default_state = card_info
		_on_default_state_pressed()
