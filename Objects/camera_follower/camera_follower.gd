extends Node2D

@export var maxDistance: float = 400
@export var followSpeed: float = 500.0
@export var toFollow: Node2D

func _ready():
	pass

func _physics_process(delta):
	# Get the distance from camera to the follow target
	var curDistance = position.distance_to(toFollow.position)
	
	# Normal Speed
	if curDistance < maxDistance/2:
		position.x = floorf(move_toward(floor(position.x), floor(toFollow.position.x), followSpeed*delta))
		position.y = floorf(move_toward(floor(position.y), floor(toFollow.position.y), followSpeed*delta))
	# Double Speed
	elif curDistance < maxDistance:
		position.x = floorf(move_toward(floor(position.x), floor(toFollow.position.x), followSpeed*delta*2))
		position.y = floorf(move_toward(floor(position.y), floor(toFollow.position.y), followSpeed*delta*2))
	# Keeps at the maximum distance no matter what	
	else:
		position += toFollow.position - position - (position.direction_to(toFollow.position)*maxDistance)
		position = floor(position)

		
	pass

##
#func cameraSpeedMult(mult: float) -> void:
	
