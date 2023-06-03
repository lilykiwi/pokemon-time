extends Node2D

@export
var pressStart: AnimatedSprite2D = null

var _state_manager: StateManager = null

func _ready():
  self.pressStart.play("flashing")
  if not _state_manager:
    printerr("TitleScreen: Initialised without StateManager reference!")

func _unhandled_input(event):
  if event.is_pressed() and event.is_action_pressed("menu_start_button"):
    # query the state manager for the top state
    var _top_state = _state_manager.get_top_state()
    #_state_manager.push_state(StateManager.GameStates.MAIN_MENU)
    # this is temp but lol
    _state_manager.push_state(StateManager.GameStates.DEBUG)