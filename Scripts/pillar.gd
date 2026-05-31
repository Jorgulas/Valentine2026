extends Node2D

@export var required_answer: String # Set this in the Inspector for each pillar
@onready var line_edit = $AnimatedSprite2D/LineEdit
@onready var anim_sprite = $AnimatedSprite2D

var player_nearby = false
var is_solved = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_nearby = true

func _input(event):
	if is_solved: return
	
	if player_nearby and event.is_action_pressed("interact"): # Create an "interact" action in Input Map
		line_edit.show()
		line_edit.grab_focus()

func _on_line_edit_text_submitted(new_text):
	if new_text.to_lower() == required_answer.to_lower():
		open_pillar()
		$correct.play()
	else:
		print("Wrong")
		$wrong.play()
		line_edit.hide()

func open_pillar():
	print("Pillar Activated!")
	is_solved = true
	
	# Trigger animation/lights here
	line_edit.hide()
	
	# Change the sprite to the "solved" pillar3 sprite
	anim_sprite.stop()
	anim_sprite.play("activated")
	
	# Tell the GameManager this pillar is done
	GameManager.pillar_solved()


@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	# Connect signals to detect when the player clicks the box
	line_edit.focus_entered.connect(_on_typing_started)
	line_edit.focus_exited.connect(_on_typing_ended)
	
	# Also stop typing if they press "Enter"
	line_edit.text_submitted.connect(func(_text): line_edit.release_focus())

func _on_typing_started():
	if player:
		player.can_move = false

func _on_typing_ended():
	if player:
		player.can_move = true
