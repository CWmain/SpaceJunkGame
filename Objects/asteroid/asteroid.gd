class_name Asteroid
extends RigidBody2D

## Variable to control how small an asteroid can get
const MIN_ASTEROID_SIZE = 1000

@onready var hit_box : CollisionPolygon2D = $HitBox
@onready var visual : Polygon2D = $Visual

var area;

#TODO: When created they should move away from the cutting tool, not sure where to place logic


# Called when the node enters the scene tree for the first time.
func _ready():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_area(i):
	area = i

## Sets the collision and visual polygon of Asteroid
func set_polygons(p: PackedVector2Array):
	if (p == null):
		return
	hit_box.set_polygon(p)
	visual.set_polygon(p)
	
