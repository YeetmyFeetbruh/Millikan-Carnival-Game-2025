extends Node2D
@onready var knife: Node2D = self
@onready var knifehandle = $Knifehandle
@onready var knifeblade = $Knife
@onready var knifetimer = $knifetimer
@onready var outline = $"../outline"
@onready var redx = $"../Redx"
@onready var path: Path2D = $"../Path"
const ACCURACY_GRADIENT = preload("uid://7kncgva66po5")

@export var max_distance = 50.0

var mouse_pos: Vector2
var prevmousepos: Vector2
var cutting = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func _process(_delta):
	mouse_pos = get_global_mouse_position()
	knife.global_position = mouse_pos

func _input(_event):
	# knife stuff
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cutting:
		knifeblade.hide()
		knifehandle.show()
		if prevmousepos.distance_to(mouse_pos)>20 and cutting:
			var angle = prevmousepos.angle_to_point(mouse_pos) - PI/2
			knifehandle.rotation = angle
			outline.add_point(mouse_pos)
			prevmousepos = mouse_pos
		evaluate()
	elif Input.is_action_just_released("cutting") and cutting:
		knifeblade.show()
		knifehandle.hide()

func evaluate():
	var dist = mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos))
	outline.self_modulate = ACCURACY_GRADIENT.sample(dist/max_distance)
	#print(dist)
	if dist > max_distance:
		fail()
		
func fail():
	cutting = false
	knifeblade.show()
	knifehandle.hide()
	await get_tree().create_timer(1.0).timeout
	redx.show()
	$"../AudioStreamPlayer2D".play()
	await get_tree().create_timer(1.0).timeout
	redx.hide()
	outline.clear_points()
	cutting = true
