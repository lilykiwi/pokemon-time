extends GenericButton

var pips = []
var value = 1

var inactive = preload("res://sprites/OptionsMenu/ThemeElements/pip0.tres")
var active = preload("res://sprites/OptionsMenu/ThemeElements/pip4.tres")

var root

# Called when the node enters the scene tree for the first time.
func _ready():
  root = get_tree().get_root()
  # grab all our children
  var children = get_children()
  # loop through them and add them to pips if they are a pip
  for child in children:
    if child is TextureRect:
      pips.append(child)

  #root.size_changed.connect(self.set_to_auto)
  self.pressed.connect(self.button_pressed)
  
func set_to_auto():
  if (value != 4):
    value = 4
    update_pips()

func update_pips():
  for i in range(0, 5):
    pips[i].set_texture(active if i == value else inactive)

func button_pressed():
  value = (value + 1) % 5

  if value == 0:
    root.set_size(Vector2(256, 192))
  elif value == 1:
    root.set_size(Vector2(512, 384))
  elif value == 2:
    root.set_size(Vector2(768, 576))
  elif value == 3:
    root.set_size(Vector2(1024, 768))

  update_pips()

