class_name Move_Growl extends Move

# commented values are unused for this move

func _init():
  id = 45
  power = 0
  #priority = 0
  moveName = "Growl"
  moveType = Type.list.NORMAL
  moveClass = Move.moveClasses.STATUS
  moveTarget = Move.moveTargets.ADJACENT_FOES
  accuracy = 100
  pp = 40
  ppCurrent = pp
  ppMax = floori(pp * (8.0/5.0))
  #ppUpsUsed = 0
  moveDescription = "The user growls in an endearing way, making opposing Pokémon less wary. This lowers their Attack stat."
  #moveEffect = {
  #  Move.moveEffects.NONE: 0,
  #}
  #moveEffectTurns = Vector2i(0,0)
  statChangeType = Move.statChangeTypes.ALL
  statChanges = [
    -1, # attack
    0, # defense
    0, # special attack
    0, # special defense
    0, # speed
    0, # accuracy
    0, # evasion
  ]
  statChangeChance = 100
  #makesContact = false
  affectedByProtect = true
  affectedByMagicCoat = false
  #affectedBySnatch = false
  affectedByMirrorMove = true
  #affectedByKingsRock = false
	