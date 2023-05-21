extends "../Pokemon.gd"

func _ready():
  dexNum = 001
  pName = "Bulbasaur"
  pType1 = "Grass"
  pType2 = ""

  baseHp = 45
  baseAtk = 49
  baseDef = 49
  baseSpAtk = 65
  baseSpDef = 65
  baseSpd = 45

  baseHappiness = 50
  captureRate = 45
  genderThreshold = 223  # 87.5% ish

  growthRate = "Medium Slow"

  expYield = 64

  yieldEVSpAtk = 1

  frontSprite = preload("res://sprites/pokemon/001-bulbasaur/front.png")
  backSprite = preload("res://sprites/pokemon/001-bulbasaur/back.png")
  frontShinySprite = preload("res://sprites/pokemon/001-bulbasaur/front_shiny.png")
  backShinySprite = preload("res://sprites/pokemon/001-bulbasaur/back_shiny.png")

  # todo: icon sprites
  #iconZero = preload("res://sprites/pokemon/001-bulbasaur/icon_0.png")
  #iconOne = preload("res://sprites/pokemon/001-bulbasaur/icon_1.png")

  