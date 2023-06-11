class_name Pokemon extends Object

# The pokemon's national dex number
var dexNum: int
# The pokemon's regional dex number
#var regionalDexNum: int
# The pokemon's name
var pName: String

# Sprites for the pokemon
var frontSprite: Texture2D
var backSprite: Texture2D
var frontShinySprite: Texture2D
var backShinySprite: Texture2D

# Forms
#var forms: Array = []

# held items in the wild, along with their chances
var wildItems: Dictionary = {}

# Gender Ratio
var genderThreshold: int # 0-255. 256 = male only, 257 = female only, 258 = genderless
var description: String
var weight: int
var height: int

# The pokemon's type
# Type.list.NONE default
var types: Vector2i = Vector2i(
  Type.list.NONE,
  Type.list.NONE
)

# The pokemon's base stats
var baseHp: int
var baseAtk: int
var baseDef: int
var baseSpAtk: int
var baseSpDef: int
var baseSpd: int

# list of moves the pokemon can learn, what level they learn them at. dict of move: level
var moves: Dictionary = {}
# list of moves the pokemon can learn, by TM/HM
var tmMoves: Array = []
# list of moves the pokemon can learn, by breeding, with what parent(s)
var eggMoves: Array = []
# list of moves the pokemon can learn, by tutor
var tutorMoves: Array = []
# list of moves the pokemon can learn, by event
var eventMoves: Array = []
# The abilities the pokemon can have
var abilities: Array = []
# The pokemon's hidden ability
var hiddenAbility: Ability = null

# The pokemon's base experience yield
var expYield: int

# The pokemon's base EV yield
var yieldEVHp: int = 0
var yieldEVAtk: int = 0
var yieldEVDef: int = 0
var yieldEVSpAtk: int = 0
var yieldEVSpDef: int = 0
var yieldEVSpd: int = 0

# The pokemon's base Happiness
var baseHappiness: int

# egg cycles, multiples of 256 steps
var eggCycles: int

# The pokemon's capture rate
var captureRate: int

# The pokemon this evolves from, into, etc. 
# TODO: make this a dictionary of pokemon: [ level, item, etc. ]
var evolutionChain: Dictionary = {}

# levelling rate. this affects xp-to-next using a dif algorithm for each. this can be:
enum levellingRates {
  SLOW,
  MEDIUM_SLOW,
  MEDIUM_FAST,
  FAST,
  ERRATIC,
  FLUCTUATING,
}

# the levelling rate type
var levellingRate: levellingRates

# ---------------------------------------------------------------------------------------------------------------------
# these values represent an instance of a pokemon, compared with a prototype for the dex.

# The pokemon's pid number
var pid: int

# Shiny Pokemon. do not set
var shiny: bool

# Met Location
var metLocation: String
# Met Level
var metLevel: int
# Met date
var metDate: String
# Fateful Encounter?
var fatefulEncounter: bool

# met as egg?
var metAsEgg: bool
# recieved egg date
var recievedDate: String

# Ball type
var ball: String

# The pokemon's nickname
var nickname: String
# The OT
var ot: String
# The OT's ID
#var otId: int
# The OT's secret ID
#var otSecretId: int

# Gender of the pokemon
var gender: String

# The pokemon's current experience
var xp: int
# The pokemon's level
# We must not set this directly. We should calculate it using xp. Cannot be above 100.
var level: int
# The pokemon's current experience, as a percentage of the total experience needed to level up
# We must not set this directly. We should calculate it using xp.
var expPercent: int

# The pokemon's current stats (COMPUTE THESE, DO NOT SET THEM MANUALLY)
var currentHp: int
var currentAtk: int
var currentDef: int
var currentSpAtk: int
var currentSpDef: int
var currentSpd: int

# The pokemon's max stats (COMPUTE THESE, DO NOT SET THEM MANUALLY)
var maxHp: int
var maxAtk: int
var maxDef: int
var maxSpAtk: int
var maxSpDef: int
var maxSpd: int

# IVs are the pokemon's "genetic" potential. They are randomly generated when the pokemon is encountered.
# They range from 0-31, and are used to calculate the pokemon's stats.
var ivHp: int
var ivAtk: int
var ivDef: int
var ivSpAtk: int
var ivSpDef: int
var ivSpd: int

