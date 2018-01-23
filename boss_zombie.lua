
function init_boss_zombie()

	-- initialize zombie
	boss_zombie = {}
	boss_zombie.list = {}
	boss_zombie.dead = {}
	boss_zombie.zimage = love.graphics.newImage("img/boss_zombie.png")
	boss_zombie.deadzimage = love.graphics.newImage("img/boss_dead.png")

	-- create boss zombie motion
	boss_zombie.create_motion = {}
	boss_zombie.create_motion[0] = love.graphics.newQuad(0, 0, 64, 64, 320, 64)
    boss_zombie.create_motion[1] = love.graphics.newQuad(51, 0, 64, 64, 320, 64)
    boss_zombie.create_motion[2] = love.graphics.newQuad(117, 0, 64, 64, 320, 64)
    boss_zombie.create_motion[3] = love.graphics.newQuad(182, 0, 64, 64, 320, 64)
    boss_zombie.create_motion[4] = love.graphics.newQuad(245, 0, 64, 64, 320, 64)
    boss_zombie.create_motion[5] = love.graphics.newQuad(313, 0, 64, 64, 320, 64)

    -- create dead boss zombie motion
    boss_zombie.create_dead_motion = {}
    boss_zombie.create_dead_motion[0] = love.graphics.newQuad(0, 0, 64, 64, 384, 64)
    boss_zombie.create_dead_motion[1] = love.graphics.newQuad(54, 0, 64, 64, 384, 64)
    boss_zombie.create_dead_motion[2] = love.graphics.newQuad(119, 0, 64, 64, 384, 64)
    boss_zombie.create_dead_motion[3] = love.graphics.newQuad(186, 0, 64, 64, 384, 64)
    boss_zombie.create_dead_motion[4] = love.graphics.newQuad(253, 0, 64, 64, 384, 64)
    boss_zombie.create_dead_motion[5] = love.graphics.newQuad(318, 0, 64, 64, 384, 64)

    -- zombie wave count
    boss_zombie.wave_count = 1

    return boss_zombie

end

function create_boss_zombie(zombie_list, user)

	-- create boss zombie
	local _boss_zombie = {}

	-- boss zombie variables
	_boss_zombie.health = {}
	_boss_zombie.health.max = 10
    _boss_zombie.num_steps = 1
    _boss_zombie.distance = 0
    _boss_zombie.speed = 70

	-- place it on a random position
    _boss_zombie.x = math.clamp(user.x + math.random(500) * math.rsign(), 2 * tiles.new_tile_width, tiles.width - 2 * tiles.new_tile_width)
    _boss_zombie.y = math.clamp(user.y + math.random(500) * math.rsign(), 2 * tiles.new_tile_height, tiles.h - 2 * tiles.new_tile_height)

    -- not too close from the user
    if  check_collision(_boss_zombie) or math.dist(_boss_zombie.x, _boss_zombie.y, user.x, user.y) < 160 then
        create_boss_zombie(zombie_list, user)
        return
    end

    -- point towards user
    _boss_zombie.angle = math.getAngle(user.x, user.y, _boss_zombie.x, _boss_zombie.y)

    -- set boss zombie speed
    _boss_zombie.curr_speed = _boss_zombie.speed
    _boss_zombie.health.curr = _boss_zombie.health.max

    -- direction towards user
    _boss_zombie.to_user_x = user.x - _boss_zombie.x
    _boss_zombie.to_user_y = user.y - _boss_zombie.y
    _boss_zombie.to_user_x, _boss_zombie.to_user_y, _ = math.normalize(_boss_zombie.to_user_x, _boss_zombie.to_user_y)

    table.insert(zombie_list, _boss_zombie)
end


