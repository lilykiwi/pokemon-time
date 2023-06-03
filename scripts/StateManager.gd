class_name StateManager extends Node

# this is the primary controller for game state. we do this by utilising a stack of
# states, where the top state is the active state. the active state is the one that
# receives input and is updated. the active state can push a new state onto the stack
# or pop itself off the stack.

# we also want to manage the game's resources here, so that they can be shared between
# states. this is done by loading the resources in the _ready() function and then
# passing them to the states as they are created.

# finally, we store the game's configuration here, so that it can be accessed by the
# states. alongside this, we store the relevant game data, such as the player team.

# change this to true to enable debug mode
# disable this before shipping please :>
@export var debug: bool = false

# locale
enum Locales {
  NONE = -1,
  SNOWDRIFT_TOWN
}

var locale: Locales = Locales.NONE
var player: Player  = null

var messageBox: MessageBox = null
var debugOverlay: DebugOverlay = null

var loadStack: ReferenceRect = null

enum GameStates {
  BASE,
  DEBUG,
  TITLE_SCREEN,
  MAIN_MENU,
  OVERWORLD,
  BATTLE,
  MAP,
  ITEMS,
  POKEMON,
  SUMMARY,
  OPTIONS,
}

var GameStateStrings = {
  GameStates.BASE: "Base",
  GameStates.DEBUG: "Debug",
  GameStates.TITLE_SCREEN: "Title screen",
  GameStates.MAIN_MENU: "Main menu",
  GameStates.OVERWORLD: "Overworld",
  GameStates.BATTLE: "Battle",
  GameStates.MAP: "Map",
  GameStates.ITEMS: "Items",
  GameStates.POKEMON: "Pokemon",
  GameStates.SUMMARY: "Summary",
  GameStates.OPTIONS: "Options",
}

var GameStateSceneName = {
  GameStates.BASE: "dontFreeMe",
  GameStates.DEBUG: "dontFreeMe",
  GameStates.TITLE_SCREEN: "TitleScreen",
  GameStates.MAIN_MENU: "MainMenu",
  GameStates.OVERWORLD: "ow_",
  GameStates.BATTLE: "Battle",
  GameStates.MAP: "Map",
  GameStates.ITEMS: "Items",
  GameStates.POKEMON: "Pokemon",
  GameStates.SUMMARY: "Summary",
  GameStates.OPTIONS: "Options",
}

# substates aren't *truly* substates, but we can use this dictionary to check if we're
# in a valid substate. for example, we can't push the MAP state if we're in POKEMON,
# but we can push SUMMARY if we're in POKEMON.

# Debug is always a valid substate
var legalSubstates = {
  GameStates.BASE: [
    GameStates.TITLE_SCREEN,
    GameStates.OVERWORLD,
    GameStates.BATTLE, # for testing ONLY
  ],
  GameStates.DEBUG: [],
  GameStates.TITLE_SCREEN: [
    GameStates.MAIN_MENU,
  ],
  GameStates.MAIN_MENU: [
    GameStates.OPTIONS,
  ],
  GameStates.OVERWORLD: [
    GameStates.BATTLE,
    GameStates.MAP,
    GameStates.ITEMS,
    GameStates.POKEMON,
    GameStates.OPTIONS,
  ],
  GameStates.BATTLE: [
    GameStates.ITEMS,
    GameStates.POKEMON,
  ],
  GameStates.MAP: [],
  GameStates.ITEMS: [
    GameStates.POKEMON,
    GameStates.DEBUG,
  ],
  GameStates.POKEMON: [
    GameStates.SUMMARY,
    GameStates.DEBUG,
  ],
  GameStates.SUMMARY: [
    GameStates.DEBUG,
  ],
  GameStates.OPTIONS: [
    GameStates.DEBUG,
  ],
}

var states = [
  GameStates.BASE,
]

signal game_state_changed(state) # emitted when the game state changes. contains new top level state
signal load_complete(resource)   # emitted when a resource is loaded by ResourceLoader. contains the resource

var loadStatus: int = 4
var loadPath: String = "[none]"
var loadTarget: Node = null
var resource: Resource = null
# 0 - ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
# 1 - ResourceLoader.THREAD_LOAD_IN_PROGRESS
# 2 - ResourceLoader.THREAD_LOAD_FAILED
# 3 - ResourceLoader.THREAD_LOAD_LOADED
# 4 - not loading

func _init():
  # disable loader processing until we need it
  set_process(false)

  # bind to the game state changed signal
  connect("game_state_changed", self._on_game_state_changed)
  connect("load_complete", self._on_load_complete)

func _ready():
  debugOverlay = get_node("%DebugOverlay")
  messageBox = get_node("%MessageBox")
  loadStack =  get_node("%LoadStack")

  push_state(GameStates.TITLE_SCREEN)

