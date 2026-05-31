extends Control

# These now work because Bag and InventoryMenu are CHILDREN of this node

@onready var inventory_menu = %InventoryMenu
@onready var bag_sprite = %Bag
@onready var grid = %GridContainer
@onready var question_label = $InventoryMenu/Label

var slot_scene = preload("res://Scenes/letter_slot.tscn")

func _ready():
	
	# Connect to your Autoload Manager
	if GameManager:
		GameManager.inventory_updated.connect(refresh_inventory)
	
	refresh_inventory()

func toggle_inventory():
	inventory_menu.visible = !inventory_menu.visible
	if inventory_menu.visible:
		refresh_inventory()

# --- Visual Interactions ---

func _on_mouse_entered():
	bag_sprite.play("open")

func _on_mouse_exited():
	bag_sprite.play_backwards("open") 

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_inventory()

# --- Grid Logic ---
func refresh_inventory():
	if grid == null: return
	
	for child in grid.get_children():
		child.queue_free()
	
	# Pull the data from your Autoload Manager
	for letter in GameManager.collected_letters:
		var new_slot = slot_scene.instantiate()
		grid.add_child(new_slot)
		new_slot.set_letter(letter)
		new_slot.z_index = new_slot.get_index() # Increment z-index based on position

func display_question(text: String):
	question_label.text = text
