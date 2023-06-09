class_name MessageBox extends TextureRect

var textChild: RichTextLabel
var nextArrow: TextureRect
var children: Array

var textSpeed: float = 30.0 # characters per second
var textTimer: float = 0.0
# placeholders are placeholders
var text: Array = []
var textIndex: int = 0

var caret: int = 0

# TODO: connect this to a function that hides self
signal text_done

# Called when the node enters the scene tree for the first time.
func _ready():
  children = get_children()
  # check if there is a child node of type RichTextLabel
  for child in children:
    if child is RichTextLabel and textChild == null:
      textChild = child
      textChild.visible_characters = caret
    if child is TextureRect and nextArrow == null:
      nextArrow = child
      nextArrow.visible = false
  
  if text.size() > 0:
    displayText(text)
  else:
    self.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if caret < textChild.text.length():
    # if the caret isn't at the end, we check the timer against the cumulative deltatime
    if textTimer > (1/textSpeed):
      caret += 1
      textTimer = 0
      textChild.visible_characters = caret
    else: 
      textTimer += delta
  else:
    # otherwise, all text is displayed and we're waiting for input
    nextArrow.visible = true
    pass
  
func _unhandled_input(event):
  var check = event is InputEventKey and event.is_pressed() and event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select")

  if check and caret >= textChild.text.length():
    # if the user presses the accept key and the caret is at the end of the text, we move to the next text
    textIndex += 1
    if textIndex < text.size():
      textChild.text = text[textIndex]
      caret = 0
      textChild.visible_characters = caret
      nextArrow.visible = false
    else:
      # if there is no more text, we hide the text box
      text = []
      textIndex = 0
      caret = 0
      self.hide()
      emit_signal("text_done")
  elif check:
    # if the user presses the accept key and the caret is not at the end of the text, we display the rest of the text
    caret = textChild.text.length()
    textChild.visible_characters = caret
    # show the next arrow
    nextArrow.visible = true

# called when the text box is to be displayed. public function
func displayText(textToShow: Array):
  if textToShow.size() > 0:
    text = textToShow
    textChild.text = text[textIndex]
    caret = 0
    textChild.visible_characters = caret  
    self.show()
  else:
    self.hide()
    emit_signal("text_done")
    return

func clearText():
  text = []
  textIndex = 0
  caret = 0
  self.hide()
  emit_signal("text_done")
  return