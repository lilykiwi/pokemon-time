class_name StateManager extends Node2D

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
  SAVE,
  OPTIONS,
  CREDITS,
  EXIT,
}

var GameStateStrings = {
  GameStates.BASE: "BASE",
  GameStates.DEBUG: "DEBUG",
  GameStates.TITLE_SCREEN: "TITLE_SCREEN",
  GameStates.MAIN_MENU: "MAIN_MENU",
  GameStates.OVERWORLD: "OVERWORLD",
  GameStates.BATTLE: "BATTLE",
  GameStates.MAP: "MAP",
  GameStates.ITEMS: "ITEMS",
  GameStates.POKEMON: "POKEMON",
  GameStates.SAVE: "SAVE",
  GameStates.OPTIONS: "OPTIONS",
  GameStates.CREDITS: "CREDITS",
  GameStates.EXIT: "EXIT",
}

var load_target: Node2D = null

var states = []
var states_data = []

signal game_state_changed(state) # emitted when the game state changes. contains new top level state

func _init():
  # bind to the game state changed signal
  connect("game_state_changed", _on_game_state_changed.bind(StateManager.GameStates))

  # create a load target
  load_target = Node2D.new()
  load_target.set_name("load_target")
  self.add_child(load_target)


  push_state(GameStates.BASE, {
    player: player,
  })

  if debug:
    push_state(GameStates.DEBUG, {})
  else:
    push_state(GameStates.TITLE_SCREEN, {})

func _on_game_state_changed(state: StateManager.GameStates):
  # this is called when the game state changes. we should update the active state
  # and pass it the resources it needs
  match state:
    StateManager.GameStates.DEBUG:
      # we need to initialise a new DebugOverlay here.
      return
    StateManager.GameStates.TITLE_SCREEN:
      return
    StateManager.GameStates.OVERWORLD:
      return
    StateManager.GameStates.BATTLE:
      return

func push_state(state, state_data: Dictionary = {}):
  states.push_back(state)
  states_data.push_back(state_data)
  emit_signal("game_state_changed", states.back())

func pop_state():
  states.pop_back()
  states_data.pop_back()
  emit_signal("game_state_changed", states.back())

var loadStatus: int = 4
# 0 - ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
# 1 - ResourceLoader.THREAD_LOAD_IN_PROGRESS
# 2 - ResourceLoader.THREAD_LOAD_FAILED
# 3 - ResourceLoader.THREAD_LOAD_LOADED
# 4 - not loading
func loadScene(scene_path: String):
  # initilise the loader
  loadStatus = ResourceLoader.load_threaded_request(scene_path, "PackedScene", false)
  if loadStatus != 1:
    print("Failed to load scene: " + scene_path)

    return
  else:
    print("Loading scene: " + scene_path)
  
  while true:
    loadStatus = ResourceLoader.load_threaded_get_status(scene_path)
    match loadStatus:
      ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
        printerr("Invalid resource")
        loadStatus = 4
        break
      ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        print(ResourceLoader.load_threaded_get_status(scene_path))
      ResourceLoader.THREAD_LOAD_FAILED:
        printerr("Failed to load " + scene_path)
        loadStatus = 4
        break
      3:
        print("Loaded scene: " + scene_path)
        var resource = ResourceLoader.load_threaded_get(scene_path)
        load_target.add_child(resource.instantiate())
        break
      4:
        print("Not loading")
        break
  loadStatus = 4
  return