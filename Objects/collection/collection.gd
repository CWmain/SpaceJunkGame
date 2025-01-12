extends Node2D

var scoreMutex: Mutex
var scoreUpdate: bool = false
var score: Dictionary = {"r":0,"g":0,"b":0}

@onready var collection_hit_box = $CollectionHitBox
#@onready var pixel_counter = $pixelCounter
@onready var scoreSign = $Sign

@export var pixel_counter: SubViewport


func _ready():
	scoreMutex = Mutex.new()
	
	# TODO: Sign can be moved out of collection into its own node since there is now one common
	# Connect the singal update to update the sign
	pixel_counter.scoreSignal.connect(_on_score_signal)

func _process(_delta):
	if Input.is_action_just_pressed("PlacePoint"):
		print(score)
	

	
func _on_collection_hit_box_body_entered(_body):
	collectAsteroid()

func collectAsteroid() -> void:
	var toCollect : Array[Node2D] = collection_hit_box.get_overlapping_bodies()
	for ast in toCollect:
		# Prevents collection if the hook is still attached to the asteroid
		if ast.get_node_or_null("TetherHook") != null:
			continue
		
		var visualPoly: Polygon2D = ast.visual
		pixel_counter.visualPolygonImageGenerator(visualPoly)
		
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

func _on_score_signal():
	scoreSign.label.set_text(str(pixel_counter.score))
	
