extends RigidBody2D


const SPEED = 300.0
const STOP_SPEED = 300.0
const ROTATION_SPEED = PI/64
const JUMP_VELOCITY = -100.0
const THRUST_VELOCITY = Vector2(0,-300)
const TETHER_FORCE = 100

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

func _physics_process(_delta):
	# Add the drag.
	#if not is_on_floor():
	#	velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("Accelerate"):
		#linear_velocity += THRUST_VELOCITY.rotated(rotation)
		apply_force(THRUST_VELOCITY.rotated(rotation), Vector2.ZERO)

		
	if Input.is_action_pressed("Stop"):
		linear_velocity.x = move_toward(linear_velocity.x, 0, STOP_SPEED)
		linear_velocity.y = move_toward(linear_velocity.y, 0, STOP_SPEED)
		angular_velocity = move_toward(angular_velocity, 0, STOP_SPEED)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var rot = Input.get_axis("TurnLeft", "TurnRight")
	if rot:
		rotate(rot * ROTATION_SPEED)
		
	if Input.is_action_just_pressed("Tether"):
		tether_hook.fire_tether()
		


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
	


func _on_tether_hook_body_entered(body):
	if (body == null):
		return
	var tether_length = tether_hook.position.distance_to(player_rocket.position)
	var tether_angle = tether_hook.position.angle_to(player_rocket.position)
	#tether_spring.set_length(tether_length)
	#tether_spring.set_rotation(tether_angle)
	tether_spring.node_a = get_path_to(self)
	tether_spring.node_b = get_path_to(body)
	pass # Replace with function body.
