extends Node


@export var collectors: Array[Collector]
signal scoreChanged(s: Dictionary)

var score : int = 0

# While testing will keep a history of the score gain / loss (0,1 respectivly)
var scoreHistory : Dictionary = {"r": [0,0],"g": [0,0],"b": [0,0]}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to each collectors signal
	for c in collectors:
		c.scoreSignal.connect(_on_score_signal)

func _on_score_signal(id, s):
	if(id == "Red"):
		score += s["r"]
		score -= s["g"]
		score -= s["b"]
		scoreHistory["r"][0] += s["r"]
		scoreHistory["g"][1] += s["g"]
		scoreHistory["b"][1] += s["b"]
	elif(id == "Green"):
		score -= s["r"]
		score += s["g"]
		score -= s["b"]
		scoreHistory["r"][1] += s["r"]
		scoreHistory["g"][0] += s["g"]
		scoreHistory["b"][1] += s["b"]
	elif(id == "Blue"):
		score -= s["r"]
		score -= s["g"]
		score += s["b"]
		scoreHistory["r"][1] += s["r"]
		scoreHistory["g"][1] += s["g"]
		scoreHistory["b"][0] += s["b"]
	print("MM working for %s" % [id])
	print("MM: ScoreHistory %s" % scoreHistory)
	scoreChanged.emit(score)
