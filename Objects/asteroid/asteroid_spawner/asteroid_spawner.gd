extends Node2D

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")
var def = preload("res://Objects/asteroid/base_asteroids/default.tres")
var star = preload("res://Objects/asteroid/base_asteroids/star.tres")

#TODO: Consider moving random to singelton so seeds may be used and consistent
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _process(_delta):

	if get_tree().get_nodes_in_group("Asteroid").size() < 2:
		var newAsteroid: Asteroid = asteroid.instantiate()
		var newProperties: AsteroidProperties
		
		# We duplicate to avoid issues of editing the base shape
		if rng.randf() > 0.5:
			newProperties = def.duplicate()
		else:
			newProperties = star.duplicate()


		get_tree().get_root().add_child(newAsteroid)

		#region Apply attributes to asteroid
		print(newAsteroid.area)
		newAsteroid.position = position
		newAsteroid.properties = newProperties
		newAsteroid.area = 1001
		newAsteroid.mass = 100
		print("Mass: ", newAsteroid.get_mass())
