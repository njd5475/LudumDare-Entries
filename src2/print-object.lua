local col = 80

function ObjectToString(o)
    local str = ''
    if type(o) == 'table' and #o > 0 then
        str = str .. '['
        for k,v in pairs(o) do
            local _next = ' ' .. ObjectToString(v) .. ','
            str = str .. _next
            if #_next >= col then
                str = str .. '\n'
            end
        end
        str = str .. ']\n'
    elseif type(o) == 'table' and #o ~= nil then
        str = str .. '{'
        for k,v in pairs(o) do
            str = str .. ' ' .. k .. '=' .. ObjectToString(v)
            if #str >= col then
                str = str .. '\n'
            end
        end
        str = str .. '}\n'
    else
        str = tostring(o)
    end
    return str
end

function printo(str, o)
    print(str .. ': ' .. ObjectToString(o))
end