# EVs are the pokemon's "training" potential. They are gained by defeating other pokemon, and are used to calculate the pokemon's stats.
# A pokemon can have a maximum of 252 EVs in any one stat, and a maximum of 510 EVs total. We must not set these directly.
var evHp: int
var evAtk: int
var evDef: int
var evSpAtk: int
var evSpDef: int
var evSpd: int

# stages for in-battle stat modifiers
var atkStage: int = 0
var defStage: int = 0
var spAtkStage: int = 0
var spDefStage: int = 0
var spdStage: int = 0
var accStage: int = 0
var evaStage: int = 0

# The pokemon's current HP as a percentage
# We must not set this directly. We should calculate it using currentHp.
var hpPercent: int = 100

# The pokemon's current moves
# we can only have 4 moves at a time
var currentMoves: Array = []

# The pokemon's current statuses 
var statuses: Array = []

# The pokemon's current ability
var ability: Ability

# The pokemon's current nature
var nature: Nature.natures

# The pokemon's current held item
# TODO: implement item objects
var item: Item

# The pokemon's current happiness
var happiness: int

# are we currently an egg? if so, use friendship as a hatch counter
var isEgg: bool

# flag for whether or not a pokemon gets a hidden ability. set this in the editor
var giveHiddenAbility: bool = false

# party index
var partyIndex: int = -1

func generate(startingLevel: int): 
  # todo: get the player's name when caught
  ot = ""
  # do we need these? seems antiquitated.
  # otId = 0
  # otSecretId = 0

  # this is 0-4,294,967,295, 32bit but Godot is 64bit
  pid = randi() % 4294967295

  setNickname(pName)

  # -- Shininess ------------------------------------------------------------------------------------------------------

  # we can work out shiny from this
  shiny = pid % 65536 < 8

  # typically this would be:
  # var p1 = floor((pid & 0b11111111111111110000000000000000) / 65536.0)
  # var p2 = (pid & 0b00000000000000001111111111111111) % 65536
  # shiny = otId ^ otSecretId ^ p1 ^ p2

  # -- Gender ---------------------------------------------------------------------------------------------------------

  if (genderThreshold > 255):
    # gender is specified based on this value
    if genderThreshold == 256:
      gender = "male"
    elif genderThreshold == 257:
      gender = "female"
    elif genderThreshold == 258:
      gender = "genderless"
    else: 
      printerr("ERROR: Gender ratio is misconfigured for " + pName)
  else:
    # we need to work it out using mod
    # this differs dramatically from the typical technique, but it's easier
    # and we don't need to worry about memory & storage at this stage.
    if (pid % 255 < genderThreshold):
      gender = "male"
    else:
      gender = "female"

  # TODO: Cute Charm ability

  # -- Nature ---------------------------------------------------------------------------------------------------------

  # TODO: stat modifiers
  nature = Nature.intToNature(pid % 25)

  # TODO: Breeding & Nature
  # TODO: Synchronize

  # -- Ability --------------------------------------------------------------------------------------------------------

  # pokemon have 1 or 2 abilities, and a hidden ability. 
  # hidden ability is source-specific, so we'll need to check that.

  # we *could* grab one bit.... but mod is easy.

  if hiddenAbility != null && giveHiddenAbility:
    ability = hiddenAbility
  elif abilities.size() != 0:
    ability = abilities[pid % abilities.size()]
  else:
    printerr("ERROR: Pokemon has no abilities set:" + pName)

  # TODO: Breeding & Ability

  # -- IVs ------------------------------------------------------------------------------------------------------------

  # IVs are the pokemon's "genetic" potential. They are randomly generated when
  # the pokemon is encountered. they range from 0-31 and are independent of PID
  ivHp = randi() % 31
  ivAtk = randi() % 31
  ivDef = randi() % 31
  ivSpAtk = randi() % 31
  ivSpDef = randi() % 31
  ivSpd = randi() % 31

  # TODO: Breeding & IVs

  # -- EVs ------------------------------------------------------------------------------------------------------------
  
  # EVs start at 0
  evHp = 0
  evAtk = 0
  evDef = 0
  evSpAtk = 0
  evSpDef = 0
  evSpd = 0

  # -- Held Items -----------------------------------------------------------------------------------------------------

  # if we're not an egg, we can have a held item
  if !isEgg && wildItems.size() > 0:
    for pair in wildItems:
      if randi() % 100 < wildItems[pair]:
        item = pair
        break

  # -- Friendship ------------------------------------------------------------------------------------------------------

  # friendship starts at base friendship, unless we're an egg. then it's 0.
  if isEgg:
    happiness = 0
  else:
    happiness = baseHappiness

  # -- Moves ----------------------------------------------------------------------------------------------------------

  # we can have up to 4 moves
  # if we're a wild pokemon, we can have any move we can learn up to our level
  # if we're an egg, we can have any move we can learn up to our level and egg moves
  # if we're a trainer pokemon, we can specify which moves we have. for now this is TODO.

  # -- Stats ----------------------------------------------------------------------------------------------------------

  calculateStats()

  # -- Level ----------------------------------------------------------------------------------------------------------

  # we are specified a level, so we can calculate our xp
  level = startingLevel
  xp = levelToExp(level)
  # check this
  expPercent = floori((xp - levelToExp(level - 1)) / (levelToExp(level) - levelToExp(level - 1) * 1.0))
  

