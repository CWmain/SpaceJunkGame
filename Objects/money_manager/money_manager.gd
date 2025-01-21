extends Node


@export var collectors: Array[Collector]
signal scoreChanged(s: Dictionary)
## Ordered rgb
signal multChange(mults: Array)
var score : int = 0

# While testing will keep a history of the score gain / loss (0,1 respectivly)
var scoreHistory : Dictionary = {"r": [0,0],"g": [0,0],"b": [0,0]}

var rMult: float = 1
var bMult: float = 1
var gMult: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to each collectors signal, must be manually added to the export array
	for c in collectors:
		c.scoreSignal.connect(_on_score_signal)

func _on_score_signal(id, s):
	if(id == "Red"):
		# Update score
		score += s["r"] * rMult
		score -= s["g"] * gMult
		score -= s["b"] * bMult
		
		# Update score history
		scoreHistory["r"][0] += s["r"] * rMult
		scoreHistory["g"][1] += s["g"] * gMult
		scoreHistory["b"][1] += s["b"] * bMult
		
		#Modify Mult
		rMult -= 0.2
		bMult += 0.1
		gMult += 0.1
		
		multChange.emit([rMult, bMult, gMult])
	elif(id == "Green"):
		# Update score
		score -= s["r"] * rMult 
		score += s["g"] * gMult
		score -= s["b"] * bMult
		
		# Update score history
		scoreHistory["r"][1] += s["r"] * rMult
		scoreHistory["g"][0] += s["g"] * gMult
		scoreHistory["b"][1] += s["b"] * bMult
		
		#Modify Mult
		rMult += 0.1
		bMult -= 0.2
		gMult += 0.1
		
		multChange.emit([rMult, bMult, gMult])
	elif(id == "Blue"):
		# Update score
		score -= s["r"] * rMult
		score -= s["g"] * gMult
		score += s["b"] * bMult
		
		# Update score history
		scoreHistory["r"][1] += s["r"] * rMult
		scoreHistory["g"][1] += s["g"] * gMult
		scoreHistory["b"][0] += s["b"] * bMult
		
		#Modify Mult
		rMult += 0.1
		bMult += 0.1
		gMult -= 0.2
		
		multChange.emit([rMult, bMult, gMult])
	print("MM working for %s" % [id])
	print("MM: ScoreHistory %s" % scoreHistory)
	scoreChanged.emit(score)
