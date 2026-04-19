
require('print-object')
require('vec')
require('movement')
local mapIsle = require('themap')

local textures = {}
local grid,w,h = {}, 100, 20
local TILEWIDTH,TILEHEIGHT=24,24

function love.load()
    local map = mapIsle
    for i=1,#map.tilesets do
        local t = map.tilesets[i]
        t.texture = love.graphics.newImage(t.image)
        t.texture:setFilter('nearest', 'nearest')
        local startId = t.firstgid
        local columns = math.floor(t.imagewidth / t.tilewidth)
        print("Image " .. t.imagewidth .. "," .. t.imageheight .. ' Tiles ' .. t.tilewidth .. "," .. t.tileheight .. " Columns " .. columns)

        for j=1,t.tilecount do
            local n = j - 1
            local gid = n + startId
            local lx = (n - math.floor(n / columns)*columns) * TILEWIDTH 
            local ly = (math.floor(n / columns)) * TILEHEIGHT
            print("Index " .. j .. "  L " .. lx .. "," .. ly)

            textures[gid] = {
                index=n,
                texture=t.texture,
                quad=love.graphics.newQuad(lx, ly, t.tilewidth, t.tileheight, t.imagewidth, t.imageheight)
            }
        end
    end

    for l=1,#map.layers do
        local y = 1
        local layer = map.layers[l]
        w = math.max(w, layer.width or 0)
        local cur = 1
        if layer.data then
            local lw = layer.width
            while layer.data[cur] do
                if cur%lw == 0 then
                    y = y + 1
                end
                grid[(cur - (y-1)*lw) .. ',' .. y] = grid[(cur - (y-1)*lw) .. ',' .. y] or {}
                table.insert(grid[(cur - (y-1)*lw) .. ',' .. y], layer.data[cur])
                cur = cur + 1
            end
        end
        if layer.objects then
            for j=1,#layer.objects do
                local o = layer.objects[j]
                if o.properties then
                    if o.properties.mapping then
                        --assert(false, 'found mapping object at ' .. o.x .. ',' .. o.y .. ' ' .. o.width .. 'x' .. o.height)
                    end
                end
            end
        end
        h = math.max(h, y)
    end
end

local camx,camy=0,0

function love.draw()
    local _g = love.graphics
    _g.push()
    _g.clear(0,0,0,1)
    _g.translate(-camx, -camy)
    for i=1,w do
        for j=1,h do
            local layers = grid[i .. ',' .. j]
            if layers then
                for l=1,#layers do
                    local cell = layers[l]
                    local tile = cell or '-'
                    if tile ~= '-' and textures[tile] then
                        tile = textures[tile]
                        _g.setColor(1,1,1,1)
                        _g.draw(tile.texture, tile.quad, i*TILEWIDTH, j*TILEHEIGHT, 0, 1, 1)
                    end
                end
            end
        end
    end

    _g.pop()
end

function love.update(dt)

    local dx,dy=GetMovementInput()

    camx,camy = camx +10*dx, camy+10*dy
end

function love.keypressed(code)
    if code == 'escape' then
        love.event.quit()
    end
end