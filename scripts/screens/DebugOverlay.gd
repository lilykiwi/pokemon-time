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
  self.StateLoaderButton.new(StateManager.GameStates.OVERWORLD),
  self.StateLoaderButton.new(StateManager.GameStates.BATTLE),
  OptionsMenu.DisplayScalingButton.new(),
  OptionsMenu.AudioButton.new(OptionsMenu.AudioButton.VolumeType.MAIN),
  OptionsMenu.AudioButton.new(OptionsMenu.AudioButton.VolumeType.SFX),
  OptionsMenu.AudioButton.new(OptionsMenu.AudioButton.VolumeType.MUSIC),
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

class StateLoaderButton extends MainMenu.GenericButton:

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
