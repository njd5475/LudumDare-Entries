pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

local dbgmsg='debugmsg'
local dbgt = 30

local state
local gravfn=nil

function _init()
	state=main()
	state:addfx(temp)
	state:addfx(obstruct)
	state:push(ctrl())
end

function _draw()
	state:draw()
	
	if dbgt > 0 and dbgmsg and #dbgmsg > 0 then
		print(dbgmsg, 4, 4, 12)
	end
	
	print(stat(7), 64, 4, 12)
end

function _update60()
	state = state:update()
	
	
	
	if dbgt > 0 and dbgmsg and #dbgmsg > 0 then
		dbgt -= 1
		if dbgt <= 0 then
			dbgmsg = nil
		end
	end

 if dbgt <= 0 and dbgmsg and #dbgmsg > 0 then
 	dbgt = 60
 end
	
end
-->8
-- cell. objects
local palx,paly=0,9
local tmpmx=1000.0
local wnd={x=0,y=0,w=128,h=128}

function cell(_x,_y,_c)
 local dx, dy = 0, 0

	return {
	 x=_x,
	 y=_y,
	 dx=0,
	 dy=0,
	 clr=_c,
	 wgt=1, -- weight
	 tmp=rnd(tmpmx), -- temperature
	 tmpmx=tmpmx, -- temp max
	 ris=100, -- resistance
		draw=function(_,g)
			_.clr = _.clr or _:tocolor()
		 pset(_.x,_.y,_.clr)
		end,
		update=function(_,g)
   g:adjust(_)
   if _.x < wnd.x or _.x > wnd.x+wnd.w or
   		_.y < wnd.y or _.y > wnd.y+wnd.h then
   	del(g.objs, _)
 		end
		end,
		incex=function(_,inc)
			_.tmp+=inc
		end,
		tocolor=function(_)
			return sget(palx+flr((_.tmp/_.tmpmx) * 8), paly)
		end
	}
end

function well(x,y)
 local isplaced,t,gfn=false,300,grav(x,y,300)
 
	return {
		draw=function()
		end,
		update=function(_,g)
		 if not isplaced then
		 	g:addfx(gfn)
		 	isplaced = true
		 end
		 
		 t -= 1
		 if t < 0 then
		  dbgmsg='gfn removed'
		 	g:rmfx(gfn)
		 end
		end
	}
end
-->8
-- main

adjx={-1,1,0,0,-1,1,1,-1}
adjy={0,0,-1,1,-1,-1,1,1}

