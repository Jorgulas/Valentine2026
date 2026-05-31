extends CharacterBody2D

# This will hold the specific "LetterData" resource (Letter 1, Letter 2, etc.)
@export var letter_resource: LetterData 

@onready var sprite = $Sprite2D # Make sure this matches your node name

const SPEED = 40.0
var direction = 1 # 1 = Right, -1 = Left

func _physics_process(delta):
	# 1. Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Movement
	velocity.x = direction * SPEED

	# 3. Handle collisions
	move_and_slide()

	# 4. Bounce off walls like Mario!
	if is_on_wall():
		direction *= -1


var can_pickup = false

func _ready():
	if letter_resource == null:
		# This will turn the letter BRIGHT RED in the editor if it's broken
		modulate = Color.RED 
		print("DEBUG: This letter spawned with no data!")
	else:
		# Set the texture so we know it worked
		$Sprite2D.texture = letter_resource.letter_sprite
		
	# Ignore physical collisions with the player so it doesn't stand on Jheny's head
	for p in get_tree().get_nodes_in_group("player"):
		add_collision_exception_with(p)
		
	# Wait brief moment before it can be picked up
	await get_tree().create_timer(0.4).timeout
	can_pickup = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not can_pickup:
		return
		
	# Check if the thing that touched us is in the "player" group
	print("Something touched me: ", body.name)
	if body.is_in_group("player"):
		print("It was the player!")
		$PickupSound.play()
		GameManager.add_mushroom()
		
		# Check if the resource actually exists before adding it
		if letter_resource != null:
			GameManager.add_letter(letter_resource)
			queue_free()
		else:
			print("CRITICAL ERROR: This letter has no Data Resource assigned!")
			queue_free() # Remove it anyway so it doesn't just sit there
		
		# 3. Vanish
		queue_free() # Remove the mushroom from the game
