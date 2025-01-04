extends Node2D

@export var maxDistance: float = 400
@export var followSpeed: float = 500.0
@export var toFollow: Node2D

@onready var color_rect = $CanvasLayer/ColorRect

func _ready():
	pass

func _physics_process(delta):
	# Get the distance from camera to the follow target
	var curDistance = position.distance_to(toFollow.position)
	
	# Normal Speed
	if curDistance < maxDistance/2:
		cameraSpeedMult(delta)
		color_rect.material.set("shader_paramater/curve", float(10))
	# Double Speed
	elif curDistance < maxDistance:
		cameraSpeedMult(2*delta)
		color_rect.material.set("shader_parameter/curve", float(5))
	# Keeps at the maximum distance no matter what	
	else:
		position += toFollow.position - position - (position.direction_to(toFollow.position)*maxDistance)
		position = floor(position)
		color_rect.material.set("shader_paramater/curve", float(1))

## Function to easily apply multiplications of follow speed
func cameraSpeedMult(mult: float) -> void:
	position.x = floorf(move_toward(position.x, toFollow.position.x, followSpeed*mult))
	position.y = floorf(move_toward(position.y, toFollow.position.y, followSpeed*mult))
