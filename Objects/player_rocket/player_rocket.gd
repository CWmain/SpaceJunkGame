extends CharacterBody2D


const SPEED = 300.0
const STOP_SPEED = 300.0
const ROTATION_SPEED = PI/64
const JUMP_VELOCITY = -100.0
## Variable to control how small an asteroid can get
const MIN_ASTEROID_SIZE = 35

@onready var cutting_tool = $CuttingTool
@onready var collision_polygon = $CuttingTool/CollisionPolygon

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	if Input.is_action_just_pressed("Cut"):
		asteroidCut()

func _physics_process(_delta):
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
	if rot:
		rotate(rot * ROTATION_SPEED)


	move_and_slide()

func asteroidCut():
	for entity in cutting_tool.get_overlapping_bodies():
		# Shift both polygons into the global space so an intersection can be made
		#region Global Polygon Calculation
		var toCutPolygon : PackedVector2Array = entity.get_child(0).polygon.duplicate()
		for i in range(toCutPolygon.size()):
			toCutPolygon[i] = entity.to_global(toCutPolygon[i])			
		var cutterPolygon : PackedVector2Array = collision_polygon.polygon.duplicate()
		for i in range(cutterPolygon.size()):
			cutterPolygon[i] = cutting_tool.to_global(cutterPolygon[i])
		#endregion
		
		var intersection = Geometry2D.clip_polygons(toCutPolygon, cutterPolygon)

		#NOTICE: If preformace issues consider object pooling for asteroids
		for overlapping in intersection:
			#region Localise Polygon and find its max height and width
			var largeX: int = -9223372036854775808
			var largeY: int = -9223372036854775808
			var smallX: int = 9223372036854775807 
			var smallY: int = 9223372036854775807 
			var localOverLapping = overlapping.duplicate()
			for i in range(localOverLapping.size()):
				localOverLapping[i] = entity.to_local(localOverLapping[i])
				smallX = min(smallX, localOverLapping[i].x)
				smallY = min(smallY, localOverLapping[i].y)
				largeX = max(largeX, localOverLapping[i].x)
				largeY = max(largeY, localOverLapping[i].y)
			#endregion	
			
			print("X: ", largeX-smallX, " Y: ", largeY-smallY)
			
			#TODO: Play a shattering partile effect the emphasis destruction of asteroid
			if (largeX-smallX < MIN_ASTEROID_SIZE or largeY-smallY < MIN_ASTEROID_SIZE):
				continue
			
			var splitAsteroid: Asteroid = asteroid.instantiate()
			get_tree().get_root().add_child(splitAsteroid)
			
			#TODO: Consider calculating mass for each asteroid
			#region Apply attributes to asteroid
			splitAsteroid.set_transform(entity.transform)
			splitAsteroid.set_linear_velocity(entity.get_linear_velocity())
			splitAsteroid.set_angular_velocity(entity.get_angular_velocity())
			splitAsteroid.set_polygons(localOverLapping)
			#endregion
			
		
		entity.queue_free()

