extends Control
signal text_submitted
var open: bool = false
var showcase_text_changed: bool = false

func _on_lock_button_pressed():
	if !$LockButtonPressed.is_playing():
		open = !open
		match open:
			false: $LockButtonPressed.play("on_lock_button_closed")
			true: $LockButtonPressed.play("on_lock_button_open")

func _on_internal_text_changed(new_text: String):
	if !showcase_text_changed:
		$Showcase.text = new_text

func _on_showcase_text_changed(__: String):
	showcase_text_changed = true
	
func set_text(itext: String, stext:String="") -> void:
	showcase_text_changed = false
	$Internal.text = itext
	match stext:
		itext, "": $Showcase.text = itext
		_: $Showcase.text = stext; _on_showcase_text_changed("")
		
	
@onready var lock_open_sfx: AudioStreamWAV = preload("res://scenes/editor/edit_file_name/lock_button/lock_closed_sfx.wav")
@onready var lock_closed_sfx: AudioStreamWAV = preload("res://scenes/editor/edit_file_name/lock_button/lock_open_sfx.wav")
	
func on_play_lock_open_sound_effect(): AudioMaster.play_sfx(lock_open_sfx, -15)
func on_play_lock_closed_sound_effect(): AudioMaster.play_sfx(lock_closed_sfx)

func _on_text_submitted(__: String):
	$Internal.release_focus()
	$Showcase.release_focus()
	text_submitted.emit()
