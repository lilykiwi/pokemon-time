class_name wPlayer extends Sprite2D

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

var _state_manager: StateManager = null
var _locale_manager: LocaleManager = null
var _camera: Camera2D = null

# we store position here even though Sprite2D has a transform property, because we want to
# be able to move the player in a grid and have a method to update the transform based on this.
var gridPosition: Vector2i = Vector2(0, 0)
var nextGridPosition: Vector2i = Vector2(0, 0)
var isFacingInputDir: bool = false
var facingHoldTime: float = 0.1
var facingHoldTimeCurrent: float = 0.0
var movingDirection: String = ""
var isMoving: bool = false
var isMovingTime: float = 0.0
# how many seconds it takes to move a single unit
var gridSpeedWalk: float = 0.25
var gridSpeedRun: float = 0.15
var gridSpeedBike: float = 0.1
# we want to buffer the next input so that we can move the player after moving a single unit
# input in DPP seems to go on a FIFO rule? we should store an array of inputs and then
# process the most recent pushed (back()?) input. admittedly DPP has some weirdness,
# so we'll see how this goes.

var inputFIFO: Array = []
var inputBuffer: String = ""

var pModel: int = Player.pModel.NONE
var pModelString: String = "NONE"
var stateManager: StateManager = null

var pModelSprite: Sprite2D = null
var frameIndex: int = 0
var animFrameTime: float = 0.0

# anim store: this is crunky asf but this is how it's going to work for now lol
# we use frame indexes to animate. repeated frames are nice here. pretty simple.
var walkingFps:  int = 6
var walk_south:  Array[int] = [ 8, 9, 8,10]
var walk_north:  Array[int] = [ 0, 1, 0, 2]
var walk_west:   Array[int] = [16,17,16,18]
var walk_east:   Array[int] = [24,25,24,26]

var runningFps:  int = 6
var run_south:   Array[int] = [ 4, 5, 4, 6]
var run_north:   Array[int] = [12,13,12,14]
var run_west:    Array[int] = [20,21,20,22]
var run_east:    Array[int] = [28,29,28,30]

# don't animate this one, these are directions (nswe)
var cycle_still: Array[int] = [36,37,36,38]
var cyclingFps:  int = 6
var cycle_north: Array[int] = [32,33,32,34]
var cycle_south: Array[int] = [40,41,40,42]
var cycle_west:  Array[int] = [48,49,48,50]
var cycle_east:  Array[int] = [56,57,56,58]

# don't animate this one, these are directions (nswe)
var surf:        Array[int] = [44,45,46,47]

# animated, idk what it's for though
var idk:         Array[int] = [52,53,54,55]
var pokeballFps: int = 6
var pokeball:    Array[int] = [60,61,62,63]

func _ready():
  _camera = get_child(0)

func _process(_delta):
  if _state_manager.get_top_state() != StateManager.GameStates.OVERWORLD:
    return

  if inputFIFO.size() > 0 && facingHoldTimeCurrent == 0.0:
    var dir = inputBuffer
    movingDirection = dir

  if inputFIFO.size() > 0 && facingHoldTimeCurrent < facingHoldTime:
    facingHoldTimeCurrent += _delta

    # no animation needed here as we're holding until the facingHoldTime is reached
  
  if inputFIFO.size() > 0 and facingHoldTimeCurrent >= facingHoldTime and not isMoving:
    # collision check here
    var dir = inputBuffer
    movingDirection = dir
    clearBuffer()
    match dir:
      "main_up":
        nextGridPosition = gridPosition + Vector2i(0, -1)
      "main_down":
        nextGridPosition = gridPosition + Vector2i(0, 1)
      "main_left":
        nextGridPosition = gridPosition + Vector2i(-1, 0)
      "main_right":
        nextGridPosition = gridPosition + Vector2i(1, 0)
    if _locale_manager.tileMap.get_cell_tile_data(6, nextGridPosition) != null:
      # we have a collision in this direction, so we can deregister it
      isMoving = false
    else:
      isMoving = true


  if isMoving:
    # get the delta between our current position and our next position
    var start = _locale_manager.tileMap.map_to_local(gridPosition)
    var end = _locale_manager.tileMap.map_to_local(nextGridPosition)
    
    if isMovingTime >= gridSpeedWalk:
      self.position = end
      snapToGrid()
      isMoving = false
      isMovingTime = 0.0
      if inputFIFO.size() > 0: inputBuffer = inputFIFO.back()
      else:                    inputBuffer = ""
    else:
      var delta = end - start
      # multiply this by the isMovingTime
      delta *= isMovingTime / gridSpeedWalk
      # round this to the nearest pixel
      delta = delta.round()
  
      # set our position to the start + delta
      self.position = start + delta
      _camera.align()
      
      # increment isMovingTime
      isMovingTime += _delta

  if isMoving == false and inputBuffer == "":
    # we're not moving and have no more moves queued, so reset facing hold time
    isFacingInputDir = false
    # reset the facing hold time
    facingHoldTimeCurrent = 0.0

  self.animate(_delta)

