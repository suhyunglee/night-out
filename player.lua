
function init_player()

    -- inialize player
    player = {}
    player.image = love.graphics.newImage("img/player.png")
    player.x = math.random(tiles.width)
    player.y = math.random(tiles.h)
    player.game_over = false
    player.angle = 0
    player.speed = 0
    player.curr_speed = 180
    player.distance = 0
    player.play_time = 0
    player.zombies_killed = 0
    player.num_steps = 1
    player.num_shot_action = 3

    -- check if player collides anything on the map when he is placed randomly
    while check_collision(player) do
	    player.x = math.clamp(math.random(tiles.width), tiles.new_tile_width, tiles.width - tiles.new_tile_width)
	    player.y = math.clamp(math.random(tiles.h), tiles.new_tile_height, tiles.width - tiles.new_tile_height)
    end

    -- create player motion
    player.create_motion = {}
    player.create_motion[0] = love.graphics.newQuad(0, 0, 32, 32, 128, 32)
    player.create_motion[1] = love.graphics.newQuad(32, 0, 32, 32, 128, 32)
    player.create_motion[2] = love.graphics.newQuad(64, 0, 32, 32, 128, 32)
    player.create_motion[3] = love.graphics.newQuad(96, 0, 32, 32, 128, 32)
    
    return player
    
end


-- calculates the players angle
function calculate_player_angle(player, mx, my)
    local get_angle = math.getAngle(mx, my, player.x, player.y)
    player.angle = -get_angle - math.pi/2
end


-- function to keep track of zombies killed
function zombies_killed_by_player(player)
    player.zombies_killed = player.zombies_killed + 1
end

-- sets the shooting sprite we are on now
function update_players_shots(player, weapon_shot)
    if weapon_shot.current.ammo_left > 0 then
        if weapon_shot.current.shoot_sprite_1 < weapon_shot.current.stop_shot then
            player.num_shot_action = 0
        elseif weapon_shot.current.shoot_sprite_2 > weapon_shot.current.stop_shot then
            player.num_shot_action = 1
        elseif weapon_shot.current.shoot_sprite_3 > weapon_shot.current.stop_shot then
            player.num_shot_action = 2
        elseif weapon_shot.current.shoot_sprite_4 > weapon_shot.current.stop_shot then
            player.num_shot_action = 3
        end
    end
end


-- update players movement and sprite
function update_player_sprite(player)
    if 21 < player.distance then 
        player.distance = 0
        if player.num_steps < 3 then
            player.num_steps = player.num_steps + 1
        else
            player.num_steps = 0
        end
    end
end


-- update players movement
function update_player_movement(tiles, dt)

    local del_x = 0
    local del_y = 0
    player.play_time = player.play_time + dt

    -- 여기 나중에 bush 나 뭐로 바꿔라
    if check_player_in_slow_dirt(player, tiles) then
        player.speed = player.curr_speed * 0.4
    elseif check_player_in_fast_grass(player, tiles) then
        player.speed = player.curr_speed * 1.5
    else
        player.speed = player.curr_speed
    end
 
    -- update players distance and calculate all players movement
    -- up, down, right, left, and diagonal movements
    player.distance = player.distance + player.speed* dt
    if love.keyboard.isDown("w") and love.keyboard.isDown("d") then
        del_x = player.speed * 0.65 * dt
        del_y = -player.speed * 0.65 * dt
    elseif love.keyboard.isDown("w") and love.keyboard.isDown("a") then
        del_x = -player.speed * 0.65 * dt
        del_y = -player.speed * 0.65 * dt
    elseif love.keyboard.isDown("s") and love.keyboard.isDown("d") then
        del_x = player.speed * 0.65 * dt
        del_y = player.speed * 0.65 * dt
    elseif love.keyboard.isDown("s") and love.keyboard.isDown("a") then
        del_x = -player.speed * 0.65 * dt
        del_y = player.speed * 0.65 * dt
    elseif love.keyboard.isDown("w") then
        del_y = -player.speed * dt
    elseif love.keyboard.isDown("s") then
        del_y = player.speed * dt
    elseif love.keyboard.isDown("d") then
        del_x = player.speed * dt
    elseif love.keyboard.isDown("a") then
        del_x = -player.speed * dt
    else
        player.distance = player.distance - player.speed * dt
    end
    
    -- update new x and y position
    local update_x = player.x
    local update_y = player.y
    player.x = player.x + del_x    
    if check_collision(player,tiles) then 
        player.x = update_x
    end
    player.y = player.y + del_y
    if check_collision(player,tiles) then 
        player.y = update_y
    end
end


-- if zombies get player, game over
function zombie_gets_player(player, zombie_list, dt)
    for a, zom in ipairs(zombie_list) do
        if CheckCollision(zom.x - 9.5, zom.y - 9.5, 20, 20, player.x - 9.5, player.y - 9.5, 20, 20) then
			player.game_over = true
		end
    end
end


-- check if game is over
function check_game_over(player, zombie_list)
    return player.game_over
end


-- draw player
function draw_player(player, menu)
    love.graphics.setColor(200, 200, 200)
    love.graphics.draw(player.image, player.create_motion[player.num_steps], player.x, player.y, player.angle, 1, 1, 32 / 2, 32 / 2)
    love.graphics.draw(weapon.current.image, player.create_motion[player.num_shot_action], player.x, player.y, player.angle, 1, 1, 32 / 2, 32 / 2)
end