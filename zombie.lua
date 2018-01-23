
function init_zombie()

    -- initialize zombie
    zombie = {}
    zombie.list = {}
    zombie.dead = {}
    zombie.zimage = love.graphics.newImage("img/zombie.png")
    zombie.deadzimage = love.graphics.newImage("img/dead_zombie.png")

    -- create zombie motion
    zombie.create_motion = {}
    zombie.create_motion[0] = love.graphics.newQuad(0, 0, 32, 32, 160, 32)
    zombie.create_motion[1] = love.graphics.newQuad(32, 0, 32, 32, 160, 32)
    zombie.create_motion[2] = love.graphics.newQuad(65, 0, 32, 32, 160, 32)
    zombie.create_motion[3] = love.graphics.newQuad(95, 0, 32, 32, 160, 32)
    zombie.create_motion[4] = love.graphics.newQuad(128, 0, 32, 32, 160, 32)
    zombie.create_motion[5] = love.graphics.newQuad(158, 0, 32, 32, 160, 32)

    -- create dead zombie motion
    zombie.create_dead_motion = {}
    zombie.create_dead_motion[0] = love.graphics.newQuad(0, 0, 32, 32, 192, 32)
    zombie.create_dead_motion[1] = love.graphics.newQuad(32, 0, 32, 32, 192, 32)
    zombie.create_dead_motion[2] = love.graphics.newQuad(62, 0, 32, 32, 192, 32)
    zombie.create_dead_motion[3] = love.graphics.newQuad(94, 0, 32, 32, 192, 32)
    zombie.create_dead_motion[4] = love.graphics.newQuad(127, 0, 32, 32, 192, 32)
    zombie.create_dead_motion[5] = love.graphics.newQuad(158, 0, 32, 32, 192, 32)

    -- zombie wave/spwan count
    zombie.wave_count = 0
    zombie.spawn_count = 0
    zombie.wave = 1

    -- zombie spwans every second
    -- new wave after 12 seconds
    zombie.spawn = 1 
    zombie.time = 12

    -- lower the number, the harder it gets
    zombie.difficulty = 0.91

    return zombie
end

function create_zombie(zombie_list, user)

    -- create a zombie
    local _zombie = {}

    -- zombie variables
    _zombie.health = {}
    _zombie.health.max = 1
    _zombie.num_steps = 1
    _zombie.distance = 0

    -- place it on a random position
    -- 타일즈 펑션 나중에 tiles.w 이런거 바꾸기
    _zombie.x = math.clamp(math.random(500) * math.rsign() + user.x, 2 * tiles.new_tile_width, tiles.width - 2 * tiles.new_tile_width)
    _zombie.y = math.clamp(math.random(500) * math.rsign() + user.y, 2 * tiles.new_tile_height, tiles.h - 2 * tiles.new_tile_height)

    -- not too close from the user
    if  check_collision(_zombie) or math.dist(_zombie.x, _zombie.y, user.x, user.y) < 130 then
        create_zombie(zombie_list, user)
        return
    end

    -- point towards user
    _zombie.angle = math.getAngle(user.x, user.y, _zombie.x, _zombie.y)

    -- after wave 10, zombies get faster and spwan more often
    if zombie.wave > 10 then
        zombie.difficulty = 0.805
        _zombie.speed = math.random(25) + 65
        _zombie.curr_speed = _zombie.speed
    else
        _zombie.speed = math.random(25) + 35
        _zombie.curr_speed = _zombie.speed
    end
    _zombie.health.curr = _zombie.health.max
    
    -- direction towards user
    _zombie.to_user_x = user.x - _zombie.x
    _zombie.to_user_y = user.y - _zombie.y
    _zombie.to_user_x, _zombie.to_user_y, _ = math.normalize(_zombie.to_user_x, _zombie.to_user_y)

    table.insert(zombie_list, _zombie)
end


