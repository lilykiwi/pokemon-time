class_name MainMenu extends GenericScreen

var buttons = []

# This is the class that controls the main menu screen
# we want to present a continue button if there is a save file
# additionally, we want a new game button and an options button.
#   TODO: the options menu
# additionally, we will have a quit button which closes the game

func _init() -> void:
  super(true) # needs subviewport

#func _ready() -> void:
#  return

class GenericPanel extends VBoxContainer:

  var panelTheme: Theme = preload("res://sprites/mainTheme.tres")
  var _state_manager: StateManager = null

  func SetStyle():
    self.theme = panelTheme
    self.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    self.custom_minimum_size = Vector2(0, 19)
    return

class GenericButton extends Button:

  var buttonTheme: Theme = preload("res://sprites/mainTheme.tres")
  var _state_manager: StateManager = null

  func SetStyle():
    self.theme = buttonTheme
    self.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    self.custom_minimum_size = Vector2(0, 19)
    return


class NewGameButton extends MainMenu.GenericButton:

  func _ready() -> void:
    self.SetStyle()
    self.text = "New Game"
    #self.connect("pressed", self, "NewGame")
    return

  func NewGame() -> void:
    self._state_manager.NewGame()
    return


class ContinueButton extends MainMenu.GenericButton:
  
  func _ready() -> void:
    self.SetStyle()
    self.text = "Continue"
    #self.connect("pressed", self, "Continue")
    return

  func Continue() -> void:
    self._state_manager.Continue()
    return


class OptionsButton extends MainMenu.GenericButton:
  
  func _ready() -> void:
    self.SetStyle()
    self.text = "Options"
    #self.connect("pressed", self, "Options")
    return

  func Options() -> void:
    self._state_manager.Options()
    return


class QuitButton extends MainMenu.GenericButton:
  
  func _ready() -> void:
    self.SetStyle()
    self.text = "Quit"
    #self.connect("pressed", self, "Quit")
    return

  func Quit() -> void:
    self._state_manager.Quit()
    return