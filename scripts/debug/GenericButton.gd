class_name GenericButton extends Button

@export var focusThisByDefault : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
  SetupFocus()
  
func SetupFocus():
  # get the focused value from metadata
  if focusThisByDefault:
    grab_focus()

  # grab a list of siblings from our MenuTabs BoxContainer
  var siblings = get_node("%OptionsList").get_children()

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

  # search siblings for the first richtextlabel above us
  var category = null
  for i in range(index - 1, -1, -1):
    if siblings[i] is RichTextLabel:
      # if we find one, grab the text from it
      category = siblings[i].get_text()
      break

  # if we found a category, set the focus to the matching button in the tabs list
  if category != null:
    var tabsList = get_node("%TabsList")
    # iterate through each child of the tabs list
    for i in range(tabsList.get_child_count()):
      var child = tabsList.get_child(i)
      # if the child is a button and the text matches our category, set the focus to it
      if child is Button and child.name == category:
        focus_neighbor_left = child.get_path()
        break
  else:
    # if we didn't find a matching button, set the focus to the first button in the list
    focus_neighbor_left = siblings[firstButton].get_path()
