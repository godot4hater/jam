extends Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	if gMode.endless:
		self.wait_time = 1.0
		self.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
