extends RigidBody2D


const STOP_SPEED = 18000.0
const ROTATION_SPEED = (PI/64) * 60 * 1.5

const THRUST_VELOCITY = Vector2(0,-18000)
const DRAG_FORCE = 60.0

@export var PUSH_FORCE: float = 1000
var canPush: bool = true

@export var BOOST: float = 300
var canBoost: bool = true

@onready var cutting_tool = $CuttingTool
@onready var collision_polygon = $CuttingTool/CollisionPolygon

@onready var player_rocket = $"."
@onready var tether_hook = $TetherHook

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")
var bullet = preload("res://Objects/mine_bullet/mine_bullet.tscn")

var tetherSet = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	if Input.is_action_just_pressed("Cut"):
		tether_hook.reset_tether()
		asteroidCut()
		shootBullet()

func _physics_process(delta):
	#print("PR: Linear Velocity = %s" % [linear_velocity])
	# Add drag
	rocketDrag(delta)
	
	if Input.is_action_pressed("Accelerate"):
		#linear_velocity += THRUST_VELOCITY.rotated(rotation)
		rocketForwards(delta)

		
	if Input.is_action_pressed("Boost") and canBoost:
		rocketBoost()

	if Input.is_action_pressed("Push") and canPush:
		asteroidPush()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var rot = Input.get_axis("TurnLeft", "TurnRight")
	if rot:
		rotate(rot * ROTATION_SPEED * delta)
		
	if Input.is_action_just_pressed("Tether"):
		tether_hook.fire_tether()
	
	
	
func rocketDrag(delta: float) -> void:
	var dragForce : Vector2 = linear_velocity.normalized()*DRAG_FORCE*-delta
	
	if abs(dragForce) > abs(linear_velocity):
		linear_velocity = Vector2.ZERO
	else:
		linear_velocity += dragForce


func rocketForwards(delta:float) -> void:
	var forceToApply: Vector2 = THRUST_VELOCITY.rotated(rotation)
	var turningAngle: float = linear_velocity.angle_to(forceToApply)

	# When attempting to change direction apply a greater force to allow for quicker accelaration
	if (turningAngle > 3*PI/4 or turningAngle < -3*PI/4):
		apply_force(forceToApply * 2 * delta)

	# Currently always apply the fowards force as it has no negative affect on the above
	apply_force(forceToApply * delta)

	
func rocketBoost() -> void:
	canBoost = false
	apply_impulse(Vector2(0,-BOOST).rotated(rotation))
	print("a")

func asteroidCut() -> void:
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

func shootBullet() -> void:
	var newBullet = bullet.instantiate()
	newBullet.transform = transform
	get_tree().get_root().add_child(newBullet)
	pass

func asteroidPush() -> void:
	canPush = false
	print("asteroidPush: Attempting Push")
	for entity in cutting_tool.get_overlapping_bodies():
		# Get the vector from the rocket to the asteroid
		var directionVector : Vector2 = (entity.position - position).normalized()
		entity.apply_impulse(directionVector*PUSH_FORCE)

func _on_timer_timeout():
	canBoost = true


func _on_push_timer_timeout():
	canPush = true
