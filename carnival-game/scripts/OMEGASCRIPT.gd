extends Node2D

@onready var knife = $knife
@onready var knifehandle = $knife/Knifehandle
@onready var knifeblade = $knife/Knife
@onready var knifetimer = $knife/knifetimer
@onready var outline = $outline
@onready var redx = $Redx

var prevmousepos = Vector2(0.0, 0.0)
var cutting = true

func _ready():
	Input.set_mouse_mode(1)

func _input(_event):
	
	# knife stuff
	knife.global_position = get_global_mouse_position()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cutting:
		knifeblade.hide()
		knifehandle.show()
		if prevmousepos.distance_to(get_global_mouse_position())>20 and cutting:
			var angle = prevmousepos.angle_to_point(get_global_mouse_position()) - PI/2
			knifehandle.rotation = angle
			outline.add_point(get_global_mouse_position())
			prevmousepos = get_global_mouse_position()
	elif Input.is_action_just_released("cutting") and cutting:
		cutting = false
		knifeblade.show()
		knifehandle.hide()
		evaluate()

func evaluate():
	if true: # add actual evaluation logic here
		await get_tree().create_timer(2.0).timeout
		redx.show()
		$AudioStreamPlayer2D.play()
		await get_tree().create_timer(2.0).timeout
		redx.hide()
		outline.clear_points()
		cutting = true