# function to calculate the pokemon's stats
func calculateStats():
  # calculate the pokemon's current stats
  # TODO: going to need to double check this math
  maxHp = floori((2 * baseHp + ivHp + floori(evHp / 4.0)) * level / 100.0) + level + 10
  maxAtk = floori((2 * baseAtk + ivAtk + floori(evAtk / 4.0)) * level / 100.0) + 5
  maxDef = floori((2 * baseDef + ivDef + floori(evDef / 4.0)) * level / 100.0) + 5
  maxSpAtk = floori((2 * baseSpAtk + ivSpAtk + floori(evSpAtk / 4.0)) * level / 100.0) + 5
  maxSpDef = floori((2 * baseSpDef + ivSpDef + floori(evSpDef / 4.0)) * level / 100.0) + 5
  maxSpd = floori((2 * baseSpd + ivSpd + floori(evSpd / 4.0)) * level / 100.0) + 5

  # set the current stats to the max stats
  currentHp = maxHp
  currentAtk = maxAtk
  currentDef = maxDef
  currentSpAtk = maxSpAtk
  currentSpDef = maxSpDef
  currentSpd = maxSpd

# function to add EVs
# TODO: check if the pokemon has max EVs (252 each, 510 total)
func addEVs(stat: String, amount: int):
  # find total
  var total = evHp + evAtk + evDef + evSpAtk + evSpDef + evSpd

  var delta = amount
  # check if the operation will take us over the limit
  if total + amount > 510:
    # find the difference
    delta = 510 - total
  match stat:
    "hp":
      if evHp + delta > 252:
        evHp = 252
      else:
        evHp += delta
    "atk":
      if evAtk + delta > 252:
        evAtk = 252
      else:
        evAtk += delta
    "def":
      if evDef + delta > 252:
        evDef = 252
      else:
        evDef += delta
    "spatk":
      if evSpAtk + delta > 252:
        evSpAtk = 252
      else:
        evSpAtk += delta
    "spdef":
      if evSpDef + delta > 252:
        evSpDef = 252
      else:
        evSpDef += delta
    "spd":
      if evSpd + delta > 252:
        evSpd = 252
      else:
        evSpd += delta
    _:
      print("EV not added. " + stat + " is not a valid stat.")

# function to add a status
# TODO: check if the pokemon already has this status
func addStatus(status: String):
  statuses.append(status)

# function to remove a status
# TODO: check if the pokemon has this status
func removeStatus(status: String):
  statuses.erase(statuses.find(status))

func doDamage(damage: int):
  currentHp -= damage
  hpPercent = floori(currentHp / (maxHp * 1.0))
  if currentHp < 0:
    currentHp = 0
    #emit_signal("pokemon_fainted", self)
  # update the health bar
  #emit_signal("update_health", self)

# function to add a move and check if the pokemon can learn it, by source.
func addMove(move: Move, source: String):
  if (checkMove(move, source)):
    currentMoves.append(move)

# function to check if the pokemon can learn a move, by source. returns true or false.
func checkMove(move: Move, source: String):
  match source:
    "level":
      return true if move in moves else false
    "tm": 
      return true if move in tmMoves else false
    "egg":
      return true if move in eggMoves else false
    "tutor":
      return true if move in tutorMoves else false
    "event":
      return true if move in eventMoves else false
    "debug":
      print_debug("DEBUG: initialised move " + move.moveName + " for " + pName)
      return true
    _: 
      return false

# function to remove a move
func removeMove(move: Move) -> void:
  currentMoves.erase(currentMoves.find(move))

