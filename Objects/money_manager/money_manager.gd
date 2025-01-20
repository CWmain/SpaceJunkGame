extends Node

@export var collectors: Array[Collector]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to each collectors signal
	for c in collectors:
		c.scoreSignal.connect(_on_score_signal)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_score_signal(id, s):
	print("MM working for %s" % [id])
