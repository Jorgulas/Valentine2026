extends Area2D


func _on_pickup_area_body_entered(body):
	# Check if the thing that touched us is in the "player" group
	if body.is_in_group("player"):
		GameManager.add_mushroom()
		queue_free() # Remove the mushroom from the game
