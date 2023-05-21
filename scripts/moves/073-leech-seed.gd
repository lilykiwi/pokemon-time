class_name Move_LeechSeed extends Move

# commented values are unused for this move

func _init():
  id = 73
  power = 0
  #priority = 0
  moveName = "Leech Seed"
  moveType = Type.list.GRASS
  moveClass = Move.moveClasses.STATUS
  moveTarget = Move.moveTargets.SINGLE
  accuracy = 90
  pp = 10
  ppCurrent = pp
  ppMax = floori(pp * (8.0/5.0))
  #ppUpsUsed = 0
  moveDescription = "A seed is planted on the target. It steals some HP from the target every turn."
  moveEffect = {
    Move.moveEffects.LEECHSEED: 100,
  }
  #moveEffectTurns = Vector2i(0,0)
  #statChangeType = Move.statChangeTypes.NONE
  #statChanges = [
  #  0, # attack
  #  0, # defense
  #  0, # special attack
  #  0, # special defense
  #  0, # speed
  #  0, # accuracy
  #  0, # evasion
  #]
  #statChangeChance = 0
  #makesContact = false
  affectedByProtect = true
  affectedByMagicCoat = true
  #affectedBySnatch = false
  affectedByMirrorMove = true
  #affectedByKingsRock = false
	