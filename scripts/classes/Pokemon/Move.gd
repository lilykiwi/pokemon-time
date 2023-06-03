class_name Move extends Object

enum moveClasses {
  PHYSICAL,
  SPECIAL,
  ONLY_STATUS,
  NONE, # fallback, error if this is used
}

# for moves that use the attacker's physical and defenders spdef, for example.
enum defenderStat {
  PHYSICAL,
  SPECIAL,
  FIXED_DAMAGE,
  NONE, # fallback, if this is used then presume it uses moveClass
}

# Triple battles specify single adjacent or single non adjacent, but wontfix because I don't care about triple battles
enum moveTargets {
  SINGLE, 
  ADJACENT_ALL,
  ADJACENT_FOES,
  ADJACENT_ALLIES,
  ALL,
  ALL_FOES,
  ALL_ALLIES,
  NONE, # fallback, error if this is used
}

# TODO: Check these
enum moveEffects {
  NONE,
  BURN,
  FREEZE,
  PARALYZE,
  POISON,
  SLEEP,
  CONFUSION,
  FLINCH,
  INFATUATION,
  TRAP,
  NIGHTMARE,
  CURSE,
  YAWN,
  DISABLE,
  HEALBLOCK,
  EMBARGO,
  PERISHSONG,
  INGRAIN,
  AQUARING,
  MAGNETRISE,
  TELEKINESIS,
  LEECHSEED,
  TORMENT,
  TAUNT,
  HEALINGWISH,
  LUNARDANCE,
  WISH,
}

# TODO: Check these
enum statChangeTypes {
  RANDOM,
  ALL,
  NONE, # fallback
}

var id: int = 0
var power: int = 0
var priority: int = 0
#var critRatio: int = 0
var moveName: String = ""
var moveType: Type.list = Type.list.NONE
var moveTargetStat: defenderStat = defenderStat.NONE
var moveClass: moveClasses = moveClasses.NONE
var moveTarget: moveTargets = moveTargets.NONE
var accuracy: int = 0
var pp: int = 0
var ppCurrent: int = 0
var ppMax: int = 0
var ppUpsUsed: int = 0
var moveDescription: String
var moveEffect: Dictionary = { # effect and chance
  moveEffects.NONE: 0,
}
var moveEffectTurns: Vector2i
var statChangeType: statChangeTypes = statChangeTypes.NONE
var statChanges: Array = [
  0, # attack
  0, # defense
  0, # special attack
  0, # special defense
  0, # speed
  0, # accuracy
  0, # evasion
]
var statChangeChance: int = 0
var selfStatChangeType: statChangeTypes = statChangeTypes.NONE
var selfStatChanges: Array = [
  0, # attack
  0, # defense
  0, # special attack
  0, # special defense
  0, # speed
  0, # accuracy
  0, # evasion
]
var selfStatChangeChance: int = 0
var makesContact: bool = false
var affectedByProtect: bool = false
var affectedByMagicCoat: bool = false
var affectedBySnatch: bool = false
var affectedByMirrorMove: bool = false
var affectedByKingsRock: bool = false
var disabled: bool = false
var disabledTurns: int = 0

func calcAccuracyThreshold(userAccStage: int, targetEvaStage: int) -> float:
  if accuracy != -1:
    return 100
  else: 
    var stageModifier = userAccStage - targetEvaStage
    stageModifier.clamp(-6, 6)
    if (stageModifier < 0):
      return (accuracy * (3.0 / (3.0 - stageModifier))).clamp(0, 100)
    elif (stageModifier > 0):
      return (accuracy * ((3.0 + stageModifier) / 3.0)).clamp(0, 100)
    return 100

func calcAccuracyHit(userAccStage: int, targetEvaStage: int) -> bool:
  if accuracy != -1:
    # TODO: stagemod
    # sum: -6 to 6
    # -6   -5   -4   -3   -2   -1   0    1    2    3    4    5    6
    # 3/9, 3/8, 3/7, 3/6, 3/5, 3/4, 3/3, 4/3, 5/3, 6/3, 7/3, 8/3, 9/3
    var hitThreshold = calcAccuracyThreshold(userAccStage, targetEvaStage)
    var hitRoll = randi() % 100
    if hitRoll > hitThreshold:
      # the move missed
      print("The move missed!")
      print("Hit threshold: " + str(hitThreshold))
      return false
  return true

