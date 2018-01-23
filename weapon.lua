function init_weapon()
    -- default values 
    weapon = {}
    weapon.count = 0
    weapon.check = false
    weapon.check_time = 0
    weapon.pistol = {}
    weapon.pistol.image = love.graphics.newImage("img/pistol.png")
    weapon.pistol.reloading_sound = "sound/reload_gun.mp3"
    weapon.pistol.fire_rate = 0.3
    weapon.pistol.reloading_time = 0.75
    weapon.pistol.ammo = 8
    weapon.pistol.ammo_left = weapon.pistol.ammo
    weapon.pistol.stop_shot = 1
    weapon.pistol.stop_reload = 1
    weapon.pistol.shoot_sprite_1 = 0.05
    weapon.pistol.shoot_sprite_2 = 0.10
    weapon.pistol.shoot_sprite_3 = 0.15
    weapon.pistol.shoot_sprite_4 = 0.20

    weapon.current = weapon.pistol
    
    weapon.bullets = {}
    weapon.bullet_speed = 15
    weapon.bullet_img = love.graphics.newImage("img/bullet.png")
    weapon.bullet_motion = love.graphics.newQuad(0,0, 4, 8, 16, 16)
    weapon.hits_rock = {}
    weapon.rock_motion = love.graphics.newQuad(6,0, 7, 8, 16, 16)
    return weapon
end


function fire_weapon(user, mouse_x, mouse_y, weapon)

    -- check if weapon has an ammo
    if 0 < weapon.current.ammo_left then
        -- create a bullet
        local bull = {}
        bull.x = user.x
        bull.y = user.y
        bull.curr_bullet_x = mouse_x - user.x
        bull.curr_bullet_y = mouse_y - user.y
        bull.curr_bullet_x, bull.curr_bullet_y, _ = math.normalize(bull.curr_bullet_x, bull.curr_bullet_y)

        -- get the angle of the bullet
        local angle = math.getAngle(mouse_x, mouse_y, bull.x, bull.y)
        bull.angle = -angle
        bull.x = bull.x + 8 * math.cos(bull.angle)
        bull.y = bull.y + 7 * math.sin(bull.angle)
        table.insert(weapon.bullets, bull)
        weapon.current.ammo_left = weapon.current.ammo_left - 1
        TEsound.play("sound/shot.mp3")

    else
        -- no ammo
        weapon.check = true    
        TEsound.play("sound/empty.mp3")
    end
end


function check_weapon(user, shot, mouse_x, mouse_y, dt)

    if user.play_time < 0.2 then 
        return 
    end

    -- when user fires
    if love.mouse.isDown(1) then
        -- you can't shoot unless it's some time past from last
        if weapon.current.reloading_time < weapon.current.stop_reload and weapon.current.fire_rate < weapon.current.stop_shot then
            -- shoot
              fire_weapon(user, mouse_x, mouse_y, weapon, weapon.bullets)
              weapon.current.stop_shot = 0
        end 
    end
    
    if weapon.count == 100 then
        reload_weapon(weapon)
        weapon.check = false
        weapon.count = 0
        weapon.current.stop_reload = 0
    end
end


function update_bullets_fired(weapon, dt)
    -- update shots in every direction
    for a, b in ipairs(weapon.bullets) do
        b.x = weapon.bullet_speed * b.curr_bullet_x + b.x
        b.y = weapon.bullet_speed * b.curr_bullet_y + b.y
        if 0 > b.x or 0 > b.y or tiles.width < b.x or tiles.h < b.y then
            table.remove(weapon.bullets, a)
        end
    end
    
    -- bullets that hit obstacles
    for a, b in ipairs(weapon.hits_rock) do
        b.time = b.time + dt
        if b.time > 0.1 then
            table.remove(weapon.hits_rock, a)
        end
    end

    bullet_hits_objects(weapon.bullets)
    weapon.current.stop_reload = weapon.current.stop_reload + dt
    weapon.current.stop_shot = weapon.current.stop_shot + dt
    
    if weapon.check then
        weapon.check_time = weapon.check_time + dt
        -- blinks every half a second
        if weapon.check_time > 0.5 then
            weapon.check_time = 0
        end
    end
end


function reload_weapon(weapon)
    -- reload weapon
    weapon.current.ammo_left = weapon.current.ammo
    TEsound.play(weapon.current.reloading_sound)
end


function bullet_hits_objects(shot_list)
    -- for every bullet check if it hits an object
    for a, b in ipairs(shot_list) do
        if check_collision(b, tiles) then
            b.time = 0
            table.insert(weapon.hits_rock, b) 
            if math.dist(user.x,user.y, b.x,b.y) < 400 then
                TEsound.play("sound/rock.mp3")
            end
            table.remove(shot_list, a)
        end
    end
end


function draw_bullets_fired(weapon, user)
    -- draw bullets fired
    for a, b in ipairs(weapon.bullets) do
        love.graphics.setColor(200, 200, 200)
        love.graphics.draw(weapon.bullet_img, weapon.bullet_motion, b.x, b.y, b.angle, 0.6, 0.8)
    end

    for a, b in ipairs(weapon.hits_rock) do
        love.graphics.setColor(200, 200, 200)
        love.graphics.draw(weapon.bullet_img, weapon.rock_motion, b.x, b.y, b.angle, 0.6, 0.8)
    end
      
    -- draw ammo UI
    if weapon.check == false then
        for i = 1, weapon.current.ammo_left do
            love.graphics.setColor(200, 200, 200)
            love.graphics.draw(weapon.bullet_img, weapon.bullet_motion, 500 + camera:getX() - 11 * i, camera:getY() + 10, 0, 2, 2)
        end
    elseif 0.3 > weapon.check_time then
        love.graphics.setColor(250, 0, 0)
        love.graphics.print("RELOAD", 390 + camera:getX() + 10, camera:getY() + 5)
    elseif weapon.check == true then
        weapon.count = weapon.count + 1
    end
end

