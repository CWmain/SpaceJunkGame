extends Polygon2D

@onready var label = $Label

@export var mm: Node

var totalSpawned: Dictionary = {"r":0,"g":0,"b":0}
var collectedRed : int
var collectedGreen : int
var collectedBlue : int
# Called when the node enters the scene tree for the first time.
func _ready():
	assert(mm != null)
	mm.scoreChanged.connect(_on_score_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_score_signal(s: int):

	# Create the text to display
	var toDisplay: String = "Current score: %s" % [s]
	
	label.set_text(toDisplay)
