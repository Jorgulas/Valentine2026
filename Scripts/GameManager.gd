extends Node

signal count_changed(new_count)

@onready var chat_bubble = $ChatBubble # Make sure this matches your node name


var mushroom_count = 0:
	set(value):
		mushroom_count = value
		count_changed.emit(mushroom_count) # Tell the UI to update

func add_mushroom():
	mushroom_count += 1
	

signal inventory_updated

var collected_letters: Array[LetterData] = []

func add_letter(letter: LetterData):
	if letter and not collected_letters.has(letter):
		collected_letters.append(letter)
		inventory_updated.emit() # This triggers the UI refresh!

# --- Pillar Logic ---

signal all_pillars_solved

var pillars_solved = 0
var total_pillars = 5

func pillar_solved():
	pillars_solved += 1
	if pillars_solved >= total_pillars:
		all_pillars_solved.emit()

# --- Douguinho Block Logic ---

var activated_douguinhos = []

func save_douguinho_state(block_key: String):
	if not activated_douguinhos.has(block_key):
		activated_douguinhos.append(block_key)

func is_douguinho_activated(block_key: String) -> bool:
	return activated_douguinhos.has(block_key)
