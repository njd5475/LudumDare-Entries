
local State = require('engine.class')()

function State:_init(name)
  assert(name, "States need unique names!")
  self.name = name
  self.objects = {}
  self.types = {}
  self.keyUpActions = {}
  self.keyDownActions = {}
end

function State:init(game)
end

function State:cleanup(game)
end

function State:draw(game)
  SetColor('Background')
  for _, go in pairs(self.objects) do
    go:draw(game)
  end
end

function State:update(game, dt)
  local toRemove = {}
  for _, go in pairs(self.objects) do
    if not go:dead() then
      go:update(game, dt)
    else
      table.insert(toRemove, go)
    end
  end

  if #toRemove > 0 then
    for _, rm in pairs(toRemove) do
        self:remove(rm)
    end
  end

  self:handleInputActions(game, dt)
end

function State:withinRange(x, y, rangeSq, objType)
  assert(type(rangeSq) == 'number', 'Range must be a number')
  local results = {}
  local objs = self.objects
  if objType then
    objs = self.types[objType]
  end

  if objs then
    for _, o in pairs(objs) do
      local cx, cy = o:boundsCenter()
      local dsq = distSq(cx, cy, x, y)
      if (rangeSq+o:boundsRadiiSq()) >= dsq then
        table.insert(results, o)
      end
    end
  else
    print('No objects found of type ' .. objType)
    for t in pairs(self.types) do
      print('Have ' .. t)
    end
  end

  return results
end

function State:getObjectsOfType(...)
  local results = {}
  local args = {...}
  for _, t in pairs(args) do 
    local objList = self.types[t] or {}
    for _, o in pairs(objList) do
      table.insert(results, o)
    end
  end

  return results
end

function State:getName()
  return self.name
end

function State:incrementSize()
  self.size = (self.size or 0) + 1
end

function State:decrementSize()
  self.size = math.max(0, (self.size or 1) - 1) -- never go negative
end

function State:getNumberOfObjects()
  return self.size
end


function State:add(o)
  if o.dead and o.id and not o:dead() then
    self:incrementSize()
    self.objects[o:id()] = o
    if not self.types[o:type()] then
      self.types[o:type()] = {}
    end
    self.types[o:type()][o:id()] = o
  else
    print("Err: Game only accepts non-dead game objects")
  end
end

function State:remove(go)
  self.objects[go:id()] = nil
  self.types[go:type()][go:id()] = nil
end

function State:removeAll()
  self.objects = {}
  self.types = {}
end

function State:getAction(event)
  return self.actions[event]
end

function State:handleInputActions(game, dt)
  local actions = {}
  for action, key in pairs(self.keyDownActions) do
    if action.isDown(key) then
      table.insert(actions, {action=action, obj=key})
    end
  end

  for action, keyState in pairs(self.keyUpActions) do
    if keyState.wasDown and not action.isDown(keyState.key) then
      keyState.wasDown = false
      table.insert(actions, {action=action, obj=keyState.key})
    elseif keyState.wasDown or action.isDown(keyState.key) then
      keyState.wasDown = true
    end
  end

  if #actions > 0 then
    for _, action in pairs(actions) do
      action.action:invoke(action.obj, game, dt)
    end
  end
end

function State:addKeyPressEvent(key, action)
  assert(key, "We need a non nil key to track events")
  assert(action, "We need a non nil action to trigger events")
  local me = self
  local actionHandler = {}
  actionHandler.invoke = function(o, obj, game, dt)
    me[action](me, obj, game, dt)
  end
  actionHandler.isDown = function(key)
    return love.keyboard.isDown(key)
  end
  self.keyDownActions[actionHandler] = key
end


function State:addKeyReleaseEvent(key, action)
  assert(key, "We need a non nil key to track events")
  assert(action, "We need a non nil action to trigger events")
  local me = self
  local actionHandler = {}
  actionHandler.invoke = function(o, obj, game, dt)
    me[action](me, obj, game, dt)
  end
  actionHandler.isDown = function(key)
    return love.keyboard.isDown(key)
  end
  self.keyUpActions[actionHandler] = {wasDown=false,key=key}
end

return State
