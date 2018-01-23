function init_menu()

    -- initialize menu
    menu = {}
    menu.game_start = true
    menu.game_over = false
    menu.gameover_color = 250
    menu.gameover_size = 0
    menu.sound = true
    menu.item = 1
    menu.death_sound = true
    TEsound.playLooping("sound/bgm.mp3", "bgm")
    menu.font = love.graphics.newFont("img/game_font.ttf", 35)
    love.graphics.setFont(menu.font)

    return menu
end


-- check menu states
function check_menus(menu, key, x)
    if menu.game_start then
        update_game_start_menu(menu, key, x)
    end
end


function update_game_start_menu(menu, key)
    -- keeps track of the mouse
    mouse_x, mouse_y = camera:mousePosition()
    if mouse_y > camera:getY() + 350 then
        menu.item = 4
    elseif mouse_y > camera:getY() + 300 then
        menu.item = 1
    end

    -- user either clicks on the menu item or press return
    if menu.item == 1 and (love.mouse.isDown(1) or key=="return") then
        menu.game_start = false
        menu.game_over = false
    elseif menu.item == 4 and (love.mouse.isDown(1)  or key=="return") then
        love.event.push('quit')
    end
end


-- function that updates the game over menu
function update_game_over_menu(menu, player)
    -- menu slowly turns black
    menu.game_over = true
    menu.gameover_color = math.max(menu.gameover_color - 1, 0)
    menu.gameover_size = menu.gameover_size + 3
    
    -- play players death sound
    if menu.death_sound then
        TEsound.stop("all")
        TEsound.play("sound/death.mp3")
        menu.death_sound = false
    end
    
    -- end game over menu
    if menu.gameover_color == 0 then 
        menu.game_over = false
    end  
end


function draw_game_start_menu(menu, player)
    -- game start menu background color is black
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", player.x, player.y, 800)

    love.graphics.setColor(200, 200, 200)
    love.graphics.print("Night Out", camera:getX() + 140, camera:getY() + 140, 0, 2, 2)

    -- changes color depending on the menu.item
    if menu.item == 1 then
        love.graphics.setColor(200, 20, 20)
    end
    love.graphics.print("Start game", camera:getX() + 200, camera:getY() + 300 )
    love.graphics.setColor(200, 200, 200)

    if menu.item == 4 then
        love.graphics.setColor(200, 20, 20)
    end
    love.graphics.print("Exit", camera:getX() + 200, camera:getY() + 350)
    love.graphics.setColor(200, 200, 200)   
end


function draw_game_over_menu(menu, player)
    
    -- game over menu and keeps getting red
    love.graphics.setColor(menu.gameover_color, menu.gameover_color/4, menu.gameover_color/4)
    love.graphics.circle("fill", player.x, player.y, menu.gameover_size, 50)
    
    -- display user score
    love.graphics.setColor(200, 200, 200)
    love.graphics.print("GAME OVER", camera:getX() + 100, camera:getY() + 100)
    love.graphics.print("You Survived "..string.format("%d",zombie.wave).." Wave(s)", camera:getX() + 100, camera:getY() + 150)
    love.graphics.print("You Survived "..string.format("%.2f",player.play_time).." Seconds", camera:getX() + 100, camera:getY() + 180)
    love.graphics.print("You Killed "..string.format("%d",player.zombies_killed).." Zombie(s)", camera:getX() + 100, camera:getY() + 210)
end






