extends AnimatableBody2D

@export var lift_height: float = -32.0 # How far UP it goes
@export var lift_duration: float = 4.0 # How long the lift animation takes
@export var required_wait_time: float = 3.0 # 10 seconds

var wait_timer: float = 0.0
var player_in_area: bool = false
var is_activated: bool = false
var activated_position_saved: bool = false

# Create a unique key for this block so we can save its state in GameManager
@onready var save_key = "douguinho_block_" + str(global_position) + "_" + name

func _ready():
	# Check if this specific block was already activated in a previous session or moment
	if GameManager and GameManager.has_method("is_douguinho_activated"):
		if GameManager.is_douguinho_activated(save_key):
			# Instantly move it to the lifted position!
			global_position.y += lift_height
			is_activated = true
			activated_position_saved = true

func _physics_process(delta):
	# Don't do anything if it's already finished lifting
	if is_activated: 
		modulate = Color.WHITE
		return
		
	if player_in_area:
		wait_timer += delta
		
		# VISUAL FEEDBACK: Block turns greener as the timer goes up
		var progress = wait_timer / required_wait_time
		modulate = Color(1.0 - progress, 1.0, 1.0 - progress)
		
		if wait_timer >= required_wait_time:
			activate_lift()
	else:
		# VISUAL FEEDBACK: Return to normal (or red if they stepped off)
		if wait_timer > 0.0:
			modulate = Color(1.0, 0.5, 0.5) # Turns slightly red when paused!
		else:
			modulate = Color.WHITE

func activate_lift():
	is_activated = true
	
	# Animate it going up using a Tween
	var tween = create_tween()
	var target_pos = global_position + Vector2(0, lift_height)
	
	tween.tween_property(self, "global_position", target_pos, lift_duration).set_trans(Tween.TRANS_SINE)
	
	# Save it forever in GameManager
	if GameManager and GameManager.has_method("save_douguinho_state"):
		GameManager.save_douguinho_state(save_key)

# Connect these signals from an Area2D!
func _on_detection_area_body_entered(body):
	print("Douguinho detected body: ", body.name)
	if body.is_in_group("player") or body.name == "Jheny" or body.name == "CharacterBody2D":
		player_in_area = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player") or body.name == "Jheny" or body.name == "CharacterBody2D":
		player_in_area = false
