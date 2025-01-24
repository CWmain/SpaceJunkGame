extends Node2D

const BULLET_SPEED = 400

@onready var explosion_shape = $ExplosionShape
var asteroid = preload("res://Objects/asteroid/asteroid.tscn")

func _physics_process(delta):
	position += Vector2(0,-BULLET_SPEED*delta).rotated(rotation)

func _on_detection_body_entered(body):

	if typeof(body) != typeof(Asteroid):
		# If colliding with anything else free self
		queue_free()
		return
	print("Asteroid Collision")
	var entityProperties : AsteroidProperties = body.properties

	# Shift both polygons into the global space so an intersection can be made
	#region Global Polygon Calculation
	var toCutPolygon : PackedVector2Array = entityProperties.shape.duplicate()
	for i in range(toCutPolygon.size()):
		toCutPolygon[i] = body.to_global(toCutPolygon[i])			
	var cutterPolygon : PackedVector2Array = explosion_shape.polygon
	for i in range(cutterPolygon.size()):
		cutterPolygon[i] = explosion_shape.to_global(cutterPolygon[i])
	#endregion
	
	var intersection = Geometry2D.clip_polygons(toCutPolygon, cutterPolygon)

	#NOTICE: If preformace issues consider object pooling for asteroids
	#NOTICE: I think my area formula is wrong???
	for overlapping in intersection:
		#region Localise Polygon and find its area
		var leftSide = 0
		var rightSide = 0 
		var localOverLapping = overlapping
		for i in range(localOverLapping.size()):			
			localOverLapping[i] = body.to_local(localOverLapping[i])
			
			if (i > 0):
				leftSide += localOverLapping[i].x * localOverLapping[i-1].y
				rightSide += localOverLapping[i-1].x * localOverLapping[i].y
			
		leftSide += localOverLapping[0].x * localOverLapping[localOverLapping.size()-1].y
		rightSide += localOverLapping[localOverLapping.size()-1].x * localOverLapping[0].y
		var area = abs(leftSide-rightSide)/2
		#endregion	
		print("Area: ", area)
		
		#Finds the percent that the overlap is of the original
		var percent = area / body.area
		print("Percent: ", percent)
		var splitAsteroid: Asteroid = asteroid.instantiate()
		var newProperties: AsteroidProperties = AsteroidProperties.new()
		newProperties.shape = localOverLapping
		newProperties.textureOffest = entityProperties.textureOffest
		newProperties.textureRotation = entityProperties.textureRotation
		newProperties.mass = body.get_mass()*percent
		newProperties.initialAngularVelocity = body.get_angular_velocity()
		newProperties.initialLinearVelocity = body.get_linear_velocity()
		splitAsteroid.properties = newProperties
		get_tree().get_root().add_child(splitAsteroid)
		splitAsteroid.transform = body.transform

		#region Apply attributes to asteroid

		print("Area: ", splitAsteroid.area)
		print("Mass: ", splitAsteroid.get_mass())

		#splitAsteroid.set_polygons(localOverLapping)
		#endregion
		print("\n NEW \n")
	
	body.queue_free()
	queue_free()
