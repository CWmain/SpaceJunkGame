extends CharacterBody2D


const SPEED = 300.0
const STOP_SPEED = 300.0
const ROTATION_SPEED = PI/64
const JUMP_VELOCITY = -100.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the drag.
	#if not is_on_floor():
	#	velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Accelerate"):
		velocity.y = JUMP_VELOCITY
		velocity.x = 0
		velocity = velocity.rotated(rotation)
		
	if Input.is_action_pressed("Stop"):
		velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
		velocity.y = move_toward(velocity.y, 0, STOP_SPEED)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var rot = Input.get_axis("TurnLeft", "TurnRight")
	print(rot)
	if rot:
		rotate(rot * ROTATION_SPEED)


	move_and_slide()
