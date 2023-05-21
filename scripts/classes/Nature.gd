class_name Nature extends Object

# Nature
enum natures {
	HARDY,
  LONELY,
  BRAVE,
  ADAMANT,
  NAUGHTY,
  BOLD,
  DOCILE,
  RELAXED,
  IMPISH,
  LAX,
  TIMID,
  HASTY,
  SERIOUS,
  JOLLY,
  NAIVE,
  MODEST,
  MILD,
  QUIET,
  BASHFUL,
  RASH,
  CALM,
  GENTLE,
  SASSY,
  CAREFUL,
  QUIRKY,
}

static func natureToString(nature: natures) -> String:
	# returns the string representation of the nature
	match nature:
		natures.HARDY: return "Hardy"
		natures.LONELY: return "Lonely"
		natures.BRAVE: return "Brave"
		natures.ADAMANT: return "Adamant"
		natures.NAUGHTY: return "Naughty"
		natures.BOLD: return "Bold"
		natures.DOCILE: return "Docile"
		natures.RELAXED: return "Relaxed"
		natures.IMPISH: return "Impish"
		natures.LAX: return "Lax"
		natures.TIMID: return "Timid"
		natures.HASTY: return "Hasty"
		natures.SERIOUS: return "Serious"
		natures.JOLLY: return "Jolly"
		natures.NAIVE: return "Naive"
		natures.MODEST: return "Modest"
		natures.MILD: return "Mild"
		natures.QUIET: return "Quiet"
		natures.BASHFUL: return "Bashful"
		natures.RASH: return "Rash"
		natures.CALM: return "Calm"
		natures.GENTLE: return "Gentle"
		natures.SASSY: return "Sassy"
		natures.CAREFUL: return "Careful"
		natures.QUIRKY: return "Quirky"
		_:
			printerr("ERROR: invalid nature " + str(nature))
			return "ERROR"

static func natureToStat(nature: natures) -> Array:
	# returns an array of 6 ints, each representing the change in the corresponding stat
	# the order is HP, ATK, DEF, SPATK, SPDEF, SPD
	match nature:
		natures.LONELY: return [0,1,-1,0,0,0]
		natures.BRAVE: return [0,1,0,0,0,-1]
		natures.ADAMANT: return [0,1,0,-1,0,0]
		natures.NAUGHTY: return [0,1,0,0,-1,0]
		natures.BOLD: return [0,-1,1,0,0,0]
		natures.RELAXED: return [0,0,1,0,0,-1]
		natures.IMPISH: return [0,0,1,-1,0,0]
		natures.LAX: return [0,0,1,0,-1,0]
		natures.TIMID: return [0,-1,0,0,0,1]
		natures.HASTY: return [0,0,-1,0,0,1]
		natures.JOLLY: return [0,0,0,0,-1,1]
		natures.NAIVE: return [0,0,0,-1,0,1]
		natures.MODEST: return [0,-1,0,1,0,0]
		natures.MILD: return [0,0,-1,1,0,0]
		natures.QUIET: return [0,0,0,1,0,-1]
		natures.RASH: return [0,0,0,1,-1,0]
		natures.CALM: return [0,-1,0,0,1,0]
		natures.GENTLE: return [0,0,-1,0,1,0]
		natures.SASSY: return [0,0,0,0,1,-1]
		natures.CAREFUL: return [0,0,0,-1,1,0]
		_:
			# this includes natures.HARDY, natures.DOCILE, natures.SERIOUS, natures.BASHFUL and natures.QUIRKY
			return [0,0,0,0,0,0]

static func intToNature(val: int) -> natures:
	# returns the nature corresponding to the given int
	# the int should be between 0 and 24
	if val < 0 or val > 24:
		printerr("ERROR: invalid nature int " + str(val))
		return natures.HARDY
	match val:
		0: return natures.HARDY
		1: return natures.LONELY
		2: return natures.BRAVE
		3: return natures.ADAMANT
		4: return natures.NAUGHTY
		5: return natures.BOLD
		6: return natures.DOCILE
		7: return natures.RELAXED
		8: return natures.IMPISH
		9: return natures.LAX
		10: return natures.TIMID
		11: return natures.HASTY
		12: return natures.SERIOUS
		13: return natures.JOLLY
		14: return natures.NAIVE
		15: return natures.MODEST
		16: return natures.MILD
		17: return natures.QUIET
		18: return natures.BASHFUL
		19: return natures.RASH
		20: return natures.CALM
		21: return natures.GENTLE
		22: return natures.SASSY
		23: return natures.CAREFUL
		24: return natures.QUIRKY
		_:
			printerr("ERROR: invalid nature int " + str(val))
			return natures.HARDY