class_name TitleScreen extends GenericScreen

func _init() -> void:
  super(true) # needs subviewport

@export var pressStart: AnimatedSprite2D = null
@export var clickButton: Button = null

func _ready() -> void:

  # if we dont have a reference to the sprite and button, find them
  if not self.pressStart:
    self.pressStart = find_child("PressStart")
  if not self.clickButton:
    self.clickButton = find_child("ClickButton")

  self.pressStart.play("flashing")
  if not _state_manager:
    printerr("TitleScreen: Initialised without StateManager reference!")
  
  # bind the button
  self.clickButton.connect("pressed", self._on_clickButton_pressed)

func _unhandled_input(event) -> void:
  if event.is_pressed() and event.is_action_pressed("menu_start_button"):
    startButton()

func _on_clickButton_pressed() -> void:
  startButton()

func startButton() -> void:
  #_state_manager.push_state(StateManager.GameStates.MAIN_MENU)
  # this is temp but lol
  _state_manager.push_state(StateManager.GameStates.DEBUG)
