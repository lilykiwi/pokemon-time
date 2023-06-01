class_name Move_VineWhip extends Move

# commented values are unused for this move

func _init():
  id = 22
  power = 35
  #priority = 0
  moveName = "Vine Whip"
  moveType = Type.list.GRASS
  moveClass = Move.moveClasses.PHYSICAL
  #moveTargetStat = Move.defenderStat.NONE
  moveTarget = Move.moveTargets.SINGLE
  accuracy = 100
  pp = 15
  ppCurrent = pp
  ppMax = floori(pp * (8.0/5.0))
  #ppUpsUsed = 0
  moveDescription = "The target is struck with slender, whiplike vines to inflict damage."
  #moveEffect = {
  #  Move.moveEffects.NONE: 0,
  #}
  #moveEffectTurns = Vector2i(0,0)
  #statChangeType = Move.statChangeTypes.ALL
  #statChanges = [
  #  0, # attack
  #  0, # defense
  #  0, # special attack
  #  0, # special defense
  #  0, # speed
  #  0, # accuracy
  #  0, # evasion
  #]
  statChangeChance = 100
  makesContact = true
  affectedByProtect = true
  affectedByMagicCoat = false
  affectedBySnatch = false
  affectedByMirrorMove = true
  affectedByKingsRock = true
