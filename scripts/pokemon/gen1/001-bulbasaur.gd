class_name Pokemon_Bulbasaur extends Pokemon

# todo: pass in values for level and stuff?
func _init(startingLevel: int, startingMoves: Array):
  dexNum = 001
  pName = "Bulbasaur"
  description = "For some time after its birth, it grows by gaining nourishment from the seed on its back."
  types = Vector2i(Type.list.GRASS, Type.list.NONE)

  baseHp = 45
  baseAtk = 49
  baseDef = 49
  baseSpAtk = 65
  baseSpDef = 65
  baseSpd = 45

  baseHappiness = 70
  captureRate = 45
  genderThreshold = 223  # 87.5% ish

  levellingRate = Pokemon.levellingRates.MEDIUM_SLOW

  expYield = 64

  yieldEVSpAtk = 1

  frontSprite = preload("res://sprites/pokemon/001-bulbasaur/front.png")
  backSprite = preload("res://sprites/pokemon/001-bulbasaur/back.png")
  frontShinySprite = preload("res://sprites/pokemon/001-bulbasaur/front_shiny.png")
  backShinySprite = preload("res://sprites/pokemon/001-bulbasaur/back_shiny.png")

  #todo: icon sprites
  #iconZero = preload("res://sprites/pokemon/001-bulbasaur/icon_0.png")
  #iconOne = preload("res://sprites/pokemon/001-bulbasaur/icon_1.png")

  # abilities
  abilities = [Ability_Overgrow.new()]
  hiddenAbility = Ability_Chlorophyll.new()

  # moves
  moves = {
    0: [Move_Tackle, Move_Growl],
    7: [Move_LeechSeed],
    9: [Move_VineWhip],
    #20: [Move_PoisonPowder],
    #27: [Move_SleepPowder],
    #34: [Move_RazorLeaf],
    #41: [Move_SweetScent],
    #48: [Move_Growth],
    #55: [Move_Synthesis],
    #62: [Move_SolarBeam]
  }

  if startingMoves.size() == 0:
    # we need to generate the moves based on the level
    # get all moves in moves dict that are less than or equal to the starting level
    for moveLevel in moves.keys():
      if moveLevel <= startingLevel:
        for move in moves[moveLevel]:
          # add the move to the pokemon's moveset
          addMove(move, "level")
  else:
    # we need to generate the moves based on the starting moves array
    for move in startingMoves:
      addMove(move, "debug")

  generate(startingLevel)
