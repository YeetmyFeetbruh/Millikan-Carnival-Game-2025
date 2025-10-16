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
@onready var reward = $"../Control/Reward"
@onready var game_over = $"../Control/GameOver"
@onready var countdown = $"../Control/countdown"
@onready var timer = $"../Control/countdown/Timer"
@onready var music = $"../sfx/music"
var ACCURACY_GRADIENT = preload("uid://7kncgva66po5")

## Smallest distance where accuracy is considered 0
@export var max_distance = 50.0
## Minimum accuracy needed for a win. 0.0 = 0% 1.0 = 100%
@export_range(0.0, 1.0) var accuracy_threshold = 0.9 # changed to 90% cause game way to easy
## Distance before the knife is updated
@export var knife_dist = 20
@export var prizes:Array[String] = ["2 Dum Dums", "1 Soda", "1 Candy Bag", "Meta Quest 2"]
@export var times:Array[int] = []
var mouse_pos: Vector2
var prevmousepos: Vector2
var cutting = true
var accuracy := 0.0
var num_dists := 0
var dist_sum := 0.0
## Offset of closest point on path to where mouse was first held down
var start_offset: float
var prev_offset: float
var curr_offset: float
var correct_direction: int
var designs_completed := 0
signal design_completed(next_design_index)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	# Make gradient reflect threshold
	ACCURACY_GRADIENT.set_offset(1, (1.0 - accuracy_threshold) / 2.0) # Yellow
	ACCURACY_GRADIENT.set_offset(2, 1.0 - accuracy_threshold)         # Red
	reset()
	
func _process(_delta):
	mouse_pos = get_global_mouse_position()
	knife.global_position = mouse_pos

func _input(_event):
	if Input.is_action_just_pressed("cutting"):
		start_offset = path.curve.get_closest_offset(path.curve.get_closest_point(mouse_pos))
		prev_offset = start_offset
	# knife stuff
	if Input.is_action_pressed("cutting") and cutting:
		knifeblade.hide()
		knifehandle.show()
		if prevmousepos.distance_to(mouse_pos) > knife_dist and cutting:
			var angle = prevmousepos.angle_to_point(mouse_pos) - PI/2
			knifehandle.rotation = angle
			outline.add_point(mouse_pos)
			prevmousepos = mouse_pos
			update()
	elif Input.is_action_just_released("cutting") and cutting:
		fail()
	if Input.is_key_pressed(KEY_T):
		win()

func update():
	var dist = mouse_pos.distance_to(path.curve.get_closest_point(mouse_pos))
	# Calculate average accuracy
	num_dists += 1
	dist_sum += dist
	var average_dist = dist_sum / num_dists
	accuracy = clampf(1.0 - (average_dist / max_distance), 0.0, 1.0) # float [0.0,1.0]
	numba.text = str(snapped(accuracy * 100.0, 0.01)) + "%"
	outline.self_modulate = ACCURACY_GRADIENT.sample(1.0 - accuracy)
	# Evaluation
	curr_offset = path.curve.get_closest_offset(path.curve.get_closest_point(mouse_pos))
	var curr_direction = int(sign(curr_offset - prev_offset))
	if absf(curr_offset - prev_offset) < path.curve.get_baked_length()/2:
		if curr_direction != 0 and correct_direction == 0:
			correct_direction = curr_direction
		if prev_offset < start_offset and curr_offset >= start_offset or prev_offset > start_offset and curr_offset <= start_offset:
			if curr_direction == correct_direction:
				evaluate()
			else:
				correct_direction = curr_direction * -1
	prev_offset = curr_offset
	
func evaluate():
	if accuracy >= accuracy_threshold:
		win()
	else:
		fail()

func fail():
	music.stream_paused = true
	timer.stop()
	cutting = false
	knifeblade.show()
	knifehandle.hide()
	await get_tree().create_timer(2.0).timeout
	#jumpscare.play()
	#jumpscare.show()
	#await jumpscare.finished
	#jumpscare.hide()
	redx.show()
	$"../sfx/fail".play()
	await get_tree().create_timer(1.0).timeout
	$"../sfx/cheer".play()
	redx.hide()
	await get_tree().create_timer(1.0).timeout
	reward.show()
	reward.text = "YOU WIN: "+str(prizes[designs_completed])
	await get_tree().create_timer(2.0).timeout
	designs_completed = 0
	reward.hide()
	game_over.show()
	music.stream_paused = false

func win():
	music.stream_paused = true
	timer.stop()
	designs_completed += 1
	cutting = false
	knifeblade.show()
	knifehandle.hide()
	await get_tree().create_timer(2.0).timeout
	greenv.show()
	$"../sfx/win".play()
	await get_tree().create_timer(1.0).timeout
	music.stream_paused = false
	reset()
	if designs_completed >= path.get("designs").size():
		pass #how
	else: 
		design_completed.emit(designs_completed)
	
	
func reset():
	game_over.hide()
	redx.hide()
	greenv.hide()
	outline.clear_points()
	cutting = true
	accuracy = 0.0
	num_dists = 0
	dist_sum = 0
	numba.text = "0.00%"
	correct_direction = 0
	curr_offset = 0.0
	prev_offset = 0.0
	seconds = times[designs_completed]
	timer.start()
	

var seconds = 0
func _on_timer_timeout():
	countdown.text = str(seconds)+"s"
	seconds -= 1
	if seconds == -1:
		fail()
