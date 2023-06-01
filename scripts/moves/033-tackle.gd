class_name Move_Tackle extends Move

# commented values are unused for this move

func _init():
  id = 33
  power = 50
  #priority = 0
  #var critRatio = 0
  moveName = "Tackle"
  moveType = Type.list.NORMAL
  #moveTargetStat = Move.defenderStat.NONE
  moveClass = Move.moveClasses.PHYSICAL
  moveTarget = Move.moveTargets.SINGLE
  accuracy = 100
  pp = 35
  ppCurrent = pp
  ppMax = floori(pp * (8.0/5.0))
  #ppUpsUsed = 0
  moveDescription = "A physical attack in which the user charges and slams into the target with its whole body."
  #moveEffect = {
  #  Move.moveEffects.NONE: 0,
  #}
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
  #selfStatChangeType = Move.statChangeTypes.NONE
  #selfStatChanges = [
  #  0, # attack
  #  0, # defense
  #  0, # special attack
  #  0, # special defense
  #  0, # speed
  #  0, # accuracy
  #  0, # evasion
  #]
  #selfStatChangeChance = 0
  makesContact = true
  affectedByProtect = true
  #affectedByMagicCoat = false
  #affectedBySnatch = false
  affectedByMirrorMove = true
  affectedByKingsRock = true
  #disabled = false
  #disabledTurns = 0
