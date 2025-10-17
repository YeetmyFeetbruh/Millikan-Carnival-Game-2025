extends Node2D
@onready var knife = $knife
@onready var ambient: AudioStreamPlayer2D = $sfx/ambient
@onready var music = $sfx/music
# why no code in my omegascript

# fail and win functions in knife.gd should be moved here and called with signals

func _ready():
	print("you have 10 seconds to carve a perfect cirlce into the pumpkin or the room will fill with GYAS")
	ambient.play()

# finally something is here
func _on_button_pressed():
	print("reloading")
	get_tree().reload_current_scene()

# TO DO
# add jumpscare
