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

# store all possible states
var states = [
  "PlayerTurn",
  "EnemyTurn",
  "Action",
  "EndBattle",
]

var playerState = [
  "PlayerAttack",
  "PlayerItem",
  "PlayerPokemon",
  "PlayerRun",
]

var enemyState = [
  "EnemyAttack",
  "EnemyItem",
  "EnemyPokemon",
  "EnemyRun",
]

# store the current state
var current_state = null

# store the player and enemy team
var player = []
var enemy = []

# store the player and enemy pokemon
var player_pokemon: Pokemon = null
var enemy_pokemon: Pokemon = null

func _ready():

  # set the current state to PlayerTurn
  current_state = states[0]

  pass