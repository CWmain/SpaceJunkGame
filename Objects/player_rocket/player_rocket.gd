extends CharacterBody2D


const SPEED = 300.0
const STOP_SPEED = 300.0
const ROTATION_SPEED = PI/64
const JUMP_VELOCITY = -100.0

@onready var cutting_tool = $CuttingTool
@onready var collision_polygon = $CuttingTool/CollisionPolygon

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	if Input.is_action_just_pressed("Cut"):
		asteroidCut()

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

func asteroidCut():
	for entity in cutting_tool.get_overlapping_bodies():
		# TODO: Update when the proper asteroid object is made
		var tc1 : PackedVector2Array = entity.get_child(0).polygon.duplicate()
		for i in range(tc1.size()):
			tc1[i] = entity.to_global(tc1[i])
			
		var c1 : PackedVector2Array = collision_polygon.polygon.duplicate()
		for i in range(c1.size()):
			c1[i] = cutting_tool.to_global(c1[i])

		
		var intersection = Geometry2D.clip_polygons(tc1, c1)

		# TODO: Update with proper asteroid contruction rather than outline
		for overlapping in intersection:
			var intersection_polygon = Polygon2D.new()
			#intersection_polygon.transform = entity.transform
			intersection_polygon.color = Color.ROSY_BROWN
			intersection_polygon.set_polygon(overlapping)
			get_tree().get_root().add_child(intersection_polygon)
