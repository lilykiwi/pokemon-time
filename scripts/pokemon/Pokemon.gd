# A pokemon has an id, name, type, as well as starting stat spreads.
# we need to implement multiple 
class_name Pokemon
extends Resource

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

# the growth rate type
var growthRate: String

# Gender Ratio
var genderThreshold: int # 0-255. 256 = male only, 257 = female only, 258 = genderless
var description: String
var weight: int
var height: int

# The pokemon's type
var pType1: String
# the second type
var pType2: String

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
var hiddenAbility: String = ""

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

# Nature stuff

var natures = [
  "Hardy",
  "Lonely",
  "Brave",
  "Adamant",
  "Naughty",
  "Bold",
  "Docile",
  "Relaxed",
  "Impish",
  "Lax",
  "Timid",
  "Hasty",
  "Serious",
  "Jolly",
  "Naive",
  "Modest",
  "Mild",
  "Quiet",
  "Bashful",
  "Rash",
  "Calm",
  "Gentle",
  "Sassy",
  "Careful",
  "Quirky" 
]

# levelling rate. this affects xp-to-next using a dif algorithm for each. this can be:
# slow, medium-slow, medium, medium-fast, fast, erratic, fluctuating
var levellingRates = [
  "slow",
  "medium-slow",
  "medium-fast",
  "fast",
  "erratic",
  "fluctuating"
]

var levellingRate: String = "medium-slow"

# TODO: move the below variables to a separate script, and make it a child of this script:
# these values represent an instance of a pokemon, compared with a prototype for the dex.

# The pokemon's pid number
var pid: int

# Shiny Pokemon. do not set
var shiny: bool

# Origin Game
# var game: String

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
var otId: int
# The OT's secret ID
var otSecretId: int
# Gender of the pokemon
var gender: String

# The pokemon's current experience
var xp: int
# The pokemon's level
# We must not set this directly. We should calculate it using xp. Cannot be above 100.
var level: int
# The pokemon's current experience, as a percentage of the total experience needed to level up
# We must not set this directly. We should calculate it using xp.
var expPercent: float

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

# The pokemon's current moves
# we can only have 4 moves at a time
var currentMoves: Array = []

# The pokemon's current statuses 
var statuses: Array = []

# The pokemon's current ability
var ability: String

# The pokemon's current nature
# TODO: implement nature stat modifiers
var nature: String

# The pokemon's current held item
# TODO: implement item objects
var item: String

# The pokemon's current happiness
var happiness: int

# are we currently an egg? if so, use friendship as a hatch counter
var isEgg: bool

# flag for whether or not a pokemon gets a hidden ability. set this in the editor
var giveHiddenAbility: bool = false

# party index
var partyIndex: int = -1

func generate(): 
  # todo: get the player's name when caught
  ot = ""
  # do we need these? seems antiquitated.
  # otId = 0
  # otSecretId = 0

  # this is 0-4,294,967,295, 32bit but Godot is 64bit
  pid = randi() % 4294967295

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
      print("")
  else:
    # we need to work it out using mod
    # this differs dramatically from the typical technique, but it's easier
    # and we don't need to worry about memory & storage at this stage.
    if (pid % 255 > genderThreshold):
      gender = "male"
    else:
      gender = "female"

  # TODO: Cute Charm ability

  # -- Nature ---------------------------------------------------------------------------------------------------------

  # TODO: stat modifiers
  nature = natures[pid % natures.size()]

  # TODO: Breeding & Nature
  # TODO: Synchronize

  # -- Ability --------------------------------------------------------------------------------------------------------

  # pokemon have 1 or 2 abilities, and a hidden ability. 
  # hidden ability is source-specific, so we'll need to check that.

  # we *could* grab one bit.... but mod is easy.

  if hiddenAbility != "" && giveHiddenAbility:
    ability = hiddenAbility
  else:
    ability = abilities[pid % abilities.size()]

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



# function to calculate the pokemon's stats
func calculateStats():
  # calculate the pokemon's current stats
  # TODO going to need to double check this math
  currentHp = floori((2 * baseHp + ivHp + floori(evHp / 4.0)) * level / 100.0) + level + 10
  currentAtk = floori((2 * baseAtk + ivAtk + floori(evAtk / 4.0)) * level / 100.0) + 5
  currentDef = floori((2 * baseDef + ivDef + floori(evDef / 4.0)) * level / 100.0) + 5
  currentSpAtk = floori((2 * baseSpAtk + ivSpAtk + floori(evSpAtk / 4.0)) * level / 100.0) + 5
  currentSpDef = floori((2 * baseSpDef + ivSpDef + floori(evSpDef / 4.0)) * level / 100.0) + 5
  currentSpd = floori((2 * baseSpd + ivSpd + floori(evSpd / 4.0)) * level / 100.0) + 5

# function to add EVs
# TODO check if the pokemon has max EVs (252 each, 510 total)
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
      print("EV not added." + stat + " is not a valid stat.")

# function to add a status
# TODO check if the pokemon already has this status
func addStatus(status: String):
  statuses.append(status)

# function to remove a status
# TODO check if the pokemon has this status
func removeStatus(status: String):
  statuses.erase(statuses.find(status))

# function to add a move and check if the pokemon can learn it, by source.
func addMove(move: String, source: String):
  if (checkMove(move, source)):
    currentMoves.append(move)

# function to check if the pokemon can learn a move, by source. returns true or false.
func checkMove(move: String, source: String):
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
    _: 
      return false

# function to remove a move
func removeMove(move: String):
  currentMoves.erase(currentMoves.find(move))

# function to swap a move's index
func swapMove(start: int, end: int):
  # check if the moves exists
  if currentMoves.find(start) == -1 or currentMoves.find(end) == -1:
    print("One or more moves do not exist.")
    return

  var temp = currentMoves[start]
  currentMoves[start] = currentMoves[end]
  currentMoves[end] = temp

# get a move by index
func getMove(index: int):
  return currentMoves[index]

# function to calculate the pokemon's current level
func calculateLevel():
  # calculate the pokemon's current level
  # TODO going to need to double check this math
  if xp < 1000000:
    level = floori(sqrt(xp))
  else:
    level = floori(sqrt(xp / 4.0))

func expToLevel(xp: int):
  for i in range(1, 101):
    if levelToExp(i) > xp:
      return i - 1
  pass

# function to calculate the pokemon's current experience progress
func levelToExp(level: int):
  # calculate the pokemon's current experience progress
  match levellingRate:
    "slow":
      return floor((5 * level * level * level) / 4.0)
    "medium-slow":
      return ((6 * level * level * level) / 5.0) - (15 * level * level) + (100 * level) - 140
    "medium-fast":
      return level * level * level
    "fast":
      return (4 * level * level * level) / 5.0
    "erratic":
      if level <= 50:
        return floori((100 - level) * level * level) / 50.0
      elif level <= 68:
        return floori((150 - level) * level * level) / 100.0
      elif level <= 98:
        return floori(floori((1911 - 10 * level) / 3.0) * level * level) / 500.0
      else:
        return floori((160 - level) * (level * level * level)) / 100.0
    "fluctuating":
      if level <= 15:
        return floori ((level * level * level) * (floori((level + 1) / 3.0) + 24) / 50.0)
      elif level <= 36:
        return floori ((level * level * level) * (level + 14) / 50.0)
      else:
        return floori ((level * level * level) * (floori(level / 2.0) + 32) / 50.0)