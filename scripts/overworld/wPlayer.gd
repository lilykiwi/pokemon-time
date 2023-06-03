extends Sprite2D

# we need to store the sprites the player can use.
# these include
# - walking
#   - north
#   - south
#   - east
#   - west
# - running
#   - north
#   - south
#   - east
#   - west
# - bike
#   - north
#   - south
#   - east
#   - west
# - fishing
#   - north
#   - south
#   - east
#   - west
# - surfing
# - pokeball (for fly and stuff)

# we also need some information about which player we are.
# we can get this from the StateManager, which holds a reference to the player.

var pModel: int = Team.Player.pModel.NONE
var pModelString: String = "NONE"
var stateManager: StateManager = null

# anim store: this is crunky asf but this is how it's going to work for now lol
# we use frame indexes to animate. repeated frames are nice here. pretty simple.
var walk_south:  Array[int] = [ 8, 9, 8,10]
var walk_north:  Array[int] = [ 0, 1, 0, 2]
var walk_east:   Array[int] = [16,17,16,18]
var walk_west:   Array[int] = [24,25,24,26]

var run_south:   Array[int] = [ 4, 5, 4, 6]
var run_north:   Array[int] = [12,13,12,14]
var run_east:    Array[int] = [20,21,20,22]
var run_west:    Array[int] = [28,29,28,30]

# don't animate this one, these are directions (nswe)
var cycle_still: Array[int] = [36,37,36,38]
var cycle_north: Array[int] = [32,33,32,34]
var cycle_south: Array[int] = [40,41,40,42]
var cycle_east:  Array[int] = [48,49,48,50]
var cycle_west:  Array[int] = [56,57,56,58]

# don't animate this one, these are directions (nswe)
var surf:        Array[int] = [44,45,46,47]

# animated, idk what it's for though
var idk:         Array[int] = [52,53,54,55]
var pokeball:    Array[int] = [60,61,62,63]

func _init(sm: StateManager):
  if sm == null:
    printerr("Player._init(): StateManager is null!!!!")
    return
  self.stateManager = sm

  # grab the player model from the state manager
  self.playerModel = self.stateManager.player.model
  match self.playerModel:
    Team.Player.pModel.NONE:
      printerr("Player._init(): Player model is NONE!!!!")
      return
    Team.Player.pModel.HERB:
      loadSprites("herb")

var loader
func loadSprites(_pModel: String):
  loader = ResourceLoader.load_threaded_request(
    "res://sprites/player/player-" + _pModel + "/overworld.png", "Image", false
  )
  set_process(true) 

func _process(_time):
  if loader == null:
    # no need to process anymore
    set_process(false)
    return

  while true:
    loader = ResourceLoader.load_threaded_get_status("res://sprites/player/player-" + pModelString + "/overworld.png")
    if loader == ResourceLoader.THREAD_LOAD_LOADED: # Finished loading.
      print("Loaded sprite: " + pModelString)
      self.texture = ResourceLoader.load_threaded_get("res://sprites/player/player-" + pModelString + "/overworld.png")
      loader = null
      break
    elif loader == ResourceLoader.THREAD_LOAD_IN_PROGRESS: # Still loading.
      print(ResourceLoader.load_threaded_get_status("res://sprites/player/player-" + pModelString + "/overworld.png"))
    else: # Error during loading. THREAD_LOAD_INVALID_RESOURCE or THREAD_LOAD_FAILED 
      print("Error loading sprite: " + str(loader))
      loader = null
      break

