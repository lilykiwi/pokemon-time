class_name DebugOverlay extends ReferenceRect

var _state_manager: StateManager = null

# the debug overlay is used for modifying game state, loading content, etc.
# some categories and their functions are:

# State
# - load scene Battle or Locale
# - clear scenes
# Display
# - scaling (1x, 2x, 3x, 4x, auto)
# Audio
# - Main Volume
# - SFX Volume
# - Music Volume

# we can implement these programatically by using the StateManager's functions
# - load_scene
# and by using the OS singleton to set the display scaling and audio volumes

# state manager should handle focus & visibility

func _unhandled_input(event):
  if event is InputEventKey and event.is_pressed() and event.is_action_pressed("debug_menu"):
    # query the state manager for the top state
    var _top_state = _state_manager.get_top_state()
    if _top_state == StateManager.GameStates.DEBUG:
      # if the top state is the debug menu, pop the debug menu state
      _state_manager.pop_state()
    else:
      # if the top state is not the debug menu, push the debug menu state
      _state_manager.push_state(StateManager.GameStates.DEBUG)

var debugButtons: Array = [
  StateLoaderButton.new(StateManager.GameStates.OVERWORLD),
  StateLoaderButton.new(StateManager.GameStates.BATTLE),
  DisplayScalingButton.new(),
  AudioButton.new(AudioButton.VolumeType.MAIN),
  AudioButton.new(AudioButton.VolumeType.SFX),
  AudioButton.new(AudioButton.VolumeType.MUSIC),
]

var debugOverlayTheme: Theme = preload("res://sprites/mainTheme.tres")

var scrollContainer: ScrollContainer
var vBoxContainer: VBoxContainer

func _init():
  # iterate over debugButtons and add them to the debugOverlay
  # we want to instantiate a scroll container and a vbox container
  scrollContainer = ScrollContainer.new()
  scrollContainer.set_name("DebugScrollContainer")
  scrollContainer.set_deferred("position", Vector2(40,0))
  scrollContainer.set_deferred("size", Vector2(176, 192))
  self.add_child(scrollContainer)

  vBoxContainer = VBoxContainer.new()
  vBoxContainer.set_name("DebugVBoxContainer")
  vBoxContainer.set_anchors_preset(PRESET_FULL_RECT)
  vBoxContainer.size_flags_horizontal = SIZE_EXPAND_FILL
  scrollContainer.add_child(vBoxContainer)

  # we want a header label that says "Debug Menu"
  var headerLabel = Label.new()
  headerLabel.set_name("DebugHeaderLabel")
  headerLabel.set_text("Debug Menu")
  headerLabel.theme = debugOverlayTheme
  vBoxContainer.add_child(headerLabel)

func _ready():
  # get the StateManager from the parent node
  self._state_manager = get_parent()

  if self._state_manager == null:
    printerr("DebugMenu: No StateManager found in parent node")
    return
  else: 
    print("DebugMenu: StateManager found in parent node")

  # assign the state manager in each of our children buttons
  for button in debugButtons:
    button._state_manager = self._state_manager

  for button in debugButtons:
    vBoxContainer.add_child(button)
    #button.initButtons()

func setFocus():
  # 
  return

class GenericButton extends Button:

  var debugOverlayTheme: Theme = preload("res://sprites/mainTheme.tres")
  var _state_manager: StateManager = null

  func SetStyle():
    self.theme = debugOverlayTheme
    self.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    self.custom_minimum_size = Vector2(0, 19)
    return
    
# a button to toggle the display scaling types
class DisplayScalingButton extends DebugOverlay.GenericButton:
    
  var pips = []
  var value = 1

  var inactive: AtlasTexture = preload("res://sprites/OptionsMenu/ThemeElements/pip0.tres")
  var active:   AtlasTexture = preload("res://sprites/OptionsMenu/ThemeElements/pip4.tres")

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
class AudioButton extends DebugOverlay.GenericButton:

  enum VolumeType { MAIN, SFX, MUSIC }
  # lookup for string
  var volumeTypeStrings = ["Main", "SFX", "Music"]
    
  var pips = []
  # 11 values, 0-10 inclusive
  var value = 5

  var volumeType: int = -1

  var inactive: AtlasTexture = preload("res://sprites/OptionsMenu/ThemeElements/pip0.tres")
  var active:   AtlasTexture = preload("res://sprites/OptionsMenu/ThemeElements/pip4.tres")

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


class StateLoaderButton extends GenericButton:

  var hbox: HBoxContainer
  var label: Label
  var target_state: StateManager.GameStates

  func _init(state: StateManager.GameStates):
    # store the target state
    target_state = state

    # we want to create a HBoxContainer for storing the label
    hbox = HBoxContainer.new()
    hbox.set_name("SceneLoaderHBox")
    self.add_child(hbox)

    # add a label to the HBoxContainer
    label = Label.new()
    label.set_name("SceneLoaderLabel")
    hbox.add_child(label)

  # Called when the node enters the scene tree for the first time.
  func _ready():
    SetStyle()

    hbox.size = Vector2(164, 19)
    hbox.set_position(Vector2(6, 0))
    hbox.add_theme_constant_override("separation", 1)

    label.set_text(_state_manager.get_state_name(target_state))
    label.size_flags_horizontal = SIZE_EXPAND_FILL

    self.pressed.connect(self.button_pressed)
  
  func button_pressed():
    if _state_manager != null:
      _state_manager.push_state(target_state)
    else:
      printerr("SceneLoaderButton: _state_manager is null!")
