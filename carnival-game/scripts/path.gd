extends Path2D

@export var radius = 225
@export var num_points = 32
var center = Vector2(1000, 550)
@onready var line: Line2D = $"../Line"

func _ready():
	curve = Curve2D.new()
	curve.bake_interval = 5.0
	# Generates a circle
	# TODO: Non-geometric designs will have to be created manually
	for i in num_points + 1:
		var new_point = Vector2(0, -radius).rotated(float(i)/num_points * 2*PI) + center
		curve.add_point(new_point)
		if i != num_points:
			line.add_point(new_point)
