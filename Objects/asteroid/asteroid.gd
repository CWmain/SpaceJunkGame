class_name Asteroid
extends RigidBody2D

## Variable to control how small an asteroid can get
const MIN_ASTEROID_SIZE = 1000

@onready var hit_box : CollisionPolygon2D = $HitBox
@onready var visual : Polygon2D = $Visual

var area = 1001;

#TODO: When created they should move away from the cutting tool, not sure where to place logic


# Called when the node enters the scene tree for the first time.
func _ready():
	set_area(calculate_area())
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if area < MIN_ASTEROID_SIZE:
		remove_asteroid()
	

func set_area(i):
	area = i

## Sets the collision and visual polygon of Asteroid
func set_polygons(p: PackedVector2Array):
	if (p == null):
		return
	hit_box.set_polygon(p)
	visual.set_polygon(p)
	
#TODO: Set up particle effect on deletion
## Plays effect and remove asteroid
func remove_asteroid():
	print("Removing Asteroid")
	queue_free()

func calculate_area():
	var leftSide = 0
	var rightSide = 0
	var poly = visual.get_polygon()
	for i in range(poly.size()):				
		if (i > 0):
			leftSide += poly[i].x * poly[i-1].y
			rightSide += poly[i-1].x * poly[i].y
		
	leftSide += poly[0].x * poly[poly.size()-1].y
	rightSide += poly[poly.size()-1].x * poly[0].y
	var sol = abs(leftSide-rightSide)/2
	return sol
