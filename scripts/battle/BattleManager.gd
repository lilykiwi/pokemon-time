extends Node2D

# Battles have a turn-based combat system. The player and the enemy take turns to attack each other until one of them is defeated.
# The player can choose to attack, use an item, change pokemon, or run away from the battle.
# The player chooses first, then the enemy chooses. The player can only choose to run away if the enemy pokemon is wild.

# The battle system is a state machine. It has these states: PlayerTurn, EnemyTurn, Action, EndBattle.
# The player and foe both have 4 options, so the Action state has 8 substates: PlayerAttack, PlayerItem, PlayerPokemon, PlayerRun, EnemyAttack, EnemyItem, EnemyPokemon, EnemyRun.
# The battle system starts in the PlayerTurn state. When the player chooses an action, the battle system transitions to the EnemyTurn state.
# We need to calculate which option is best for the enemy to choose. We do this by calculating the expected damage of each option, as well as status effects. This is partly random.
# When the enemy chooses an action, the battle system transitions to the Action state.
# When the action is complete, we check if the battle is over. If not, we transition back to the PlayerTurn state.
# If a pokemon faints, we transition to the PlayerPokemon or EnemyPokemon state, depending on whose pokemon fainted, so they can choose a new pokemon.
# If the enemy pokemon is wild, we transition to the EndBattle state.
# If there are no more pokemon left, we transition to the EndBattle state.

# The battle state uses information from the player and the enemy to calculate the expected order of actions.

signal change_state(newState, newSubState)

enum states {
  INTRO,
  PLAYER_TURN,
  ENEMY_TURN,
  ACTION,
  END_BATTLE,
}

enum subStates {
  #INTRO_SLIDE_IN, TODO
  INTRO_TEXT,
  #INTRO_THROW_POKEBALL, TODO
  PLAYER_ACTION,
  PLAYER_SELECT,
  PLAYER_ATTACK,
  PLAYER_ITEM,
  PLAYER_POKEMON,
}

var messageBox: MessageBox = null

var state: int = -1
var subState: int = -1

# store the player and enemy team
# NOTE: for future use, specify a range for wild pokemon.
var player = [
  Pokemon_Bulbasaur.new(
    10, # level
    [   # startingMoves
      Move_Tackle.new(),
      Move_Growl.new(),
      Move_VineWhip.new(),
      Move_LeechSeed.new(),
    ]
  ),
]
var enemy = [
  Pokemon_Bulbasaur.new(
    10, # level
    [   # startingMoves
      Move_Tackle.new(),
      Move_Growl.new(),
      Move_VineWhip.new(),
      Move_LeechSeed.new(),
    ]
  ),
]

# store the player and enemy pokemon
# TODO: reference party index rather than instance object
# TODO: double battles
var player_pokemon: int = 0
var enemy_pokemon: int = 0

var selectBox: Panel = null
var attackBox: Panel = null
var attackBoxType: TextureRect = null
var attackBoxPPCurrent: Label = null
var attackBoxPPMax: Label = null

var playerDataBox: TextureRect = null

var enemyDataBox: TextureRect = null


# var ListPokemon: Panel = null todo
# var ListItem: Panel = null todo

func _ready():
  # the state starts at intro, so we need to set up the intro
  messageBox = get_node("../%MessageBox")

  # get the select box and attack box
  selectBox = get_node("%SelectBox")
  attackBox = get_node("%AttackBox")
  playerDataBox = get_node("%PlayerDatabox")
  enemyDataBox = get_node("%EnemyDatabox")

  # set up the moves in the attack box
  for i in range(player[player_pokemon].currentMoves.size()):
    var move: Move = player[player_pokemon].currentMoves[i]
    var button: TextureButton = attackBox.get_child(i)
    button.get_child(0).set_text(move.moveName)
    var type: Type.list = move.moveType
    
    # set the textures based on the move type
    # TODO: relocate this to be less messy
    if type == Type.list.NONE:
      # we shouldn't get here, but just in case
      button.texture_normal = load("res://sprites/BattleGui/cursor-fight/moveTypes/unknown.tres")
      button.texture_hover = load("res://sprites/BattleGui/cursor-fight/moveTypes/unknown-focus.tres")
      button.texture_pressed = load("res://sprites/BattleGui/cursor-fight/moveTypes/unknown-pressed.tres")
    else:
      button.texture_normal = load("res://sprites/BattleGui/cursor-fight/moveTypes/" + Type.typeToString(type) + ".tres")
      button.texture_hover = load("res://sprites/BattleGui/cursor-fight/moveTypes/" + Type.typeToString(type) + "-focus.tres")
      button.texture_pressed = load("res://sprites/BattleGui/cursor-fight/moveTypes/" + Type.typeToString(type) + "-pressed.tres")

    # connect the button's draw_mode_changed signal to the battle system's draw_mode_changed signal
    button.connect("draw_mode_changed", _on_draw_mode_changed)

  # we know that the attack box has 4 buttons, so we reference them using get_child(n) (0-3). get_child(4) is the PP box
  # set up the attack box type, pp current, and pp max
  attackBoxType = attackBox.get_child(4).find_child("TypeBox")
  attackBoxPPCurrent = attackBox.get_child(4).find_child("ppCurrent")
  attackBoxPPMax = attackBox.get_child(4).find_child("ppMax")
  
  

  # connect the messageBox text_done signal to the battle system's text_done signal
  messageBox.connect("text_done", text_done)

  # connect the battle system's change_state signal to the battle system's _on_state_changed signal
  self.connect("change_state", _on_state_changed)

  # set up signals for all the buttons in the select box
  # they are in the order Attack, Item, Pokemon, Fight
  selectBox.get_children()[0].connect("pressed", Action.bind("Attack"))
  selectBox.get_children()[1].connect("pressed", Action.bind("Item"))
  selectBox.get_children()[2].connect("pressed", Action.bind("Pokemon"))
  selectBox.get_children()[3].connect("pressed", Action.bind("Run"))

  # set up signals for all the buttons in the attack box
  attackBox.get_children()[0].connect("pressed", UseMove.bind(0))
  attackBox.get_children()[1].connect("pressed", UseMove.bind(1))
  attackBox.get_children()[2].connect("pressed", UseMove.bind(2))
  attackBox.get_children()[3].connect("pressed", UseMove.bind(3))

  # set the state to intro
  emit_signal("change_state", states.INTRO, subStates.INTRO_TEXT)

