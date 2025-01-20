extends Node


@export var collectors: Array[Collector]
signal scoreChanged(s: Dictionary)

var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to each collectors signal
	for c in collectors:
		c.scoreSignal.connect(_on_score_signal)

func _on_score_signal(id, s):
	if(id == "Red"):
		score += s["r"]
	elif(id == "Green"):
		score += s["g"]
	elif(id == "Blue"):
		score += s["b"]
	print("MM working for %s" % [id])
	scoreChanged.emit(score)
