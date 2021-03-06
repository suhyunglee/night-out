-- this file is imported

function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end



function in_table(t,s)
  for i,v in pairs(t) do
    if (v==s) then 
      return true
    end
  end
end



-- Averages angles
function math.averageAngles(...)
    local x,y = 0,0
    for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
    return math.atan2(y, x)
end


-- returns distance between two points
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end


-- returns angle between two points
function math.getAngle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end


-- returns multiple
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end


-- clamps a number
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end


-- normalize 2 numbers
function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end


-- rounded to the nearest decj
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end


-- Special not-decimal round
function math.sround(n, deci) return math.floor(n*deci+.5)/deci end


-- Randomly returns either -1 or 1.
function math.rsign() return math.random(2) == 2 and 1 or -1 end


-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
    local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
    return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end


-- Collision detection function.
-- Checks if box1 and box2 overlap.
-- w and h mean width and height.
function CheckCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
    if box1x > box2x + box2w - 1 or -- Is box1 on the right side of box2?
       box1y > box2y + box2h - 1 or -- Is box1 under box2?
       box2x > box1x + box1w - 1 or -- Is box2 on the right side of box1?
       box2y > box1y + box1h - 1    -- Is b2 under b1?
    then
        return false                -- No collision. Yay!
    else
        return true                 -- Yes collision. Ouch!
    end
end