class_name Asteroid
extends RigidBody2D

## Variable to control how small an asteroid can get
const MIN_ASTEROID_SIZE = 1000

@onready var hit_box : CollisionPolygon2D = $HitBox
@onready var visual : Polygon2D = $Visual

var templateAsteroid = preload("res://Objects/asteroid/asteroid.tscn")

var area;

## Properties should only ever be modified at initial creation
@export var properties: AsteroidProperties:
	set(value):	
		properties = value
		if (value == null):
			return
		if (hit_box != null and visual != null):
			set_polygons(properties.shape)
			visual.texture_offset = properties.textureOffest
			visual.texture_rotation = properties.textureRotation
			area = calculate_area()
			mass = properties.mass
			angular_velocity = properties.initialAngularVelocity
			linear_velocity = properties.initialLinearVelocity

			
 



#TODO: When created they should move away from the cutting tool, not sure where to place logic


# Called when the node enters the scene tree for the first time.
func _ready():
	properties = properties
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if area < MIN_ASTEROID_SIZE:
		remove_asteroid()

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

func calculate_area() -> float:
	var leftSide: float = 0
	var rightSide: float = 0
	var poly : PackedVector2Array = visual.get_polygon()
	if poly.size() == 0:
		return 0
	for i in range(poly.size()):				
		if (i > 0):
			leftSide += poly[i].x * poly[i-1].y
			rightSide += poly[i-1].x * poly[i].y
	leftSide += poly[0].x * poly[poly.size()-1].y
	rightSide += poly[poly.size()-1].x * poly[0].y
	var sol: float = abs(leftSide-rightSide)/2
	return sol

