class_name LocaleManager extends GenericScreen

var player: wPlayer = null
var tileMap: TileMap = null

# janky but meh
var doors:         Array[wDoor]       = []
var trainers:      Array[wTrainer]    = []
var items:         Array[wItem]       = []
var spawnpoints:   Array[wSpawnpoint] = []
var interactables: Array[wInteractable] = []

# shader stuff
#@export
#var shadowShader:   ShaderMaterial = null
#@export_range(0, 360, 1)
#var sunAngle:       int = 200
#@export_range(0, 20, 1)
#var shadowDistance: int = 5

func _init() -> void:
  super(true) # needs subviewport

func _ready() -> void:

  if not _state_manager:
    printerr("LocaleManager: Initialised without StateManager reference!")
  else:
    _state_manager.locale_manager = self

  # find the tilemap node and assign it to the tileMap variable
  tileMap = get_node("TileMap")

  # find the wPlayer node and assign it to the player variable
  player = get_node("TileMap/wPlayer")
  player._locale_manager = self

  player._state_manager = _state_manager
  player.pModel = _state_manager.player.model
  match player.pModel:
    Player.pModel.NONE:
      printerr("Player._init(): Player model is NONE!!!!")
      return
    Player.pModel.HERB:
      _state_manager.loadSprite("res://Sprites/PlayerSprites/player-herb/overworld.png", player.pModelSprite)
      player.pModelString = "herb"
  
  # register the doors by searching for each wDoor in entitiesContainer
  for child in get_node("TileMap/Doors").get_children():
    if child is wDoor:
      doors.append(child)
  
  for child in get_node("TileMap/Trainers").get_children():
    if child is wTrainer:
      trainers.append(child)
  
  for child in get_node("TileMap/Items").get_children():
    if child is wItem:
      items.append(child)
    
  for child in get_node("TileMap/Spawnpoints").get_children():
    if child is wSpawnpoint:
      spawnpoints.append(child)

  for child in get_node("TileMap/Interactables").get_children():
    if child is wSpawnpoint:
      spawnpoints.append(child)

  # move the player to the right spawnpoint, now that we have a reference to it
  move_player(_state_manager.spawnPoint)
  

  #shadowShader.set_shader_parameter("angle", sunAngle)
  #shadowShader.set_shader_parameter("len", shadowDistance)

func move_player(localeSpawnpoint: int) -> bool:
  if spawnpoints.size() == 0:
    printerr("LocaleManager.move_player(): No spawnpoints present!")
    return false
  var targetDest = spawnpoints[localeSpawnpoint].position
  player.position = targetDest
  player.snapToGrid()
  player.gridPosition = tileMap.local_to_map(targetDest)
  player.clearMovement()
  return true


# jank but it's late and i want a prototype for this
func _process(delta: float):
  # check for collisions with doors
  for door in doors:
    if player.position == door.position:
      _state_manager.changeLocation(door.scene, door.spawnpointID)