function load_zombies(zombie, user, tiles, dt)
    
    -- count zombie wave
    zombie.wave_count = zombie.wave_count + dt

    if zombie.wave_count > zombie.time then
        zombie.spawn = zombie.spawn * zombie.difficulty 
        zombie.wave_count = 0
        zombie.wave = zombie.wave + 1
    end

    if zombie.spawn_count > zombie.spawn then
        create_zombie(zombie.list, user)
        zombie.spawn_count = 0
    else 
        zombie.spawn_count = zombie.spawn_count + dt
    end

    -- for all zombies in zombie list
    for a, b in ipairs(zombie.list) do
        -- direction to user
        b.to_user_x = user.x - b.x
        b.to_user_y = user.y - b.y
        b.to_user_x, b.to_user_y, _ = math.normalize(b.to_user_x, b.to_user_y)
        b.angle = math.getAngle(user.x, user.y, b.x, b.y)
	
        --여기 player_inmud 를 부쉬로 바꾸거나 하
        -- speed changes once zombie is in the bush
        if check_player_in_slow_dirt(b, tiles) then
            b.speed = b.curr_speed * 0.35
        elseif check_player_in_fast_grass(b, tiles) then
            b.speed = b.curr_speed * 1.3
        else
            b.speed = b.curr_speed
        end
        b.distance = (b.speed * dt) + b.distance
        
        -- corrdinates that matches the movement
        -- detects collision with the user
        dx =  (b.speed * b.to_user_x * dt)
        dy =  (b.speed * b.to_user_y * dt)
        
        local new_x = b.x
        local new_y = b.y

        b.x = b.x + dx
        if check_collision(b,tiles) then 
            b.x = new_x
        end

        b.y = b.y + dy
        if check_collision(b,tiles) then 
            b.y = new_y
        end

        -- change zombie sprite as it walks
        if b.distance > 30 then 
            b.distance = 0
            if b.num_steps < 4 then
                b.num_steps = b.num_steps + 1
            else
                b.num_steps = 0
            end
        end
	
    end
    
    -- changes sprite when the zombie dies
    for a, b in ipairs(zombie.dead) do
        -- calculate dead time
    	b.dead_time = b.dead_time + dt
    	-- pick the right dead sprite
    	if b.dead_time > 8 then
    	    table.remove(zombie.dead, a)
    	elseif b.dead_time < 0.1 then
    	    b.deads_prite = 0 
    	elseif b.dead_time < 0.3 then
    	    b.deads_prite = 1
    	elseif b.dead_time < 0.6 then
    	    b.deads_prite = 2
    	elseif b.dead_time < 0.9 then
    	    b.deads_prite = 3
    	elseif b.dead_time < 1.2 then
    	    b.deads_prite = 4
    	elseif b.dead_time < 1.5 then
    	    b.deads_prite = 5
    	end
    end
end


function user_kills_zombies(zombie, hit_list, user)
    -- for zombies in the zombie_list
    -- and for those that got shot
    -- check if the bullet hit them and if so
    -- zombie is dead
    for a, zom in ipairs(zombie.list) do
        for b, hit in ipairs(hit_list) do
            if CheckCollision(zom.x - 10, zom.y - 10, 20, 20, hit.x, hit.y, 1, 1) then
                table.remove(hit_list, b)
                zom.health.curr = zom.health.curr -1
                TEsound.play("sound/kill.mp3")

                if zom.health.curr == 0 then
             	    table.remove(zombie.list, a)
                    zom.dead_time = 0
                    zom.deads_prite = 0
        		    zombies_killed_by_player(user)
        		    table.insert(zombie.dead, zom)
                end
            end
        end
    end
end


function draw_dead_zombie(zombies)

    -- draw dead zombie
    for a, zom in ipairs(zombie.dead) do
        love.graphics.setColor(200, 200, 200)
        love.graphics.draw(zombie.deadzimage, zombie.create_dead_motion[zom.deads_prite], zom.x, zom.y, -zom.angle - math.pi/2, 1, 1, 16, 16)
    end
end


function draw_zombie(zombies)

    -- draw zombie
    for a, zom in ipairs(zombie.list) do
        love.graphics.setColor(200, 200, 200)
        love.graphics.draw(zombie.zimage, zombie.create_motion[zom.num_steps], zom.x, zom.y, -zom.angle - math.pi/2, 1, 1, 16, 16)
    end
end