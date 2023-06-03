class_name Team extends Object

var isWildEncounter: bool = false
var isTrainerEncounter: bool = false

class WildEncounter extends Team:
  var pokemon: Pokemon = null

  func _init():
    isWildEncounter = true
    isTrainerEncounter = false

class TrainerEncounter extends Team:
  var team: Array[Pokemon] = []

  func _init(startTeam: Array[Pokemon]):
    isWildEncounter = false
    isTrainerEncounter = true
    self.team = startTeam
