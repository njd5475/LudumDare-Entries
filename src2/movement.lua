
dirx={-1,1,0,0}
diry={0,0,-1,1}
dir={left=1,right=2,up=3,down=4}

function GetMovementInput()
    local dx,dy=0,0
    for k,v in pairs(dir) do
        if love.keyboard.isDown(k) then
            dx = dx + dirx[v]
            dy = dy + diry[v]
        end
    end

    if dx ~= 0 or dy ~= 0 then
        dx,dy=vec(dx,dy):norm():pos()
    end

    return dx,dy
end