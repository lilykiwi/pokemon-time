class_name LocaleManager extends GenericScreen

var _w_player: wPlayer = null
var tileMap: TileMap = null

# janky but meh
#var entitiesContainer: Node2D = null
#var doors:    Array[wDoor]         = []
#var trainers: Array[wTrainer]      = []
#var items:    Array[wItem] = []

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

  # find the tilemap node and assign it to the tileMap variable
  tileMap = get_node("TileMap")

  # find the wPlayer node and assign it to the player variable
  _w_player = get_node("TileMap/wPlayer")
  _w_player._locale_manager = self
  _w_player.snapToGrid()

  _w_player._state_manager = _state_manager
  _w_player.pModel = _state_manager.player.model
  match _w_player.pModel:
    Player.pModel.NONE:
      printerr("Player._init(): Player model is NONE!!!!")
      return
    Player.pModel.HERB:
      _state_manager.loadSprite("res://sprites/PlayerSprites/player-herb/overworld.png", _w_player.pModelSprite)
      _w_player.pModelString = "herb"
  
  # register the doors by searching for each wDoor in entitiesContainer
  #entitiesContainer = get_node("TileMap/Entities")
  #for child in entitiesContainer.get_children():
  #  if child is wDoor:
  #    doors.append(child)
  #  if child is wItem:
  #    items.append(child)
  #  if child is wTrainer:
  #    trainers.append(child)

  #shadowShader.set_shader_parameter("angle", sunAngle)
  #shadowShader.set_shader_parameter("len", shadowDistance)

#func move_player(localeSpawnpoint: int):
#  if doors.size() == 0:
#    printerr("LocaleManager.move_player(): No doors found!")
#    return
#  var targetDest = doors[localeSpawnpoint].spawnpoint.position
#  _w_player.setGlobalPosition(targetDest)
#  _w_player.snapToGrid()
#
#
## jank but it's late and i want a prototype for this
#func _update(delta: float):
#  # check for collisions with doors
#  for door in doors:
#    if _w_player.getGlobalPosition().distance_to(door.getGlobalPosition()) < 16:
#      _state_manager.changeLocale(door.destination, door.destinationSpawn)