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
  SNOWDRIFT_TOWN
}

var locale = null
var player: Player = null

var messageBox: MessageBox = null
var debugOverlay: DebugOverlay = null

enum GameStates {
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
  GameStates.DEBUG: "DEBUG",
  GameStates.TITLE_SCREEN: "TITLE_SCREEN",
  GameStates.MAIN_MENU: "MAIN_MENU",
  GameStates.OVERWORLD: "OVERWORLD",
  GameStates.BATTLE: "BATTLE",
  GameStates.MAP: "MAP",
  GameStates.ITEMS: "ITEMS",
  GameStates.POKEMON: "POKEMON",
  GameStates.SUMMARY: "SUMMARY",
  GameStates.OPTIONS: "OPTIONS",
}

# substates aren't *truly* substates, but we can use this dictionary to check if we're
# in a valid substate. for example, we can't push the MAP state if we're in POKEMON,
# but we can push SUMMARY if we're in POKEMON.

# Debug is always a valid substate
var legalSubstates = {
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

var states = []

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

  if debug:
    push_state(GameStates.DEBUG)
  else:
    push_state(GameStates.TITLE_SCREEN)

func _on_game_state_changed(state: StateManager.GameStates):
  # this is called when the game state changes. we should update the active state
  # and pass it the resources it needs

  if state == GameStates.DEBUG:
    # unhide the debug menu and query it for focus
    debugOverlay.show()
    debugOverlay.setFocus()
  else:
    # hide the debug menu
    debugOverlay.hide()

  match state:
    GameStates.DEBUG:
      return
    GameStates.TITLE_SCREEN:
      return
    GameStates.MAIN_MENU:
      return
    GameStates.OVERWORLD:
      return
    GameStates.BATTLE:
      return
    GameStates.MAP:
      return
    GameStates.ITEMS:
      return
    GameStates.POKEMON:
      return
    GameStates.SUMMARY:
      return
    GameStates.OPTIONS:
      return
    _:
      printerr("Invalid game state: " + str(state))
      return

func push_state(state: GameStates):
  # check if the state is a valid substate of the current back state
  if states.size() > 0:
    if !legalSubstates[states.back()].has(state) or not (state == GameStates.DEBUG and debug):
      printerr("Attempted to push invalid state " + GameStateStrings[state] + " onto " + GameStateStrings[states.back()])
      return
  states.push_back(state)
  emit_signal("game_state_changed", states.back())

func pop_state():
  states.pop_back()
  emit_signal("game_state_changed", states.back())

func get_top_state():
  return states.back()

func _on_load_complete(_resource):
  if _resource is PackedScene:
    loadTarget.add_child(_resource.instance())

func loadScene(scene_path: String, target: Node = %loadStack):
  # initilise the loader
  # check if we're already loading
  if self.loadStatus == 1:
    printerr("Attempted to load " + scene_path + " while already loading " + self.loadPath)
    return
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
