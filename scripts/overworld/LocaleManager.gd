class_name LocaleManager extends GenericScreen

var _w_player: wPlayer = null
var tileMap: TileMap = null

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
      
