class_name Move extends Object

enum moveClasses {
  PHYSICAL,
  SPECIAL,
  STATUS,
  NONE, # fallback, error if this is used
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
var moveName: String = ""
var moveType: Type.list = Type.list.NONE
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
var makesContact: bool = false
var affectedByProtect: bool = false
var affectedByMagicCoat: bool = false
var affectedBySnatch: bool = false
var affectedByMirrorMove: bool = false
var affectedByKingsRock: bool = false
var disabled: bool = false
var disabledTurns: int = 0
