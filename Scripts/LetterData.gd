extends Resource
class_name LetterData

@export var letter_sprite: Texture2D  # The image of the letter
@export var question_text: String      # The clue/question
@export var correct_answer: String    # The magic word for the pillar
@export var letter_id: int            # To match it to a specific pillar
