extends Node2D
var tile_colors: bool = true
var circle_size: int = 200

func _ready():
	on_change_setting()
	
func _draw() -> void:
	draw_circle(Vector2(0, 0), circle_size, Color(0,0,0,1))

func _process(_delta) -> void:
	if Input.is_action_just_pressed("MouseUp") and tile_colors:
		tile_colors = !tile_colors
		on_change_setting()
		
	elif Input.is_action_just_pressed("MouseDown") and !tile_colors:
		tile_colors = !tile_colors
		on_change_setting()
		
func on_change_setting():
	
	for child in $ActiveSetting.get_children(): child.queue_free()
	match tile_colors:
		false: 
			circle_size = 120
			var arrow_states: Control = preload("res://test/simulation/screens/create_level/arrow_states.tscn").instantiate()
			$ActiveSetting.add_child(arrow_states)
			for child in arrow_states.get_children():
				if child is TextureButton:
					child.mouse_entered.connect(func(): get_parent().active_arrow_state = int(str(child.name)))
			queue_redraw()
		true: 
			circle_size = 200
			var set_tile_colors: Control = preload("res://test/simulation/screens/create_level/tile_colors.tscn").instantiate()
			$ActiveSetting.add_child(set_tile_colors)
			for child in set_tile_colors.get_children():
				if child is TextureButton:
					child.mouse_entered.connect(func(): get_parent().active_tile_state = int(str(child.name)))
			queue_redraw()
