extends Path2D

@onready var line: Line2D = $"../DashedLine"

@export var designs: Array[Curve2D] = []
var curr_design: Curve2D
const CENTER = Vector2(1000, 550)
@onready var knife: Node2D = $"../knife"


func _ready():
	knife.design_completed.connect(set_design.bind())
	set_design(0)
		
func set_design(index):
	curr_design = designs[index]
	curve = curr_design
	#curve.bake_interval = 5.0
	line.clear_points()
	for i in curr_design.point_count - 1:
		line.add_point(curr_design.get_point_position(i))
