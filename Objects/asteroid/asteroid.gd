extends RigidBody2D

@onready var hit_box = $HitBox
@onready var visual = $Visual

#TODO: When created they should move away from the cutting tool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Sets the collision and visual polygon of Asteroid
func setPolygons(p: PackedVector2Array):
	hit_box.polygon = p
	visual.polygon = p
	
