extends CharacterBody2D

var has_triggered_ending = false
var in_zone = false
var original_zoom = Vector2(1, 1)
var overlay_showing = false

func _on_zone_music_area_body_entered(body: Node2D) -> void:
	if in_zone or has_triggered_ending:
		return
		
	if body.is_in_group("player"):
		in_zone = true
		
		if "speed_multiplier" in body:
			body.speed_multiplier = 0.5
		
		# 1. Zoom Camera
		var cam = body.get_node("Camera2D")
		if cam:
			original_zoom = cam.zoom
			var tween = create_tween()
			var target_zoom = cam.zoom * 2 # Zoom in 50% closer
			tween.tween_property(cam, "zoom", target_zoom, 3.0).set_trans(Tween.TRANS_SINE)
			
		# 2. Stop level music
		var music_tween = create_tween()
		music_tween.tween_property($"../Victory", "volume_db", -80.0, 2.0)
		music_tween.tween_callback($"../Victory".stop)
		music_tween.tween_property($"../BackgroundMusic", "volume_db", -80.0, 2.0)
		music_tween.tween_callback($"../BackgroundMusic".stop)
		
		
		# 3. Start Garden music
		$Garden.volume_db = -80.0
		$Garden.play()
		var in_tween = create_tween()
		in_tween.tween_property($Garden, "volume_db", 16.481, 2.0)

func _on_zone_music_area_body_exited(body: Node2D) -> void:
	if not in_zone or has_triggered_ending:
		return
		
	if body.is_in_group("player"):
		in_zone = false
		
		if "speed_multiplier" in body:
			body.speed_multiplier = 1.0
			
		# 1. Revert Zoom
		var cam = body.get_node("Camera2D")
		if cam:
			var tween = create_tween()
			tween.tween_property(cam, "zoom", original_zoom, 3.0).set_trans(Tween.TRANS_SINE)
			
		# 2. Fade out Garden music
		var out_tween = create_tween()
		out_tween.tween_property($Garden, "volume_db", -80.0, 2.0)
		out_tween.tween_callback($Garden.stop)
		
		# 3. Fade in level music
		$"../BackgroundMusic".play()
		var music_tween = create_tween()
		music_tween.tween_property($"../BackgroundMusic", "volume_db", 0.0, 2.0) # assuming default is 0.0

			
func _on_interact_area_body_entered(body: Node2D) -> void:
	if has_triggered_ending:
		return
		
	if body.is_in_group("player"):
		has_triggered_ending = true
		
		# 1. Hide the playable player body
		body.hide()
		body.set_physics_process(false)
		
		$bubblepop.play()
		# 2. Play the Jheny "sentada" fake sprite
		var jheny_sprite = $Jheny
		jheny_sprite.play("sentada")
		
		# 3. After 5 seconds, fade in the final message overlay
		await get_tree().create_timer(5.0).timeout
		var img = $EndingOverlay/FinalMessageRect
		var lbl = $EndingOverlay/FinalMessage
		var fade_tween = create_tween().set_parallel(true)
		fade_tween.tween_property(img, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE)
		fade_tween.tween_property(lbl, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE)
		await fade_tween.finished
		overlay_showing = true
		print("Cinematic ending triggered!")

func _unhandled_input(event: InputEvent) -> void:
	if not overlay_showing:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		overlay_showing = false
		var img = $EndingOverlay/FinalMessageRect
		var lbl = $EndingOverlay/FinalMessage
		var out_tween = create_tween().set_parallel(true)
		out_tween.tween_property(img, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_SINE)
		out_tween.tween_property(lbl, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_SINE)
		$kisses.play()
