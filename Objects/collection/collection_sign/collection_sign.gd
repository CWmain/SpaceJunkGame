extends Polygon2D

@onready var label = $Label

@export var pixel_counter: SubViewport

var totalSpawned: Dictionary = {"r":0,"g":0,"b":0}
var collectedRed : int
var collectedGreen : int
var collectedBlue : int
# Called when the node enters the scene tree for the first time.
func _ready():
	assert(pixel_counter != null)
	pixel_counter.scoreSignal.connect(_on_score_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_score_signal(id: String, s : Dictionary):
	if (id == "Spawner"):
		for key in totalSpawned.keys():
			totalSpawned[key] += s[key]
	#TODO: Subtract score when wrong color in wrong section
	elif(id == "Red"):
		collectedRed += s["r"]
	elif(id == "Green"):
		collectedGreen += s["g"]
	elif(id == "Blue"):
		collectedBlue += s["b"]
	
	# Create the text to display
	var toDisplay: String = "Total Spawned: %s\nRed: %s\nGreen: %s\nBlue: %s" % [str(s), collectedRed, collectedGreen, collectedBlue]
	
	label.set_text(toDisplay)
