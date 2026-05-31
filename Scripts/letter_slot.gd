extends TextureButton

var data: LetterData # This stores the specific letter's info

func set_letter(letter_data: LetterData):
	data = letter_data
	# Set the visual sprite from the resource
	$TextureRect.texture = letter_data.letter_sprite
	
	print(letter_data)


func _on_texture_rect_mouse_entered() -> void:
	z_index = 10 # Bring to front when hovered
	var tween = create_tween()
	# Transition to 1.2x size over 0.2 seconds with a 'Bounce' or 'Elastic' feel
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_texture_rect_mouse_exited() -> void:
	z_index = 0 # Reset when mouse leaves
		# Create a tween to return to normal size
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_LINEAR)
