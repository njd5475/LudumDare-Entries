

function vec(x,y)
    assert(x ~= nil, 'vec must have a x')
    assert(type(x) == 'number', 'x must be a number instead it was '.. type(x))
    assert(y ~= nil, 'vec must have a y')
    assert(type(y) == 'number', 'y must be a number instead it was '.. type(y))
	return {
		add=function(_, v)
		 local x2, y2 = v:pos()
			return vec(x+x2, y+y2)
		end,
		sub=function(_, v)
			local x2, y2 = v:pos()
			return vec(x-x2, y-y2)
		end,
		mul=function(_, v)
			local x2, y2 = v:pos()
			return vec(x*x2, y*y2)
		end,
		div=function(_, x2, y2)
			if type(x2) == 'table' then
				x2, y2 = x2:pos()
			else
				y2 = y2 or x2
			end
			return vec(x/x2, y/y2)
		end,
		mag=function(_)
			local sqr = math.abs(math.sqrt(x*x+y*y))
			return sqr
		end,
		dot=function(v1, v2)
			local x1,y1=v1:pos()
			local x2,y2=v2:pos()
			return x1 * x2 + y1 * y2
		end,
		cross=function(v1,v2)
			local x1,y1=v1:pos()
			local x2,y2=v2:pos()
			return	x1*y2-y1*x2
		end,
		ang=function(_)
				return atan2(x,y)
		end,
		norm=function(_)
		 local mag = _:mag()
		 return vec(x/mag, y/mag)
		end,
		pos=function(_)
			return x,y
		end,
		neg=function(_)
			return vec(-x,-y)
		end,
        distSq=function(_,v,z)
            local x2,y2=v, z
            if type(v) == 'table' and v.pos then
                x2,y2=v:pos()
            end
            return (x-x2)*(x-x2) + (y-y2)*(y-y2)
        end
	}
end