func text_done():
  # this function is called when the message box is done displaying text
  # we need to change the state
  match state:
    states.INTRO:
      # the intro is done, so we need to set up the player and enemy pokemon
      # TODO: throw pokeball intro state
      emit_signal("change_state", states.PLAYER_TURN, subStates.PLAYER_ACTION)

func _on_draw_mode_changed(buttonInstance, drawMode):
  # this function is called when a button's draw mode changes
  # we need to update the attack box type, pp current, and pp max
  # TODO: track focus rather than draw mode
  # TODO: overhaul buttons tbh. mouse hover and separate focus is weird.
  if drawMode == TextureButton.DRAW_NORMAL:
    return
  if drawMode == TextureButton.DRAW_HOVER:
    # get the index of the button
    var index = attackBox.get_children().find(buttonInstance)
    # get the move type
    var move = player[player_pokemon].currentMoves[index]
    # set the attack box type
    attackBoxType.texture = load("res://sprites/BattleGui/types/" + Type.typeToString(move.moveType) + ".tres")
    # set the attack box pp current and pp max
    attackBoxPPCurrent.set_text(str(move.ppCurrent))
    attackBoxPPMax.set_text(str(move.pp))

func _on_state_changed(newState, newSubState):
  # this function is called when the state changes
  # we need to set up the new state
  print("State changed to " + str(newState) + ", " + str(newSubState))
  state = newState
  subState = newSubState
  if newState == states.INTRO and newSubState == subStates.INTRO_TEXT:
    # set up the intro, hide UI elements that aren't needed
    manageHideShow(false, false, false, false)
    messageBox.displayText(["A wild Bulbasaur appeared!"])
  
  if newState == states.PLAYER_TURN and newSubState == subStates.PLAYER_ACTION:
    # unhide the select box and data boxes. hide the attack box
    manageHideShow(true, false, true, true)

  if newState == states.PLAYER_TURN and newSubState == subStates.PLAYER_ATTACK:
    # unhide the attack box, hide the select box
    manageHideShow(false, true, true, true)

  
  #if newState == states.ENEMY_TURN:
  #  # TODO: AI STUFF HERE 
  #  pass
  #if newState == states.ACTION:
  #  selectBox.hide()
  #  attackBox.hide()
  #  playerDataBox.hide()
  #  enemyDataBox.hide()
  #  # TODO: compute outcomes with speed, moves, etc.
  #  # TODO: 
  #  pass

func manageHideShow(selectBoxVal, attackBoxVal, playerDataBoxVal, enemyDataBoxVal):
  selectBox.visible = selectBoxVal
  attackBox.visible = attackBoxVal
  playerDataBox.visible = playerDataBoxVal
  enemyDataBox.visible = enemyDataBoxVal


# functional stuff
func Action(actionType):
  match actionType:
    "Attack":
      # TODO: check if we're allowed

      # hide the select box, show the attack box
      selectBox.hide()
      attackBox.show()

      # focus the first button in the attack box
      attackBox.get_children()[0].grab_focus()

      # update the state to PlayerAttack
      
    "Item":
      pass
      # TODO: check if we're allowed
    "Pokemon":
      pass
      # TODO: check if we're allowed
    "Run":
      # TODO: check if we're allowed
      pass

func UseMove(i):
  if player[player_pokemon].currentMoves[i].type != Move:
    # the move doesn't exist. weird?
    return
  
  # TODO: check if the move has pp left
  # TODO: check if the move is disabled
  # TODO: compute accuracy
  # TODO: compute damage
  # TODO: compute status effects
  # TODO: compute critical hits
  # TODO: compute type effectiveness

  var _move = player[player_pokemon].currentMoves[i]


