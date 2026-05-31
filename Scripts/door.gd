extends StaticBody2D

@onready var sprite = $DoorSprite
@onready var collision = $DoorCollision

func _ready():
	# Connect to the GameManager signal
	if GameManager:
		GameManager.all_pillars_solved.connect(open_door)

func open_door():
	# 1. Turn off collision so player can walk through
	collision.set_deferred("disabled", true)
	
	# 2. Move z-index up
	z_index = 5
	
	# 3. Change sprite to the open version
	sprite.play("open")
	$"../../BackgroundMusic".stop()
	$"../../Victory".play()
