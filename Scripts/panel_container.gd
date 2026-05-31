extends PanelContainer

@onready var label = $Label
@onready var timer = $Timer

func _ready():
	hide() # Hide at the start

func pop_up(text: String):
	label.text = text
	
	# Reset scale for the "Pop" effect
	scale = Vector2.ZERO 
	show()
	
	# Create a bounce-in animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	timer.start(2.0)

func _on_timer_timeout():
	hide()
