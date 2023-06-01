class_name MoveOutcome extends Object

# Public: A MoveOutcome represents the result of a move. It contains the
# following information:
# - The move that was made
# - The crit status of the move
# - The damage dealt by the move

var move: Move = null
var damage: int = 0
var superEffective: bool = false
var notVeryEffective: bool = false
var crit: bool = false
var miss: bool = false
var status: Array[StatusEffect] = []

func missed(move: Move):
  self.move = move
  self.crit = false
  self.damage = 0
  self.miss = true
  self.status = []
  
  return self

func hit(move: Move, damage: int, superEffective: bool, notVeryEffective: bool, crit: bool, status: Array[StatusEffect]):
  self.move = move
  self.crit = crit
  self.damage = damage
  self.miss = false
  self.status = status
  
  return self

func printInfo():
  if self.miss:
    print("The move " + self.move.moveName + " missed!")
  else:
    print("The move " + self.move.moveName + " hit!")
    if self.superEffective:
      print("It was super effective!")
    if self.notVeryEffective:
      print("It was not very effective...")
    if self.crit:
      print("Critical hit!")
    if self.status.size() > 0:
      print("Status effects applied:")
      for statuses in self.status:
        print(statuses.name)
  
  return
