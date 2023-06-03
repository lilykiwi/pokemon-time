extends Node

# An enemy AI.

var enemyTeam: Array[Pokemon] = []
var ourTeam: Team = null
var enemyPokemon: Pokemon = null
var ourPokemon: Pokemon = null

func _init(team: Team):
  ourTeam = team

func storeEnemyPokemon(pokemon: Pokemon):
  enemyPokemon = pokemon
  if enemyTeam.size() == 0:
    enemyTeam.append(pokemon)
  else:
    enemyTeam[0] = pokemon

func inferEnemyPokemon(pokemon: Pokemon):
  var baseHp = pokemon.baseHp
  var baseAtk = pokemon.baseAtk
  var baseDef = pokemon.baseDef
  var baseSpAtk = pokemon.baseSpAtk
  var baseSpDef = pokemon.baseSpDef
  var baseSpd = pokemon.baseSpd

  var level = pokemon.level

  var types = [
    pokemon.type1,
    pokemon.type2
  ]

  # compute the worst case scenario in terms of stats
  var maxHp = floori((2 * baseHp + 31 + floori(252 / 4.0)) * level / 100.0) + level + 10
  var maxAtk = floori((2 * baseAtk + 31 + floori(252 / 4.0)) * level / 100.0) + 5
  var maxDef = floori((2 * baseDef + 31 + floori(252 / 4.0)) * level / 100.0) + 5
  var maxSpAtk = floori((2 * baseSpAtk + 31 + floori(252 / 4.0)) * level / 100.0) + 5
  var maxSpDef = floori((2 * baseSpDef + 31 + floori(252 / 4.0)) * level / 100.0) + 5
  var maxSpd = floori((2 * baseSpd + 31 + floori(252 / 4.0)) * level / 100.0) + 5

  # we are allowed to grab the percentage of the enemy's health
  var enemyHpPercentage = pokemon.hpPercent
  var enemyHp = floori(maxHp * enemyHpPercentage)

  # compare our type matchup against the enemy's type
  # positive values mean we are strong against the enemy
  var typeMatchup = Type.computeMatchupFromStats(ourPokemon, pokemon)

  # do we want to do a status move or a damage move?
  # if we are both at full health, we want to do either a status move or a damage move
  # if we are at low health, we want to heal and switch (in that order)
  # if there's no good switch, we want to do a status move
  # if they are at low health, we want to do a damage move
  # low health is defined as <1/2 of our max health

  var healValue = 0
  if ourPokemon.hpPercent < 0.5:
    healValue = 150

  # for each of our moves, compute the damage we can do and it's likelihood of hitting
  var moveValuesDamage: Array[int] = []
  for move in ourPokemon.moves:
    var damage = Move.computeDamage(ourPokemon, pokemon, move)
    var accuracy = move.accuracy
    var value: int = damage * accuracy
    moveValuesDamage.append(value)

  # for each of our moves, compute the damage we can do and it's likelihood of hitting
  var moveValuesStatus: Array[int] = []
  for move in ourPokemon.moves:
    var isStatus = move.moveClass == Move.moveClasses.ONLY_STATUS
    var hasStatus = false
    for effect in move.moveEffect:
       hasStatus = move.moveEffect != Move.moveEffects.NONE
    var accuracy = move.accuracy
    var value: int = 15
    moveValuesStatus.append(value)

  var bestMove = -1
  var canKill = false
  for value in moveValuesDamage:
    if value > enemyHp:
      bestMove = value
      canKill = true
      break
    elif value > moveValuesDamage[bestMove]:
      bestMove = value

  var damageMoveValue = 0
  if bestMove == -1:
    damageMoveValue = 0
  else: 
    damageMoveValue = 25

  var statusMoveValue = 0
  for value in moveValuesStatus:
    if value > statusMoveValue:
      statusMoveValue = value

  if canKill:
    # we can kill the enemy, so we should do that. lol.
    damageMoveValue *= 5

  var switchValue = 0
  if typeMatchup <= 1:
    # we are weak against the enemy, so we should switch out or do a status move
    switchValue = 150


  match decideByWeight({
    "heal": healValue,
    "switchValue": switchValue,
    "statusMove": damageMoveValue,
    "damageMove": statusMoveValue,
  }):
    "heal":
      print ("heal")
    "switchValue":
      print ("switch")
    "statusMove":
      print (ourPokemon.moves[bestMove].moveName)
    "damageMove":
      print (ourPokemon.moves[bestMove].moveName)


func decideByWeight(decisions: Dictionary):
  var totalWeight: int = 0
  for decision in decisions:
    totalWeight += decision.weight

  var random = randi() % totalWeight
  var currentWeight = 0
  for decision in decisions:
    currentWeight += decision.weight
    if random < currentWeight:
      return decision

  return decisions[0]

func decideOnMove():

  # 

  return ""

func decideOnStatusMove():
  return ""

func decideOnDamageMove():
  return ""

func trySwitch():
  return ""

func tryHeal():
  return ""