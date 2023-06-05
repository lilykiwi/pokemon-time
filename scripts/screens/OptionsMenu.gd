class_name OptionsMenu extends GenericScreen

func _init():
  super(true) # needs a subviewport

# a button to toggle the display scaling types
class DisplayScalingButton extends MainMenu.GenericButton:
    
  var pips = []
  var value = 1

  var inactive: AtlasTexture = preload("res://sprites/Screens/OptionsMenu/ThemeElements/pip0.tres")
  var active:   AtlasTexture = preload("res://sprites/Screens/OptionsMenu/ThemeElements/pip4.tres")

  var hbox: HBoxContainer
  # TODO: replace this with a function in StateManager
  #var root: Node

  func _init():
    # we want to create a HBoxContainer for storing the pips and labels
    hbox = HBoxContainer.new()
    hbox.set_name("DisplayScalingHBox")
    hbox.size = Vector2(164, 19)
    hbox.set_position(Vector2(6, 0))
    hbox.add_theme_constant_override("separation", 4)
    self.add_child(hbox)

    # create a label for the button
    var label = Label.new()
    label.set_name("DisplayScalingLabel")
    label.set_text("Scale")
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(label)

    for i in range(1,6):
      # we want to create 5 pips with labels after each one
      var pip = TextureRect.new()
      pip.set_name("DisplayScalingPip" + str(i))
      pip.set_texture(inactive)
      pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
      hbox.add_child(pip)
      pips.append(pip)

      var pipLabel = Label.new()
      pipLabel.set_name("DisplayScalingLabel" + str(i))
      if (i == 5):
        pipLabel.set_text("Auto")
      else:
        pipLabel.set_text(str(i) + "x")
      pipLabel.size_flags_horizontal = Control.SIZE_EXPAND
      hbox.add_child(pipLabel)

  # Called when the node enters the scene tree for the first time.
  func _ready():
    SetStyle()

    #root = get_tree().get_root()


    #root.size_changed.connect(self.set_to_auto)
    self.pressed.connect(self.button_pressed)
    update_pips()
    
  #func set_to_auto():
  #  if (value != 4):
  #    value = 4
  #    update_pips()

  func update_pips():
    for i in range(0, 5):
      pips[i].set_texture(active if i == value else inactive)

  func button_pressed():
    value = (value + 1) % 5

    #if value == 0:
    #  root.set_size(Vector2(256, 192))
    #elif value == 1:
    #  root.set_size(Vector2(512, 384))
    #elif value == 2:
    #  root.set_size(Vector2(768, 576))
    #elif value == 3:
    #  root.set_size(Vector2(1024, 768))

    update_pips()


# a button that handles Audio Volume
class AudioButton extends MainMenu.GenericButton:

  enum VolumeType { MAIN, SFX, MUSIC }
  # lookup for string
  var volumeTypeStrings = ["Main", "SFX", "Music"]
    
  var pips = []
  # 11 values, 0-10 inclusive
  var value = 5

  var volumeType: int = -1

  var inactive: AtlasTexture = preload("res://sprites/Screens/OptionsMenu/ThemeElements/pip0.tres")
  var active:   AtlasTexture = preload("res://sprites/Screens/OptionsMenu/ThemeElements/pip4.tres")

  var hbox: HBoxContainer
  var root: Node

  func _init(_volumeType: VolumeType):
    if not _volumeType in range(0, volumeTypeStrings.size()):
      printerr("AudioButton: Invalid VolumeType: " + str(_volumeType))
      return
    volumeType = _volumeType
    # we want to create a HBoxContainer for storing the pips and labels
    hbox = HBoxContainer.new()
    hbox.set_name("DisplayScalingHBox")
    hbox.size = Vector2(164, 19)
    hbox.set_position(Vector2(6, 0))
    hbox.add_theme_constant_override("separation", 1)
    self.add_child(hbox)

    # add a label to the HBoxContainer
    var label = Label.new()
    label.set_name("DisplayScalingLabel")
    label.set_text(volumeTypeStrings[volumeType] + " Volume")
    label.size_flags_horizontal = SIZE_EXPAND_FILL
    hbox.add_child(label)

    # add 10 pips to the HBoxContainer
    for i in range(0, 10):
      var pip = TextureRect.new()
      pip.set_name("AudioPip" + str(i))
      pip.set_texture(inactive)
      pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
      hbox.add_child(pip)
      pips.append(pip)


  # Called when the node enters the scene tree for the first time.
  func _ready():
    SetStyle()

    root = get_tree().get_root()
    self.pressed.connect(self.button_pressed)

    update_pips()

  func update_pips():
    for i in range(0, 10):
      pips[i].set_texture(active if i < value else inactive)

  func button_pressed():
    value = (value + 1) % 11
    # todo: set the volume
    update_pips()

  # todo: left + right buttons to change volume up/down
  #func button_left():
  #  value = (value - 1) % 11
  #  update_pips()
  #
  #func button_right():
  #  button_pressed()