func calculateDamage(user: Pokemon, target: Pokemon, crit: bool) -> int:

  var damage: int  = 0

  var effectiveAtk: float = 0
  var effectiveDef: float = 0

  
  if (moveClass == Move.moveClasses.ONLY_STATUS):
    # status move
    return 0

  if (moveClass == Move.moveClasses.PHYSICAL):
    effectiveAtk = user.currentAtk
    effectiveDef = target.currentDef
  if (moveClass == Move.moveClasses.SPECIAL):
    effectiveAtk = user.currentSpAtk
    effectiveDef = target.currentSpDef

  if (moveClass == Move.moveClasses.NONE):
    # fallback, error if this is used
    print("Error: moveClass is NONE, this should not happen")
    return 0

  if (moveTargetStat == Move.defenderStat.FIXED_DAMAGE):
    # fixed damage move
    damage = power

  if (moveTargetStat == Move.defenderStat.SPECIAL):
    effectiveDef = target.currentSpDef
  if (moveTargetStat == Move.defenderStat.PHYSICAL):
    effectiveDef = target.currentDef

  damage = ((2*user.level)/5.0 * power * (effectiveAtk / effectiveDef)) / 50.0 + 2
  
  # 0.75x if more than one target, otherwise 1.0x

  # TODO: Parental Bond -> ability for Mega Kangaskhan

  # TODO: Weather
  # -- FLAT 1.0x if Cloud Nine or Air Lock ability is present on field
  # - 1.5x if water in rain
  # - 0.5x if fire in rain
  # - 1.5x if fire in sun (or Hydro Steam)
  # - 0.5x if water in sun (except for Hydro Steam)

  # TODO: 2x if last move is Glaive Rush -> move for Baxcalibur (are we adding this?)

  # TODO: crit check
  # 1.5x if crit (gen5 is 2x, but meh)
  # https://bulbapedia.bulbagarden.net/wiki/Critical_hit

  # crit stage varies from +0 to +4
  # +0 is 1/16 chance
  # +1 is 1/8 chance
  # +2 is 1/2 chance
  # +3 and above is 1/1 chance
  # we don't currently have a crit stage, so we'll use +0 for now
  if crit:
    damage *= 1.5

  # random damage range 0.85 - 1.00
  var randomMod = randi() % 16 + 85
  damage *= (randomMod / 100.0)

  # TODO: apply stab

  # type modifier
  # we can get the types of the pokemon from the target pokemon's type list
  # see Type.gd for more info on how this works
  var typeMod = Type.computeEffectiveness(moveType, target.types[0], target.types[1])
  damage *= typeMod

  # TODO: burn check
  # 0.5x if user is burned, move is physical, and ability isn't guts.
  # otherwise 1.0x

  # Extra Checks - ALL STACK MULTIPLICATIVELY:
  # Dynamax - 2.0x with Behemoth Blade, Behemoth Bash, Dynamax Cannon if Dynamaxed (are we adding this?)
  # Minimize - 2.0x for https://bulbapedia.bulbagarden.net/wiki/Minimize_(move)#Vulnerability_to_moves
  # Earthquake and Magnitude - 2.0x if target is in Dig invulnerability
  # Surf and Whirlpool - 2.0x if target is in Dive invulnerability
  # Reflect, Light Screen, Aurora Veil - 0.5x if target is behind one of these and move is affected by it
  #   -> https://bulbapedia.bulbagarden.net/wiki/Reflect_(move)#Generation_V_onwards
  #   -> https://bulbapedia.bulbagarden.net/wiki/Light_Screen_(move)#Generation_V_onwards
  #   -> https://bulbapedia.bulbagarden.net/wiki/Aurora_Veil_(move)#Effect
  # Collision Course and Electro Drift - ~1.3333x (5461/4096) gen 9 stuff do we care
  # Fluffy, 0.5 if check passes
  # Punk Rock, 0.5 if check passes
  # Ice Scales, 0.5 if check passes
  # Friend Guard, 0.75 if check passes
  # Filter, Prism Armor, and Solid Rock, 0.75 if check passes
  # Neuroforce, 1.25 if check passes
  # Sniper, 1.5x if check passes
  # Tinted Lens, 2.0x if check passes
  # Fluffy, 2.0x if check passes (if move is fire type)
  # Type-resist Berries, 0.5x if check passes
  #    -> 0.25x if ability is Ripen
  # Expert Belt, ~1.2x (4915/4096) if held by the attacker and the move is super effective (type mod > 1.0)
  # Life Orb, ~1.3x (5324/4096) if held by attacker
  # Metronome, up to 2.0x, add ~0.2x (819/4096) for each consecutive use of the same move

  # ZMove is 0.25 if conditions are met (meh)
  # TeraShield sure is a thing. (meh)

  # TODO: type coersion and rounding
  if damage > 1 and damage < 0:
    damage = 1

  if damage < 0:
    print("Damage is less than 0: " + str(damage))
    #return Vector4i(0,0,0,0)

  ## TODO: apply status effects
  # we round to an int here. the games typically round on each operation, but we don't need to do that.
  print(str(round(damage)))

  return damage

func calculateCrit(critStage: int) -> bool:
  # crit stage varies from +0 to +4
  # +0 is 1/16 chance
  # +1 is 1/8 chance
  # +2 is 1/2 chance
  # +3 and above is 1/1 chance
  # we don't currently have a crit stage, so we'll use +0 for now
  var randomCrit = 0
  match critStage:
    0:
      randomCrit = randi()%16
    1:
      randomCrit = randi()%8
    2:
      randomCrit = randi()%2
    _:
      randomCrit = 1
  if randomCrit == 0:
    return true
  else:
    return false

func computeMove(user, target) -> MoveOutcome:

  var moveOutcome = MoveOutcome.new()

  # calculate hit chance
  var hit: bool = calcAccuracyHit(user.accStage, target.evaStage)
  if (hit == false):
    return moveOutcome.missed(self)

  var crit: bool = false
  var superEffective: bool = false
  var notVeryEffective: bool = false
  var damage: int = 0
  
  if !(moveType == moveClasses.ONLY_STATUS):
    # calculate crit chance
    crit = calculateCrit(0)
    superEffective = Type.computeEffectiveness(moveType, target.types[0], target.types[1]) > 1.0
    notVeryEffective = Type.computeEffectiveness(moveType, target.types[0], target.types[1]) < 1.0
    # calculate damage
    damage = calculateDamage(user, target, crit)

  # todo statuses
  return moveOutcome.hit(self, damage, superEffective, notVeryEffective, crit, [])


class MoveOutcome:

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
  
  @warning_ignore("shadowed_variable")
  func missed(move: Move):
    self.move = move
    self.crit = false
    self.damage = 0
    self.miss = true
    self.status = []
    
    return self
  
  @warning_ignore("shadowed_variable")
  func hit(move: Move, damage: int, superEffective: bool, notVeryEffective: bool, crit: bool, status: Array[StatusEffect]):
    self.move = move
    self.crit = crit
    self.damage = damage
    self.miss = false
    self.status = status
    self.superEffective = superEffective
    self.notVeryEffective = notVeryEffective
    
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
  