func animate(_delta: float):
  # this function will animate us based on our current state
  # we should use:
  #   self.isMoving
  #   self.movingDirection
  #   self.animFrameTime
  #   self.frameIndex
  # as well as the various FPS variables
  if self.isMoving:
    # we're moving, so we need to animate
    # we count up the frame time using _delta, and once it overflows 1/FPS we increment the frame index
    self.animFrameTime += _delta
    if self.animFrameTime >= 1.0 / self.walkingFps:
      # we've overflowed, so we need to increment the frame index
      self.frameIndex += 1
      # we also need to reset the animFrameTime
      self.animFrameTime = 0.0
      # we also need to check if we've overflowed the frame index
      if self.frameIndex >= 4:
        # we've overflowed, so we need to reset the frame index
        self.frameIndex = 0
  elif self.isMoving == false and self.inputBuffer == "":
    # we're not moving, so we reset back to the standing frame (0th)
    self.frameIndex = 0
  match self.movingDirection:
    "main_up":
      self.frame = walk_north[self.frameIndex] 
    "main_down":
      self.frame = walk_south[self.frameIndex] 
    "main_left":
      self.frame = walk_west[self.frameIndex] 
    "main_right":
      self.frame = walk_east[self.frameIndex]

  pass

func snapToGrid():
  # this function will snap us to the grid using our position.
  gridPosition = _locale_manager.tileMap.local_to_map(self.position)
  self.position = _locale_manager.tileMap.map_to_local(gridPosition)

func getGridNeighbours(pos: Vector2i):
  return _locale_manager.tileMap.get_surrounding_cells(pos)

func getCollisionNeighbours(pos: Vector2i):
  var _neighbours: Array = getGridNeighbours(pos)
  var _collisions: Array[bool] = []
  for tilePos in _neighbours:
    var tile = _locale_manager.tileMap.get_cell_tile_data(6,tilePos)
    if tile == null:
      _collisions.append(false)
    else:
      _collisions.append(true)
  # returns in order: right, bottom, left, top
  return _collisions

func registerInput(inputCode: String):
  if not inputFIFO.has(inputCode): inputFIFO.append(inputCode)
  if inputBuffer == "":            inputBuffer = inputCode

func deregisterInput(inputCode: String):
  if inputFIFO.has(inputCode): inputFIFO.erase(inputCode)
  if inputFIFO.size() > 0:     inputBuffer = inputFIFO.back()
  else:                        inputBuffer = ""

func clearBuffer():
  inputBuffer = ""

# handle input for movement
func _unhandled_input(event):
  # query the state manager for the state.
  # if the state is not overworld, we dont want to move.
  if _state_manager.get_top_state() != StateManager.GameStates.OVERWORLD:
    return

  # now we can consume the input
  if event.is_action_pressed("main_up"):
    registerInput("main_up")
  elif event.is_action_pressed("main_down"):
    registerInput("main_down")
  elif event.is_action_pressed("main_left"):
    registerInput("main_left")
  elif event.is_action_pressed("main_right"):
    registerInput("main_right")

  if event.is_action_released("main_up"):
    deregisterInput("main_up")
  elif event.is_action_released("main_down"):
    deregisterInput("main_down")
  elif event.is_action_released("main_left"):
    deregisterInput("main_left")
  elif event.is_action_released("main_right"):
    deregisterInput("main_right")
  