function main()
 local spwn=5
 local t = spwn 
	return {
	 objs={},
	 fxs={},
	 adjcback={},
	 adjc={},
	 draw=function(_)
	  cls()
	  for o in all(_.objs) do
	  	o:draw(_)
	  end
	  
	  print('#objs'.. #_.objs, 13)
	 end,
		update=function(_)
		 _.adjc = _.adjcback -- swap bufs
		 _.adjcback = {}
		 for o in all(_.objs) do
		 	o:update(_)
		 end
		 
		 t -= 1
		 if t <= 0 then
		 	_:push(cell(rnd(64)+32,rnd(64)+32))
		 	t = spwn
		 end

			return _
		end,
		addfx=function(_, fx)
			add(_.fxs, fx)
		end,
		rmfx=function(_, fx)
			del(_.fxs, fx)
		end,
		push=function(_, o)
		 add(_.objs, o)
		end,
		excite=function(_, amt)
			for o in all(_.objs) do
				o:incex(amt or 0.01)
			end
		end,
		adjust=function(_, c)
		 local rev = false
		 local lx,ly = c.x, c.y
			for fx in all(_.fxs) do
			  local r = fx(c, _)
			  rev = rev or r == 'revert'
			end
			if rev then
				c.x = lx
				c.y = ly
			end
			
			-- index
			_.adjcback[ceil(c.x) ..','.. ceil(c.y)]=c
		end,
		get=function(_, x, y)
		 return _.adjc[ceil(x) .. ',' .. ceil(y)]
		end,
		getadj=function(_, x, y)
		 local adj = {}
			for i = 1,#adjx do
			 adj[i] = _:get(x+adjx[i], y+adjy[i])
			end
			return adj
		end,
		place=function(_,sp,x,y,w,h)
		 local spy=flr(sp/16)
		 local ox,oy=8*(sp-8*spy),spy*8
		 dbgmsg='off ' .. ox .. ',' .. oy
			for j=1,w*8 do
			 for k=1,h*8 do
			 	local c = sget(ox+j-1,oy+k-1)
			 	if c > 0 then
			 	 local n = cell(x+j,y+k, c)
			 	 n.tmp = 0
			 		_:push(n)
			 	end
			 end
			end
		end
	}
end
-->8
-- fxs

function temp(c)
	if c.tmp > c.ris then
		c.dx+=(rnd(1)-0.5)*(c.tmp/c.tmpmx)/16
		c.dy+=(rnd(1)-0.5)*(c.tmp/c.tmpmx)/16
		c.tmp -= 1 -- cool
	end
	c.x += c.dx
	c.y += c.dy
end

local gravg = 9.8
function grav(gx,gy,wgt)
 wgt = wgt or 150

	return function(c)
		local d2 = distsq(c.x, c.y, gx, gy)
		
		if d2 > 25 then
			local dirx, diry = vecdir(gx, gy, c.x, c.y)
			
			dirx,diry=vecnorm(dirx,diry)
			
			local magg = gravg * ((wgt * c.wgt) / d2)
			if magg > 0.05 then
				c.x += dirx * magg
				c.y += diry * magg
		 end
		end
	end
end

function obstruct(c, g)
	local obs = g:get(c.x, c.y)
	if obs and obs ~= c then
		local adj = g:getadj(c.x, c.y)
		-- 1=left,2=right,3=top,4=bot,
		-- 5=left-top,6=right-top,7=bottom-right,8=bottom-left
		for i=1,#adj do
			if adj[i] == nil then
			 -- find the first and move to it
				c.x+= adjx[i]
				c.y+= adjy[i]
			end
		end
		return 'revert'
	end
end
-->8
-- collision functions

function distsqcell(c1, c2)
	return distsq(c1.x, c1.y, c2.x, c2.y)
end

function distsq(x1,y1,x2,y2)
	return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
end

function vecdir(x1,y1,x2,y2)
	return x1-x2,y1-y2
end

function vecmag(x1,y1)
	return sqrt(x1^2 + y1^2)
end

function vecnorm(x1, y1)
 local mag = vecmag(x1,y1)
 return x1/mag, y1/mag
end
-->8
-- ctrl

function ctrl()

	return {
	 sel=nil,
	 x=64,
	 y=64,
		draw=function(_, g)
			_.sel = _.sel or (platform(_))
			_.first = _.first or _.sel
		
			spr(3, _.x, _.y)
			
			local sx,sy=32,119
			local cur = _.first
			while cur and cur ~= fwd do
			 cur:draw(sx,sy)
			 sx += 9
				cur = cur.after
   end
		end,
		update=function(_, g)
		 local dx,dy=0,0
			for i=1,4 do
				if btn(i-1) then
					dx=adjx[i]
					dy=adjy[i]
				end
			end
			_.x += dx
			_.y += dy
			
			if btnp(4) then
				_:exec(g)
			end
			
		 if btnp(5) then
				_:selnext()
			end

		end,
		exec=function(_, g)
			_.sel:exec(g)
		end,
		selnext=function(_)
			_.sel = _.sel.after
			if not _.sel then
		 	_.sel=_.first
		 end
		end
	}
end
-->8
-- options

function gravitywell(c,t)
 t = t or 500
	return {
		draw=function(_,x,y)
			spr(52,x,y)
			if c.sel == _ then
				rect(x,y,x+8,y+8,7)
			end
		end,
	 exec=function(_,g)
		 g:push(well(c.x, c.y))
	 end,
	 after=nil
	}
end

function platform(c)
	return {
		draw=function(_,x,y)
			spr(51, x, y)
			if c.sel == _ then
				rect(x,y,x+8,y+8,7)
			end
		end,
		exec=function(_,g)
			g:place(1,c.x,c.y,2,2)
		end,
		after=gravitywell(c)
	}
end
__gfx__
00000000067777777777776000030000076765500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006dddddddddddddd600030000767665550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007006d666666666666d600000000676665550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770006d667666666676d633000330666655550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770006d666766666666d600000000666655550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007006d666667666666d600030000666655510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006d666666666766d600030000666655520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006d667666666666d600000000066655100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1245d6f76dddddddddddddd600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1248e9a7567777777777777500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555d555d5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055d555555d555d5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000d555555d555d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000011dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000d011dd100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006777760d010d1010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000066666600d11d0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000056776500d001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000555555000dd10d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000555500001100d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001100dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
