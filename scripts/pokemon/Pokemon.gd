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
var forms: Array = []

# held items in the wild, along with their chances
var wildItems: Dictionary = {}

# the growth rate type
var growthRate: String

# Gender Ratio
var genderRatio: float
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
# list of moves the pokemon can learn, by breeding
var eggMoves: Array = []
# list of moves the pokemon can learn, by tutor
var tutorMoves: Array = []
# list of moves the pokemon can learn, by event
var eventMoves: Array = []
# The abilities the pokemon can have
var abilities: Array = []

# The pokemon's base experience yield
var baseExp: int

# The pokemon's base EV yield
var yieldEVHp: int
var yieldEVAtk: int
var yieldEVDef: int
var yieldEVSpAtk: int
var yieldEVSpDef: int
var yieldEVSpd: int

# The pokemon's base happiness
var baseHappiness: int
# The pokemon's base friendship
var baseFriendship: int

# The pokemon's capture rate
var captureRate: int

# Hatch time in steps
var hatchTime: int

# The pokemon this evolves into
var evolvesInto: Pokemon

# The pokemon this evolves from
var evolvesFrom: Pokemon

# The pokemon's evolution method
var evolutionMethod: String

# The pokemon's evolution level
var evolutionLevel: int

# The pokemon's evolution item
var evolutionItem: String

# TODO: move the below variables to a separate script, and make it a child of this script:
# these values represent an instance of a pokemon, compared with a prototype for the dex.

# The pokemon's UID number
var uid: int

# Shiny Pokemon
var shiny: bool

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
var nature: String

# The pokemon's current held item
var item: String

# The pokemon's current happiness
var happiness: int
# The pokemon's current friendship
var friendship: int

# function to calculate the pokemon's stats
func calculateStats():
  # calculate the pokemon's current stats
  # TODO going to need to double check this math
  currentHp = floori((2 * baseHp + ivHp + floori(evHp / 4)) * level / 100) + level + 10
  currentAtk = floori((2 * baseAtk + ivAtk + floori(evAtk / 4)) * level / 100) + 5
  currentDef = floori((2 * baseDef + ivDef + floori(evDef / 4)) * level / 100) + 5
  currentSpAtk = floori((2 * baseSpAtk + ivSpAtk + floori(evSpAtk / 4)) * level / 100) + 5
  currentSpDef = floori((2 * baseSpDef + ivSpDef + floori(evSpDef / 4)) * level / 100) + 5
  currentSpd = floori((2 * baseSpd + ivSpd + floori(evSpd / 4)) * level / 100) + 5

# function to add EVs
# TODO check if the pokemon has max EVs (252 each, 510 total)
func addEVs(stat: String, amount: int):
    if stat == "hp":
        evHp += amount
    elif stat == "atk":
        evAtk += amount
    elif stat == "def":
        evDef += amount
    elif stat == "spAtk":
        evSpAtk += amount
    elif stat == "spDef":
        evSpDef += amount
    elif stat == "spd":
        evSpd += amount
    else:
        print("Invalid stat")

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
    if source == "level":
        if move in moves:
            currentMoves.append(move)
        else:
            print("Pokemon cannot learn this move by level up.")
    elif source == "tm":
        if move in tmMoves:
            currentMoves.append(move)
        else:
            print("Pokemon cannot learn this move by TM.")
    elif source == "egg":
        if move in eggMoves:
            currentMoves.append(move)
        else:
            print("Pokemon cannot learn this move by breeding.")
    elif source == "tutor":
        if move in tutorMoves:
            currentMoves.append(move)
        else:
            print("Pokemon cannot learn this move by tutor.")
    elif source == "event":
        if move in eventMoves:
            currentMoves.append(move)
        else:
            print("Pokemon cannot learn this move by event.")
    else:
        print("Invalid source.")

# function to remove a move
func removeMove(move: String):
    currentMoves.erase(currentMoves.find(move))

# function to swap a move's index
func swapMove(start: int, end: int):
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
        level = floori(sqrt(xp / 4))

# generate a UID for the pokemon
# TODO: research this lol