func _on_game_state_changed(state: StateManager.GameStates):
  # this is called when the game state changes. we should update the active state
  # and pass it the resources it needs

  # debug print a list of the states
  print("State stack:")
  for i in range(states.size()):
    print("  " + str(i) + ": " + GameStateStrings[states[i]])

  if state == GameStates.DEBUG:
    # unhide the debug menu and query it for focus
    debugOverlay.show()
  else:
    # hide the debug menu
    debugOverlay.hide()

  match state:
    GameStates.BASE:
      return
    GameStates.DEBUG:
      return
    GameStates.TITLE_SCREEN:
      # check if we need to load the title screen. It'll be in loadStack if not
      if get_index_if_loaded(GameStates.TITLE_SCREEN) == -1:
        # load the title screen
        self.loadScene("res://scenes/screen/TitleScreen.tscn", loadStack)
    GameStates.MAIN_MENU:
      printerr("todo")
      return
    GameStates.OVERWORLD:
      if get_index_if_loaded(GameStates.OVERWORLD) == -1:
        # load the title screen
        self.loadScene("res://scenes/locales/ow_000-Snowdrift-Town.tscn", loadStack)
    GameStates.BATTLE:
      if get_index_if_loaded(GameStates.BATTLE) == -1:
        # load the title screen
        self.loadScene("res://scenes/screen/Battle.tscn", loadStack)
    GameStates.MAP:
      printerr("todo")
      return
    GameStates.ITEMS:
      printerr("todo")
      return
    GameStates.POKEMON:
      printerr("todo")
      return
    GameStates.SUMMARY:
      printerr("todo")
      return
    GameStates.OPTIONS:
      printerr("todo")
      return
    _:
      printerr("Invalid game state: " + str(state))
      return

# State Stuff ------------------------------------------------------------------

func get_index_if_loaded(state: GameStates) -> int:
  # returns the index of the state if it's loaded, or -1 if it's not
  for i in range(loadStack.get_child_count()):
    if loadStack.get_child(i).get_name().contains(GameStateSceneName[state]):
      return i
  return -1

func push_state(state: GameStates):
  print("Pushing state: " + GameStateStrings[state])
  # check if the state is a valid substate of the current back state
  while get_top_state() != GameStates.BASE:
    if not (legalSubstates[states.back()].has(state) or (state == GameStates.DEBUG and debug)):
      # pop the top state
      pop_state()
    else:
      break
  states.push_back(state)
  emit_signal("game_state_changed", states.back())

func pop_state():
  var stateToPop = get_top_state()
  if stateToPop == GameStates.BASE:
    printerr("Attempted to pop the base state")
    return
  var index = get_index_if_loaded(stateToPop)
  print ("Popping state: " + GameStateStrings[stateToPop])
  if index != -1:
    # unload the scene
    print("Unloading " + GameStateSceneName[stateToPop])
    loadStack.get_child(index).queue_free()
  states.pop_back()
  emit_signal("game_state_changed", states.back())

func get_top_state():
  return states.back()

func get_state_name(state: GameStates):
  return GameStateStrings[state]

# Resource Loading -------------------------------------------------------------

func _on_load_complete(_resource):
  if _resource is PackedScene:
    var _scene = _resource.instantiate()
    _scene._state_manager = self
    loadTarget.add_child(_scene)

func loadScene(scene_path: String, target: Node = %loadStack):
  # initilise the loader
  # check if we're already loading
  if self.loadStatus == 1:
    printerr("Attempted to load " + scene_path + " while already loading " + self.loadPath)
    return
  else:
    print("Loading " + scene_path)
  self.loadStatus = ResourceLoader.load_threaded_request(scene_path, "PackedScene", false)
  self.loadPath = scene_path
  self.loadTarget = target
  set_process(true)

func _process(_delta):
  # skip loading at init, for some reason _process is called before _init
  if self.loadPath == "[none]":
    return
  # poll the loader
  self.loadStatus = ResourceLoader.load_threaded_get_status(self.loadPath)
  match self.loadStatus:
    ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
      printerr("Invalid resource: " + self.loadPath)
    ResourceLoader.THREAD_LOAD_IN_PROGRESS:
      print(ResourceLoader.load_threaded_get_status(self.loadPath))
      return
    ResourceLoader.THREAD_LOAD_FAILED:
      printerr("Failed to load " + self.loadPath)
    ResourceLoader.THREAD_LOAD_LOADED:
      print("Loaded scene: " + self.loadPath)
      self.resource = ResourceLoader.load_threaded_get(self.loadPath)
      # emit the load complete signal
      emit_signal("load_complete", self.resource)
  set_process(false)

# Save/Load -------------------------------------------------------------------
#
#func save_game_data() -> Dictionary:
#  var save_dict = {}
#  return {}
