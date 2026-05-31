extends StaticBody2D

# Preload the mushroom scene so we can create copies of it
#@export var mushroom_scene: PackedScene 
@onready var anim_sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer

# Drag your LetterItem.tscn here
@export var letter_item_scene: PackedScene 

# Drag the specific .tres file for THIS block here (e.g., Letter_1.tres)
@export var letter_to_spawn: LetterData 

var is_empty = false

func handle_hit():
	if is_empty:
		return
	
	is_empty = true
	$BumpSound.play()
	anim_player.play("bump")
	
	# Change texture: Switch to the 'empty' animation or frame
	anim_sprite.play("empty") 
	
	spawn_letter()


func spawn_letter():
	var item = letter_item_scene.instantiate()
	item.letter_resource = letter_to_spawn
	get_parent().add_child(item)
	# Set starting point
	item.global_position = global_position 
	item.z_index = -1
	
	# CRUCIAL: Pass the data from the block to the letter before it pops out
	item.letter_resource = letter_to_spawn
	
	# Your existing Tween logic for the "pop up" animation
	var tween = create_tween()
	var target_pos = item.global_position + Vector2(0, -16)
	tween.tween_property(item, "global_position", target_pos, 0.1)
	
	item.set_physics_process(false)
	await tween.finished
	
	# Check if the player didn't already pick it up during the 0.1s popup window!
	if is_instance_valid(item):
		item.set_physics_process(true)
		item.z_index = 0
