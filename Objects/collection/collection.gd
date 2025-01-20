extends Node2D
class_name Collector

@onready var collection_hit_box = $CollectionHitBox
@onready var pixel_counter = $pixelCounter

@export var myID : String = "ERROR"
signal scoreSignal(id : String, s: Dictionary)
@onready var label = $Label


func _ready():
	assert(myID != "ERROR")
	label.text = myID

func _process(_delta):
	pass
	

	
func _on_collection_hit_box_body_entered(_body):
	collectAsteroid()

func collectAsteroid() -> void:
	var toCollect : Array[Node2D] = collection_hit_box.get_overlapping_bodies()
	for ast in toCollect:
		# Prevents collection if the hook is still attached to the asteroid
		if ast.get_node_or_null("TetherHook") != null:
			continue
		
		var visualPoly: Polygon2D = ast.visual
		pixel_counter.countPolygonPixels(myID, visualPoly)
		
		# Free the asteroid
		ast.queue_free()
	
func printAllPixels(myImage: Image):
	var dict = {}
	for i in range(0,300):
		for j in range(0,300):
			if dict.has(myImage.get_pixel(i,j)):
				dict[myImage.get_pixel(i,j)] += 1
			else:
				dict[myImage.get_pixel(i,j)] = 1
	for key in dict.keys():
		if dict[key] > 200:
			print(key, ": ", dict[key])
	


func _on_pixel_counter_score_signal(id, s):
	print("%s recived\nvalues = %s" % [id, str(s)])
	# Re-emit signal from collector to moneyManager
	scoreSignal.emit(id,s)
