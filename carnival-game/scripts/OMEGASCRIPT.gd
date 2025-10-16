extends Node2D
@onready var knife = $knife
@onready var music = $sfx/music
# why no code in my omegascript

# fail and win functions in knife.gd should be moved here and called with signals

func _ready():
	print("you have 10 seconds to carve a perfect cirlce into the pumpkin or the room will fill with GYAS")
	music.play()
# idk why the knife script is basically the omegascript right now a lot of 
# its functions should be here


# finally something is here
func _on_button_pressed():
	get_tree().reload_current_scene()

# TO DO
# fix the connecting the final dot at the end cause its really hard for sum reason
# add jumpscare
