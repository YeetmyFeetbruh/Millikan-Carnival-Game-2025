extends Node2D
@onready var knife: Node2D = self
@onready var knifehandle = $Knifehandle
@onready var knifeblade = $Knife
@onready var knifetimer = $knifetimer
@onready var outline = $"../outline"
@onready var redx = $"../Redx"
@onready var greenv = $"../Greenv"
@onready var path: Path2D = $"../Path"
@onready var jumpscare = $"../Control/VideoStreamPlayer"
@onready var numba: Label = $"../Control/Accuracy/numba"
const ACCURACY_GRADIENT = preload("uid://7kncgva66po5")

## Smallest distance where accuracy is considered 0
@export var max_distance = 50.0
## Minimum accuracy needed for a win. 0.0 = 0% 1.0 = 100%
@export_range(0.0, 1.0) var accuracy_threshold = 0.8 
var mouse_pos: Vector2
var prevmousepos: Vector2
var cutting = true
var accuracy := 0.0
var num_dists := 0
var dist_sum := 0.0

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
			outline.add_point(mouse_pos) # do we need this outline anymore?
			prevmousepos = mouse_pos
		update()
	elif Input.is_action_just_released("cutting") and cutting:
		knifeblade.show()
		knifehandle.hide()
		evaluate()

func update():
	var dist = mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos))
	#if dist > max_distance:
		#fail()
	# Calculate average accuracy
	num_dists += 1
	dist_sum += dist
	var average_dist = dist_sum / num_dists
	accuracy = clampf(1.0 - (average_dist / max_distance), 0.0, 1.0) # float [0.0,1.0]
	numba.text = str(snapped(accuracy * 100.0, 0.01)) + "%"
	outline.self_modulate = ACCURACY_GRADIENT.sample(dist/max_distance)
	
# TODO: evaluate when the cursor reaches where it started
func evaluate():
	if accuracy >= accuracy_threshold:
		win()
	else:
		fail()
	

func fail():
	cutting = false
	knifeblade.show()
	knifehandle.hide()
	await get_tree().create_timer(2.0).timeout
	jumpscare.play()
	jumpscare.show()
	await jumpscare.finished
	jumpscare.hide()
	#redx.show()
	#$"../sfx/fail".play()
	#await get_tree().create_timer(1.0).timeout
	reset()

func win():
	cutting = false
	knifeblade.show()
	knifehandle.hide()
	await get_tree().create_timer(2.0).timeout
	greenv.show()
	$"../sfx/win".play()
	await get_tree().create_timer(1.0).timeout
	reset()
	
func reset():
	redx.hide()
	greenv.hide()
	outline.clear_points()
	cutting = true
	accuracy = 0.0
	num_dists = 0
	dist_sum = 0
	numba.text = "0.00%"
