extends Polygon2D

@onready var label = $Label

@export var pixel_counter: SubViewport
# Called when the node enters the scene tree for the first time.
func _ready():
	assert(pixel_counter != null)
	pixel_counter.scoreSignal.connect(_on_score_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_score_signal(id: String, s : Dictionary):
	var toDisplay: String = "From %s\n%s" % [id, str(s)]
	label.set_text(toDisplay)
