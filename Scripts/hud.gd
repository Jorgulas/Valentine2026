extends Control

@onready var label = $Label

func _ready():
	# Connect to our Global script's signal
	GameManager.count_changed.connect(_on_count_changed)
	# Set initial value
	label.text = ": " + str(GameManager.mushroom_count)

func _on_count_changed(new_count):
	label.text = ": " + str(new_count)
