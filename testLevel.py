import math  

def getXpFromLevel(level) -> int: # type: ignore
  match levellingRate:
    case "slow":
      return math.floor((5 * level * level * level) / 4.0)
    case "medium-slow":
      return math.floor(((6 * level * level * level) / 5.0) - (15 * level * level) + (100 * level) - 140)
    case "medium-fast":
      return math.floor(level * level * level)
    case "fast":
      return math.floor((4 * level * level * level) / 5.0)
    case "erratic":
      if level <= 50:
        return math.floor(((100 - level) * level * level) / 50.0)
      elif level <= 68:
        return math.floor(((150 - level) * level * level) / 100.0)
      elif level <= 98:
        return math.floor(math.floor((1911 - (10 * level)) / 3.0) * (level * level * level) / 500.0)
      else:
        return math.floor((160 - level) * (level * level * level) / 100.0)
    case "fluctuating":
      if level <= 15:
        return math.floor((level * level * level) * ((((level + 1) / 3.0) + 24) / 50.0))
      elif level <= 36:
        return math.floor((level * level * level) * ((level + 14) / 50.0))
      else:
        return math.floor((level * level * level) * (((level / 2.0) + 32) / 50.0))
    case _:
      print("oops")
      return 0

levellingRate = input("Enter levelling rate: ")

# input for either level to xp or xp to level
if input("Enter 1 for level to xp, 2 for xp to level: ") == "1":
  level = int(input("Enter level: "))
  print(getXpFromLevel(level))
else:
  xp = int(input("Enter xp: "))
  # loop until we find the level
  level = 1
  while getXpFromLevel(level) < xp and level <= 100:
    level += 1
  print(level - 1)
  print("To next: " + str(getXpFromLevel(level) - xp))


