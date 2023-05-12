extends Button

@export var focusThisByDefault : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
  SetupFocus()
  
func SetupFocus():
  # get the focused value from metadata
  if focusThisByDefault:
    grab_focus()

  # grab a list of siblings from our MenuTabs BoxContainer
  var siblings = get_node("%TabsList").get_children()

  # get the index of this node in the list
  var index = siblings.find(self)

  # search for the first button in the list
  var firstButton = 0
  for i in range(siblings.size()):
    if siblings[i] is Button:
      firstButton = i
      break

  if index == firstButton:
    # if this is the first button in the list, set the focus to the last button
    focus_neighbor_top = siblings[siblings.size() - 1].get_path()
  else:
    # otherwise, set the focus to the previous node that is a button
    for i in range(index - 1, -1, -1):
      if siblings[i] is Button:
        focus_neighbor_top = siblings[i].get_path()
        break


  # search for the last button in the list
  var lastButton = 0
  for i in range(siblings.size() - 1, -1, -1):
    if siblings[i] is Button:
      lastButton = i
      break

  if index == lastButton:
    # if this is the last node in the list, set the focus to the first button
    focus_neighbor_bottom = siblings[0].get_path()
  else:
    # otherwise, set the focus to the next node that is a button
    for i in range(index + 1, siblings.size()):
      if siblings[i] is Button:
        focus_neighbor_bottom = siblings[i].get_path()
        break

  # grab the text value of our child (the label)
  var label = get_child(0).get_text()

  # find the index of the RichTextLabel with the same label as this node
  var list = get_node("%OptionsList").get_children()

  # iterate over the list of RichTextLabels to find the index of the label with the same text as this node
  var targetIndex = -1
  for i in range(list.size()):
    if list[i].get_text() == label:
      targetIndex = i
      break

  if (targetIndex == -1):
    # if we can't find the label, set the focus to the first node that is a button
    for i in range(list.size()):
      if siblings[i] is Button:
        focus_neighbor_left = siblings[i].get_path()
        break
  else:
    focus_neighbor_right = list[targetIndex + 1].get_path()