function load_boss_zombies(boss_zombie, user, tiles, dt)

	-- count boss zombie wave
    boss_zombie.wave_count = boss_zombie.wave_count + dt

    -- every 5 wave, one boss zombie spawns
    -- but if wave is 10+, then every 5 wave, 2 boss zombie spawns
    -- and if wave is 20+ (idk if user will reach this point), 4 boss zombie spawns
    if math.mod(zombie.wave,5) == 0 and boss_zombie.wave_count > zombie.time * 5 - (zombie.time - 1) then
    	if zombie.wave >= 10 and zombie.wave < 20 then
    		create_boss_zombie(boss_zombie.list, user)
    		boss_zombie.wave_count = 0
    	end
    	if zombie.wave >= 20 then
			create_boss_zombie(boss_zombie.list, user)
			create_boss_zombie(boss_zombie.list, user)
			create_boss_zombie(boss_zombie.list, user)
			boss_zombie.wave_count = 0
    	else
    		create_boss_zombie(boss_zombie.list, user)
    		boss_zombie.wave_count = 0
    	end
    end


    -- for all boss zombies in boss_zombie list
    for a, zom in ipairs(boss_zombie.list) do
	    -- direction to user
		zom.to_user_x = user.x - zom.x
		zom.to_user_y = user.y - zom.y
		zom.to_user_x, zom.to_user_y, _ = math.normalize(zom.to_user_x, zom.to_user_y)
		zom.angle = math.getAngle(user.x, user.y, zom.x, zom.y)

		--여기 player_inmud 를 부쉬로 바꾸거나 하
        -- speed changes once boss zombie is in the bush
		if check_player_in_slow_dirt(zom, tiles) then
			zom.speed = zom.curr_speed * 0.35
		elseif check_player_in_fast_grass(zom, tiles) then
			zom.speed = zom.curr_speed * 1.5
		else
			zom.speed = zom.curr_speed
		end

		zom.distance = zom.distance + (zom.speed * dt)

        -- corrdinates that matches the movement
        -- detects collision with the user
		dx =  (zom.speed * zom.to_user_x * dt)
		dy =  (zom.speed * zom.to_user_y * dt)

		local new_x = zom.x
		local new_y = zom.y

		zom.x = zom.x + dx    
		if check_collision(zom,tiles) then 
			zom.x = new_x
		end

		zom.y = zom.y + dy
		if check_collision(zom,tiles) then 
			zom.y = new_y
		end 

		-- changing boss zombie sprite as it walks
		if zom.distance > 30 then 
			zom.distance = 0
			if zom.num_steps < 4 then
				zom.num_steps = zom.num_steps + 1
			else
	            zom.num_steps = 0
	        end
	    end
	end
    
    -- changes sprite when the boss zombie dies
    for a, b in ipairs(boss_zombie.dead) do
        -- calculate dead time
		b.dead_time = b.dead_time + dt
		-- pick the right dead sprite
		if b.dead_time > 8 then
		    table.remove(boss_zombie.dead, a)
		elseif b.dead_time < 0.1 then
		    b.dead_sprite = 0 
		elseif b.dead_time < 0.3 then
		    b.dead_sprite = 1
		elseif b.dead_time < 0.6 then
		    b.dead_sprite = 2
		elseif b.dead_time < 0.9 then
		    b.dead_sprite = 3
		elseif b.dead_time < 1.2 then
		    b.dead_sprite = 4
		elseif b.dead_time < 1.5 then
		    b.dead_sprite = 5
		end
    end
end


function user_kills_boss_zombies(boss_zombie, hit_list, user)
    -- for boss zombies in the zombie_list
    -- and for those that got shot
    -- check if the bullet hit them and if so
    -- boss zombie is dead
	for a, zom in ipairs(boss_zombie.list) do
		for b, hit in ipairs(hit_list) do
			if CheckCollision(zom.x - 10, zom.y - 10, 20, 20, hit.x, hit.y, 1, 1) then
		        table.remove(hit_list, b)
		        zom.health.curr = zom.health.curr -1
		        TEsound.play("sound/kill.mp3")
		        if zom.health.curr == 0 then
	         	    table.remove(boss_zombie.list, a)
	         	    zom.dead_time = 0
	         	    zom.dead_sprite = 0
	         	    zombies_killed_by_player(user)
	         	    table.insert(boss_zombie.dead, zom)
				end
			end
		end
	end
end


function draw_dead_boss_zombie(zombies)
	-- draw dead boss zombie
	for a, zom in ipairs(boss_zombie.dead) do
		love.graphics.setColor(200, 200, 200)
		love.graphics.draw(boss_zombie.deadzimage, boss_zombie.create_dead_motion[zom.dead_sprite], zom.x, zom.y, - zom.angle - math.pi/2, 1, 1, 32, 32)
	end
end

function draw_boss_zombie(zombies)
	for a, zom in ipairs(boss_zombie.list) do
		if zom.health.max > 1 then 
			-- draw boss zombie health bars
			love.graphics.setColor(200, 0, 0)
			love.graphics.rectangle("fill", zom.x - 5 * zom.health.max / 2, zom.y - 15, 5 * zom.health.max, 3)
			love.graphics.setColor(0, 200, 0)
			love.graphics.rectangle("fill", zom.x - 5 * zom.health.max / 2, zom.y - 15, 5 * zom.health.curr, 3)
		end
		-- draw boss zombie
		love.graphics.setColor(200, 200, 200)
		love.graphics.draw(boss_zombie.zimage, boss_zombie.create_motion[zom.num_steps], zom.x, zom.y, -zom.angle - math.pi/2, 1, 1, 32, 32)
	end
end



