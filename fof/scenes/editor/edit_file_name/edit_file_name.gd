extends Control
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

func _on_showcase_text_changed(__):
	showcase_text_changed = true
	
@onready var lock_open_sfx: AudioStreamWAV = preload("res://assets/UI/lock_button/lock_closed_sfx.wav")
@onready var lock_closed_sfx: AudioStreamWAV = preload("res://assets/UI/lock_button/lock_open_sfx.wav")
	
func on_play_lock_open_sound_effect(): AudioMaster.play_sfx(lock_open_sfx)
func on_play_lock_closed_sound_effect(): AudioMaster.play_sfx(lock_closed_sfx, -15)
