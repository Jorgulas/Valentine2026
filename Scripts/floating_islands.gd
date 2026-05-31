extends TileMapLayer

@export var float_distance: float = 10.0 # How many pixels up and down
@export var float_speed: float = 2.0     # How many seconds per cycle

func _ready():
	start_floating()

func start_floating():
	var tween = create_tween().set_loops() # This makes it loop forever
	
	# Move Up
	tween.tween_property(self, "position:y", position.y - float_distance, float_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Move Down
	tween.tween_property(self, "position:y", position.y, float_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
