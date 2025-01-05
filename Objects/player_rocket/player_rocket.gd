extends RigidBody2D


const STOP_SPEED = 300.0*60
const ROTATION_SPEED = (PI/64) * 60

const THRUST_VELOCITY = Vector2(0,-18000)


@onready var cutting_tool = $CuttingTool
@onready var collision_polygon = $CuttingTool/CollisionPolygon

@onready var player_rocket = $"."
@onready var tether_hook = $TetherHook
@onready var tether_spring = $TetherSpring

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")
var tetherSet = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	if Input.is_action_just_pressed("Cut"):
		tether_hook.reset_tether()
		asteroidCut()

func _physics_process(delta):
	# Add the drag.
	#if not is_on_floor():
	#	velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("Accelerate"):
		#linear_velocity += THRUST_VELOCITY.rotated(rotation)
		apply_force(THRUST_VELOCITY.rotated(rotation) * delta)

		
	if Input.is_action_pressed("Stop") and false:
		linear_velocity.x = move_toward(linear_velocity.x, 0, STOP_SPEED*delta)
		linear_velocity.y = move_toward(linear_velocity.y, 0, STOP_SPEED*delta)
		angular_velocity = move_toward(angular_velocity, 0, STOP_SPEED*delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var rot = Input.get_axis("TurnLeft", "TurnRight")
	if rot:
		rotate(rot * ROTATION_SPEED * delta)
		
	if Input.is_action_just_pressed("Tether"):
		tether_hook.fire_tether()
		


func asteroidCut():
	for entity in cutting_tool.get_overlapping_bodies():
		var entityProperties : AsteroidProperties = entity.properties

		# Shift both polygons into the global space so an intersection can be made
		#region Global Polygon Calculation
		var toCutPolygon : PackedVector2Array = entityProperties.shape.duplicate()
		for i in range(toCutPolygon.size()):
			toCutPolygon[i] = entity.to_global(toCutPolygon[i])			
		var cutterPolygon : PackedVector2Array = collision_polygon.polygon
		for i in range(cutterPolygon.size()):
			cutterPolygon[i] = cutting_tool.to_global(cutterPolygon[i])
		#endregion
		
		var intersection = Geometry2D.clip_polygons(toCutPolygon, cutterPolygon)

		#NOTICE: If preformace issues consider object pooling for asteroids
		#NOTICE: I think my area formula is wrong???
		for overlapping in intersection:
			print("OVERLAP")
			#region Localise Polygon and find its area
			var leftSide = 0
			var rightSide = 0 
			var localOverLapping = overlapping
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
			var newProperties: AsteroidProperties = AsteroidProperties.new()
			newProperties.shape = localOverLapping
			newProperties.textureOffest = entityProperties.textureOffest
			newProperties.textureRotation = entityProperties.textureRotation
			newProperties.mass = entity.get_mass()*percent
			newProperties.initialAngularVelocity = entity.get_angular_velocity()
			newProperties.initialLinearVelocity = entity.get_linear_velocity()
			splitAsteroid.properties = newProperties
			get_tree().get_root().add_child(splitAsteroid)
			splitAsteroid.transform = entity.transform

			#region Apply attributes to asteroid

			print("Area: ", splitAsteroid.area)
			print("Mass: ", splitAsteroid.get_mass())

			#splitAsteroid.set_polygons(localOverLapping)
			#endregion
			print("\n NEW \n")
		
		entity.queue_free()

