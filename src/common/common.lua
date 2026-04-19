require('engine.common')

GRID_SIZE = 32

joyInputs = {"x","y",'a','b','back','start','leftstick','rightstick','leftshoulder','rightshoulder','dpup','dpdown','dpleft','dpright'}
LogoFont = love.graphics.newFont("fonts/press-start-2p/PressStart2P-Regular.ttf", 56)
LogoMidFont = love.graphics.newFont("fonts/press-start-2p/PressStart2P-Regular.ttf", 18)
LogoRegularFont = love.graphics.newFont("fonts/press-start-2p/PressStart2P-Regular.ttf", 10)

-- Color pallette from https://lospec.com/palette-list/dustbyte
BaseColors = {
  black={r=55, g=42, b=57},
  redbrown={r=170, g=100, b=77},
  yellow={r=245, g=233, b=191},
  green={r=120, g=131, b=116}
}
Colors={
  Background={r=0, g=0, b=0, a=255},
  white={r=255, g=255, b=255},
  background=BaseColors.black,
  depthCount=BaseColors.redbrown,
  debugLine=BaseColors.yellow,
  debugOrigins=BaseColors.yellow,
  eventForeground=BaseColors.yellow,
  eventBackground=BaseColors.redbrown,
  playerHealthForeground=BaseColors.yellow,
  playerHealthBackground=BaseColors.green,
  buttonBackground=BaseColors.green,
  buttonForeground=BaseColors.redbrown,
}


local setColorFn = love.graphics.setColor

local major, minor, revision, codename = love.getVersion()

local str = string.format("Version %d.%d.%d - %s", major, minor, revision, codename)
print(str)
if minor >= 11 or major >= 11 then
  setColorFn = function(r, g, b, a)
    a = a or 255
    love.graphics.setColor(r/255, g/255, b/255, a/255)
  end
end

function getColor(colorName)
  assert(Colors[colorName], 'Missing color [' .. colorName .. ']')
  return Colors[colorName]
end

function setColor(r, g, b, a)
  assert(r, 'Set color should have at least one parameter')
  local c = r
  if type(c) == 'number' then
    c = {r=r, g=g, b=b, a=a}
  end
  if type(c) == 'string' then
   c = getColor(c)
   assert(c, 'No actual color found for ' .. r)
  end
  setColorFn(c.r, c.g, c.b, c.a)
end

function SetColor(colorName)
  local c = Colors[colorName]
  assert(c, 'Color name does not exist ' .. colorName)
  setColor(c.r, c.g, c.b, 255)
end

function SetClearColor(colorName)
  local c = Colors[colorName]
  --love.graphics.clear(c.r/255, c.g/255, c.b/255, 1.0)
  love.graphics.clear(c.r, c.g, c.b, 255)
end

Damageable = require('effects.damageable')
Attackable = require('effects.attackable')
Pulse = require('effects.pulse')

require('names')