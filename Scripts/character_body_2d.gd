extends CharacterBody2D

const WALK_SPEED = 150.0
const RUN_SPEED = 230.0
const JUMP_VELOCITY = -320.0
const TERMINAL_VELOCITY = 700.0 # Max falling speed
const SPEED = 100.0
var after_jump = false
var is_running = false
var can_move: bool = true
var speed_multiplier: float = 1.0

@onready var shadow_ray = $shadowRay
@onready var shadow_sprite = $shadow
@onready var sprite = $jenny
@onready var head_ray = $head2jump

@onready var chat_bubble = $VBoxContainer/ChatBubble



func _ready():
	# Connect to the global signal we made earlier
	GameManager.count_changed.connect(_on_mushroom_collected)

func _on_mushroom_collected(new_count):
	var messages = [
		"Delicious!",
		"Another one!",
		"I feel stronger!",
		"Mushroom power! I am cool the strongest and biggest bubble chat ever, ahhahah nothing stops me now. Yo when will I stop appearing yo WHAT IM STILL GOING HELP AAAHHHHHH... ah ok its done"
	]
	# Pick a random message from the list
	var random_text = messages[randi() % messages.size()]
	
	chat_bubble.pop_up(random_text + "\n(Total: " + str(new_count) + ")")

func _physics_process(delta: float) -> void:
	if not can_move:
		# Reset velocity so the player stops instantly when typing starts
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		after_jump = true
		$JumpSound.play()
	
	var current_speed = WALK_SPEED * speed_multiplier
	if Input.is_action_pressed("run"): # You'll need to add "run" to Input Map (e.g., Shift)
		if not is_running and is_on_floor():
			is_running = true
			$RunSound.play()
		current_speed = RUN_SPEED * speed_multiplier
	
	# Add the gravity.
	if not is_on_floor():
		var gravity = get_gravity()
		
		# If player releases jump early, fall faster (Variable Jump Height)
		if velocity.y < 0 and not Input.is_action_pressed("ui_accept"):
			gravity *= 3 # "Heavy" fall when button released
		
		velocity += gravity * delta
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)
	
	else: 
		if after_jump:
			$FallSound.play()
			after_jump = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		# lerp makes the speed build up gradually
		velocity.x = move_toward(velocity.x, direction * current_speed, 15)
	else:
		# move_toward with a small value creates that "sliding" stop
		velocity.x = move_toward(velocity.x, 0, 10)

	move_and_slide()
	update_shadow()
	update_animations()
	hit_head()
	
	
func hit_head():
	if is_on_ceiling(): # Built-in check for CharacterBody2D
		if head_ray.is_colliding():
			var collider = head_ray.get_collider()
			# Check if the object we hit has the "handle_hit" function
			if collider.has_method("handle_hit"):
				collider.handle_hit()

func update_shadow():
	var current_scale_from_height = 1
	var shadow_max_distance = 70.0 # How high until shadow disappears
	var shadow_offset_intensity = -0.2 # How much the shadow shifts horizontally
	
	if shadow_ray.is_colliding():
		shadow_sprite.visible = true
		
		# Get the exact point where the ray hits the ground
		var collision_point = shadow_ray.get_collision_point()
		
		# 1. Calculate the jump_height
		var jump_height = abs(global_position.y - collision_point.y)
		var horizontal_offset = jump_height * shadow_offset_intensity
		shadow_sprite.global_position = Vector2(
			collision_point.x, 
			collision_point.y - horizontal_offset
		)
		
		# 3. Dynamic Scaling & Transparency
		# Map the distance to a value between 0.0 and 1.0
		var falloff = clamp(1.0 - (jump_height / shadow_max_distance), 0.0, 1.0)
		
		shadow_sprite.scale = Vector2(falloff, falloff) * 1.0 # Shrinks as you rise
		shadow_sprite.modulate.a = falloff * 0.5 # Fades as you rise
		
	else:
		# Hide shadow if we are over a bottomless pit
		shadow_sprite.visible = false
		
	# 1. Match the Flip
	# If your character sprite is flipped, the shadow should be too 
	# (only useful if your shadow isn't a perfect circle)
	shadow_sprite.flip_h = !sprite.flip_h
	
	# 2. Match the "Squash" of the animation
	# If you want the shadow to get thinner when Mario moves fast
	var jump_stretch = clamp(abs(velocity.y) / 100.0, 0.0, 0.5)
	shadow_sprite.scale.x = (1.0 + jump_stretch) * current_scale_from_height
	shadow_sprite.scale.y = (1.0 - jump_stretch) * current_scale_from_height
	
	var movement_stretch = clamp(abs(velocity.x) / 500.0, 0.0, 0.5)
	shadow_sprite.scale.x = (1.0 + movement_stretch) * current_scale_from_height
	shadow_sprite.scale.y = (1.0 - movement_stretch) * current_scale_from_height
	
	
func update_animations():
	# Get the horizontal input direction again or pass it as a variable
	var direction = Input.get_axis("ui_left", "ui_right")

	# 1. AIRBORNE ANIMATIONS
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump") # Going up
		else:
			sprite.play("fall") # Going down

	# 2. GROUNDED ANIMATIONS
	else:
		if direction == 0:
			sprite.play("idle")
		else:
			if Input.is_action_pressed("run"): # Assuming you have a run action
				sprite.play("sprint")
			else:
				sprite.play("run")

	# 3. DIRECTION (Flipping)
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true


func _on_run_sound_finished() -> void:
	is_running = false
