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
	#region Gives shader current rocket position
	var currentResolution: Vector2 = get_viewport().get_visible_rect().size;
	var relativeToCamera: Vector2 = toFollow.global_position - position;
	
	# As this relative region is -960x -> 960x and -540y -> 540y, 
	# shift so the whole space so it is in the positives based on half resolution
	var relativeShiftedPositive: Vector2 = relativeToCamera+currentResolution/2;
	
	# Since shaders work in the range 0->1, divide by current resolution
	var shaderPosition : Vector2 = relativeShiftedPositive/currentResolution
	
	color_rect.material.set_shader_parameter("rocket_position", shaderPosition)
	#endregion

	# Normal Speed
	if curDistance < maxDistance/2:
		cameraSpeedMult(delta)
		color_rect.hide()

	# Double Speed
	elif curDistance < maxDistance:
		cameraSpeedMult(2*delta)
		color_rect.material.set_shader_parameter("force", 0.05)
		color_rect.show()
	# Keeps at the maximum distance no matter what	
	else:
		position += toFollow.position - position - (position.direction_to(toFollow.position)*maxDistance)
		position = floor(position)
		color_rect.material.set_shader_parameter("force", 0.1)
		color_rect.show()

## Function to easily apply multiplications of follow speed
func cameraSpeedMult(mult: float) -> void:
	position.x = floorf(move_toward(position.x, toFollow.position.x, followSpeed*mult))
	position.y = floorf(move_toward(position.y, toFollow.position.y, followSpeed*mult))
