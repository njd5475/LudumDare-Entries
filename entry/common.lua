require('engine.common')

joyInputs = {"x","y",'a','b','back','start','leftstick','rightstick','leftshoulder','rightshoulder','dpup','dpdown','dpleft','dpright'}
LogoFont = love.graphics.newFont("fonts/press-start-2p/PressStart2P-Regular.ttf", 56)
LogoMidFont = love.graphics.newFont("fonts/press-start-2p/PressStart2P-Regular.ttf", 18)
LogoRegularFont = love.graphics.newFont("fonts/press-start-2p/PressStart2P-Regular.ttf", 10)

Player = require('objects.player')
TheSheet = require('thesheet')

-- Color pallette from https://lospec.com/palette-list/dustbyte
BaseColors = {
  black={r=55, g=42, b=57},
  redbrown={r=170, g=100, b=77},
  yellow={r=245, g=233, b=191},
  green={r=120, g=131, b=116}
}
Colors={
  white={r=255, g=255, b=255},
  background=BaseColors.black,
  depthCount=BaseColors.redbrown,
}

function SetColor(colorName)
  local c = Colors[colorName]
  love.graphics.setColor(c.r/255, c.g/255, c.b/255, 1.0)
end

function SetClearColor(colorName)
  local c = Colors[colorName]
  love.graphics.clear(c.r/255, c.g/255, c.b/255, 1.0)
end