# function to swap a move's index
func swapMove(start: int, end: int) -> void:
  # check if the index is valid
  if start < 0 or start > currentMoves.size() or end < 0 or end > currentMoves.size():
    printerr("ERROR: Invalid move index for " + pName + ": " + str(start) + ", " + str(end))
    return

  var temp = currentMoves[start]
  currentMoves[start] = currentMoves[end]
  currentMoves[end] = temp

# get a move by index
func getMove(index: int) -> Move:
  if index < 0 or index > currentMoves.size():
    printerr("ERROR: Invalid move index for " + pName + ": " + str(index))
    return null
  return currentMoves[index]

func setNickname(name: String) -> void:
  nickname = name

func resetNickname() -> void:
  nickname = pName

func expToLevel(val: int) -> int:
  for i in range(1, 101):
    if levelToExp(i) > val:
      return i - 1
  printerr("ERROR: Could not calculate level for " + pName)
  return -1

# function to calculate the pokemon's current experience progress
func levelToExp(val: int) -> int:
  # calculate the pokemon's current experience progress
  match levellingRate:
    levellingRates.SLOW:
      return floori ((5 * val * val * val) / 4.0)

    levellingRates.MEDIUM_SLOW:
      return floori ((6 * val * val * val) / 5.0) - (15 * val * val) + (100 * val) - 140

    levellingRates.MEDIUM_FAST:
      return floori (val * val * val)

    levellingRates.FAST:
      return floori ((4 * val * val * val) / 5.0)

    levellingRates.ERRATIC:
      if level <= 50:
        return floori (((100 - val) * val * val) / 50.0)
      elif level <= 68:
        return floori (((150 - val) * val * val) / 100.0)
      elif level <= 98:
        return floori ((floori((1911 - 10 * val) / 3.0) * val * val) / 500.0)
      else:
        return floori (((160 - val) * (val * val * val)) / 100.0)

    levellingRates.FLUCTUATING:
      if val <= 15:
        return floori ((val * val * val) * (floori((val + 1) / 3.0) + 24) / 50.0)
      elif val <= 36:
        return floori ((val * val * val) * (val + 14) / 50.0)
      else:
        return floori ((val * val * val) * (floori(val / 2.0) + 32) / 50.0)

    _:
      printerr("ERROR: Invalid levelling rate for " + pName)
      return -1


#func pokemonToDict() -> Dictionary:
#  return {
#    pid: pid,
#    shiny: shiny,
#    metLocation: metLocation,
#    metLevel: metLevel,
#    metDate: metDate,
#    fatefulEncounter: fatefulEncounter,
#    metAsEgg: metAsEgg,
#    recievedDate: recievedDate,
#    ball: ball,
#    nickname: nickname,
#    ot: ot,
#    gender: gender,
#    xp: xp,
#    level: level,
#    expPercent: expPercent,
#    currentHp: currentHp,
#    currentAtk: currentAtk,
#    currentDef: currentDef,
#    currentSpAtk: currentSpAtk,
#    currentSpDef: currentSpDef,
#    currentSpd: currentSpd,
#    maxHp: maxHp,
#    maxAtk: maxAtk,
#    maxDef: maxDef,
#    maxSpAtk: maxSpAtk,
#    maxSpDef: maxSpDef,
#    maxSpd: maxSpd,
#    ivHp: ivHp,
#    ivAtk: ivAtk,
#    ivDef: ivDef,
#    ivSpAtk: ivSpAtk,
#    ivSpDef: ivSpDef,
#    ivSpd: ivSpd,
#    evHp: evHp,
#    evAtk: evAtk,
#    evDef: evDef,
#    evSpAtk: evSpAtk,
#    evSpDef: evSpDef,
#    evSpd: evSpd,
#    atkStage: atkStage,
#    defStage: defStage,
#    spAtkStage: spAtkStage,
#    spDefStage: spDefStage,
#    spdStage: spdStage,
#    accStage: accStage,
#    evaStage: evaStage,
#    hpPercent: hpPercent,
#    currentMoves: currentMoves,
#    statuses: statuses,
#    ability: ability,
#    nature: nature,
#    item: item,
#    happiness: happiness,
#    isEgg: isEgg,
#    giveHiddenAbility: giveHiddenAbility,
#    partyIndex: partyIndex,
#  }
#
#func dictToPokemon(dict: Dictionary) -> 