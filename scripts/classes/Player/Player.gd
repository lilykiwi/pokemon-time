class_name Player extends Object

enum pModel {
  NONE, # fallback, should be set before rendering in wPlayer or bPlayer
  HERB,
  # todo: add 2 more
}

var team: Array[Pokemon] = []
var ot = "Player"
var id = 0
var money = 0
var badges = 0b00000000
var visitedLocales = 0b00000000000000
# TODO: pokedex
#var pokedex = []
# TODO: boxes
#var boxes = [[],[]]

# hardcoded for now
var model = pModel.HERB

func _init(
  _model: pModel = pModel.NONE,
  _team: Array[Pokemon] = [],
  _ot: String = "Player",
  _id: int = 0,
  _money: int = 0,
  _badges: int = 0b00000000,
  _visitedLocales: int = 0b00000000000000
):
  self.model = _model
  self.team = _team
  self.ot = _ot
  self.id = _id
  self.money = _money
  self.badges = _badges
  self.visitedLocales = _visitedLocales