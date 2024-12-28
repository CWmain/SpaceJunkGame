extends RigidBody2D


const SPEED = 300.0
const STOP_SPEED = 300.0
const ROTATION_SPEED = PI/64
const JUMP_VELOCITY = -100.0
const THRUST_VELOCITY = Vector2(0,-10)

@onready var cutting_tool = $CuttingTool
@onready var collision_polygon = $CuttingTool/CollisionPolygon
@onready var tether = $Tether
@onready var player_rocket = $"."

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")
var tetherSet = false
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
	if Input.is_action_pressed("Accelerate"):
		linear_velocity += THRUST_VELOCITY.rotated(rotation)
		
	if Input.is_action_pressed("Stop"):
		linear_velocity.x = move_toward(linear_velocity.x, 0, STOP_SPEED)
		linear_velocity.y = move_toward(linear_velocity.y, 0, STOP_SPEED)
		angular_velocity = move_toward(angular_velocity, 0, STOP_SPEED)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var rot = Input.get_axis("TurnLeft", "TurnRight")
	if rot:
		rotate(rot * ROTATION_SPEED)
		
	if (tether.is_colliding()):
		tetherSet = true
		on_tether()
		
		
		


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
		#NOTICE: I think my area formula is wrong???
		for overlapping in intersection:
			#region Localise Polygon and find its area
			var leftSide = 0
			var rightSide = 0 
			var localOverLapping = overlapping.duplicate()
			for i in range(localOverLapping.size()):			
				localOverLapping[i] = entity.to_local(localOverLapping[i])
				
				if (i > 0):
					leftSide += localOverLapping[i].x * localOverLapping[i-1].y
					rightSide += localOverLapping[i-1].x * localOverLapping[i].y
				
			leftSide += localOverLapping[0].x * localOverLapping[localOverLapping.size()-1].y
			rightSide += localOverLapping[localOverLapping.size()-1].x * localOverLapping[0].y
			var area = abs(leftSide-rightSide)/2
			#endregion	
			print("Area: ", area)
			
			#Finds the percent that the overlap is of the original
			var percent = area / entity.area
			print("Percent: ", percent)
			
			var splitAsteroid: Asteroid = asteroid.instantiate()
			
			get_tree().get_root().add_child(splitAsteroid)
			#TODO: Consider calculating mass for each asteroid
			#region Apply attributes to asteroid
			splitAsteroid.set_area(area)
			splitAsteroid.set_mass(entity.get_mass()*percent)
			print("Mass: ", splitAsteroid.get_mass())
			splitAsteroid.set_transform(entity.transform)
			splitAsteroid.set_linear_velocity(entity.get_linear_velocity())
			splitAsteroid.set_angular_velocity(entity.get_angular_velocity())
			splitAsteroid.set_polygons(localOverLapping)
			#endregion
			print("\n NEW \n")
		
		entity.queue_free()

func on_tether():
	print("Tethered")
	var collidedAsteroid : Asteroid = tether.get_collider()
	# Ensure that a valid asteroid is detected
	if (collidedAsteroid == null):
		return
		
	# Get a vector to move from current position towards ship
	var asteroidPosition : Vector2 = collidedAsteroid.to_global(collidedAsteroid.position)
	var shipPosition: Vector2 = to_global(position)
	
	# TODO: Adjust how shift is calculated to get the asteroid moving towards the ship correctly
	# Consider shooting a physics object which stores the asteroid you want to pull, it breaks beyond a certain distance
	var shift : Vector2 = shipPosition - asteroidPosition
	shift = shift
	collidedAsteroid.apply_force(shift, Vector2.ZERO)
	#collidedAsteroid.set_linear_velocity(shift)
	#tether.get_collider().set_linear_velocity(Vector2(0,0))

