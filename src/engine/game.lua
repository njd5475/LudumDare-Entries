
local Game = require("engine.class")()

require('engine.utils')

local Events = require('engine.lib.events')

function Game:_init(startState)
  assert(startState, "Cannot start a game with a nil state!")
  self.states = {}
  self.bindings = {}
  self.events = Events()
  local me = self
  love.draw = function() me:draw() end
  love.update = function(dt) me:update(dt) end
  self.bounds = {
    x = 0,
    y = 0,
    w = love.graphics:getWidth(),
    h = love.graphics:getHeight()
  }
  love.keyreleased = function(key)
    if key == 'escape' then
      love.event.quit()
    elseif key == 'printscreen' then
      if love.graphics.newScreenshot then
        local screenshot = love.graphics.newScreenshot()
        screenshot:encode('png', self:getScreenshotName())
      elseif love.graphics.captureScreenshot then
        love.graphics.captureScreenshot(self:getScreenshotName())
      end
    end
    if self._listenForKey then
      self.keyPressed = true
    end
  end
  self:addState(startState)
  self:changeState(startState:getName())
end

function Game:getScreenshotName()
  return os.time() .. '.png'
end

function Game:bindKeyPressed(key, action)
  self:bind(key, 'pressed', action)
end

function Game:bindKeyReleased(key, action)
  self:bind(key, 'released', action)
end

function Game:listenForKey()
  self._listenForKey = true
  self.keyPressed = false
end

function Game:wasKeyPressed()
  return self.keyPressed
end

function Game:stopListeningForKey()
  self._listenForKey = false
  self.keyPressed = false
end

function Game:bind(key, method, action)
  local binding = self.bindings[key]
  if not binding then
    binding = {}
    self.bindings[key] = binding
  end
  binding[method] = function(key, game)
    game:triggerAction(action)
  end
end

function Game:getObjectsOfType(...)
  return self:current():getObjectsOfType(...)
end

function Game:triggerAction(action)
  if self:current()[action] then
    self:current()[action](self:current(), self)
  end
end

function Game:addState(state)
  self.states[state:getName()] = state
end

function Game:current()
  return self.currentState
end

function Game:changeState(newState)
  assert(newState, "Cannot switch to a nil state!")
  assert(self.states[newState], "The game has no state named " .. newState)
  if self.currentState then
    self.currentState:cleanup(self, self.states[newState])
  end
  self.oldState = self.currentState
  self.currentState = self.states[newState]
  self.currentState:init(self, self.oldState)
end

function Game:add(go)
  self:current():add(go)
end

function Game:withinRange(x, y, rangeSq, type)
  return self:current():withinRange(x, y, rangeSq, type)
end

function Game:draw()
  self.currentState:draw(self)
end

function Game:update(dt)
  self.currentState:update(self, dt)
end

function Game:outside(go)
  return not collides(self.bounds, go:bounds())
end

function Game:on(event, fn)
  local game = self
  self.events:on(event, function(...)
    fn(game, ...)
  end)
end

function Game:off(event)
  self.events:off(event)
end

function Game:emit(event, ...)
  self.events:emit(event, ...)
end

return Game
