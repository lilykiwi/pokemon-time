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
  attackBox.get_children()[0].connect("pressed", UseMove.bind(0, player[player_pokemon], enemy[enemy_pokemon]))
  attackBox.get_children()[1].connect("pressed", UseMove.bind(1, player[player_pokemon], enemy[enemy_pokemon]))
  attackBox.get_children()[2].connect("pressed", UseMove.bind(2, player[player_pokemon], enemy[enemy_pokemon]))
  attackBox.get_children()[3].connect("pressed", UseMove.bind(3, player[player_pokemon], enemy[enemy_pokemon]))

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

# return an int?
# icky tbh. we should probably return a new object that contains the status effects and damage
# that way the AI can use this function when weighing up options, as well as the move proc itself
# >0 for damage
# 0 for status with no damage
# -1 for miss
# -2 for illegal
# -3 for error
# this is a mess. instead we should return
# a value for whether it hits (bool)
# a value for the amount of recoil it does (int)
# a value for the amount of damage it does (int)
# a list of status effects it applies (array)
# a list of status effects it removes (array)
# a list of stat changes it applies (array)
# a list of stat changes it removes (array)
#   - NOTE: we need to specify self and/or targets
# a list of other effects it applies, like weather (array)
# a list of other effects it removes, like weather (array)
# maybe we move this to a separate class?
func UseMove(i: int, user: Pokemon, target: Pokemon) -> bool:
  if !(player[player_pokemon].currentMoves[i] is Move):
    # the move doesn't exist. weird?
    printerr("Move doesn't exist: " + str(i) + ", " + str(player[player_pokemon].currentMoves[i]))
    return false
  
  # TODO: compute status effects
  # TODO: compute critical hits
  # TODO: compute type effectiveness

  var move = player[player_pokemon].currentMoves[i]

  if move.ppCurrent <= 0:
    # the move has no pp left
    # TODO: we shouldn't get here as the button should be disabled if the move has no pp left
    return false

  if move.disabled:
    # the move is disabled
    # TODO: we shouldn't get here as the button should be disabled if the move is disabled
    return false

  # accuracy check: relies on our accuracy modifier, the move's accuracy, a random number, and the target's evasion
  # if the accuracy value is -1, the move always hits - i.e. skip this section
  # T = AccuracyMove * StageMultiplier * Other
  # T is the computed threshold
  # AccuracyMove is the move's accuracy, 1-100
  # StageMultiplier is the evasion and accuracy stage multiplier, ranges from -6 to 6 and is a sum of the two.
  # Other is a modifier for Ability effects, fog, move effects, item effects, etc. 
  # https://bulbapedia.bulbagarden.net/wiki/Category:Moves_that_cannot_miss

  if move.accuracy != -1:
    # TODO: stagemod
    # sum: -6 to 6
    # -6   -5   -4   -3   -2   -1   0    1    2    3    4    5    6
    # 3/9, 3/8, 3/7, 3/6, 3/5, 3/4, 3/3, 4/3, 5/3, 6/3, 7/3, 8/3, 9/3
    var hitThreshold = move.accuracy
    if randi() % 100 > hitThreshold:
      # the move missed
      print("The move missed!")
      print("Hit threshold: " + str(hitThreshold))
      return false

  # damage calculation
  # https://bulbapedia.bulbagarden.net/wiki/Damage

  if (move.moveClass == Move.moveClasses.NONE):
    # the move is invalid
    printerr("Invalid move: " + str(move.moveName))
    return false
  
  if (move.moveClass == Move.moveClasses.STATUS):
    printerr("TODO status move:", str(move.moveName))
    return false

  # TODO: some moves have a fixed damage value
  # TODO: some moves also apply a status effect

  var damage = 0

  # TODO: https://bulbapedia.bulbagarden.net/wiki/Category:Moves_that_use_stats_from_different_categories

  if (move.moveClass == Move.moveClasses.PHYSICAL):
    # physical move
    damage = ((2*user.level)/5.0 * move.power * (user.currentAtk / float(target.currentDef))) / 50 + 2
  if (move.moveClass == Move.moveClasses.SPECIAL):
    # special move
    damage = ((2*user.level)/5.0 * move.power * (user.currentSpAtk / float(target.currentSpDef))) / 50 + 2
  
  # 0.75x if more than one target, otherwise 1.0x

  # TODO: Parental Bond -> ability for Mega Kangaskhan

  # TODO: Weather
  # -- FLAT 1.0x if Cloud Nine or Air Lock ability is present on field
  # - 1.5x if water in rain
  # - 0.5x if fire in rain
  # - 1.5x if fire in sun (or Hydro Steam)
  # - 0.5x if water in sun (except for Hydro Steam)

  # TODO: 2x if last move is Glaive Rush -> move for Baxcalibur (are we adding this?)

  # TODO: crit check
  # 1.5x if crit (gen5 is 2x, but meh)
  # https://bulbapedia.bulbagarden.net/wiki/Critical_hit

  # random damage range 0.85 - 1.00
  var randomMod = randi() % 15 + 85
  damage *= (randomMod / 100.0)

  # TODO: apply stab

  # type modifier
  # we can get the types of the pokemon from the target pokemon's type list
  # see Type.gd for more info on how this works
  var typeMod = Type.computeEffectiveness(move.moveType, target.types[0], target.types[1])
  damage *= typeMod

  # TODO: burn check
  # 0.5x if user is burned, move is physical, and ability isn't guts.
  # otherwise 1.0x

  # Extra Checks - ALL STACK MULTIPLICATIVELY:
  # Dynamax - 2.0x with Behemoth Blade, Behemoth Bash, Dynamax Cannon if Dynamaxed (are we adding this?)
  # Minimize - 2.0x for https://bulbapedia.bulbagarden.net/wiki/Minimize_(move)#Vulnerability_to_moves
  # Earthquake and Magnitude - 2.0x if target is in Dig invulnerability
  # Surf and Whirlpool - 2.0x if target is in Dive invulnerability
  # Reflect, Light Screen, Aurora Veil - 0.5x if target is behind one of these and move is affected by it
  #   -> https://bulbapedia.bulbagarden.net/wiki/Reflect_(move)#Generation_V_onwards
  #   -> https://bulbapedia.bulbagarden.net/wiki/Light_Screen_(move)#Generation_V_onwards
  #   -> https://bulbapedia.bulbagarden.net/wiki/Aurora_Veil_(move)#Effect
  # Collision Course and Electro Drift - ~1.3333x (5461/4096) gen 9 stuff do we care
  # Fluffy, 0.5 if check passes
  # Punk Rock, 0.5 if check passes
  # Ice Scales, 0.5 if check passes
  # Friend Guard, 0.75 if check passes
  # Filter, Prism Armor, and Solid Rock, 0.75 if check passes
  # Neuroforce, 1.25 if check passes
  # Sniper, 1.5x if check passes
  # Tinted Lens, 2.0x if check passes
  # Fluffy, 2.0x if check passes (if move is fire type)
  # Type-resist Berries, 0.5x if check passes
  #    -> 0.25x if ability is Ripen
  # Expert Belt, ~1.2x (4915/4096) if held by the attacker and the move is super effective (type mod > 1.0)
  # Life Orb, ~1.3x (5324/4096) if held by attacker
  # Metronome, up to 2.0x, add ~0.2x (819/4096) for each consecutive use of the same move

  # ZMove is 0.25 if conditions are met (meh)
  # TeraShield sure is a thing. (meh)

  # TODO: type coersion and rounding
  if damage > 1 and damage < 0:
    damage = 1

  if damage < 0:
    print("Damage is less than 0: " + str(damage))
    return false

  ## TODO: apply status effects
  # we round to an int here. the games typically round on each operation, but we don't need to do that.
  print(str(round(damage)))

  return true

