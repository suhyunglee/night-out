require('player')
require('weapon')
require('zombie')
require('boss_zombie')
require('tiles')
require('game_menu')
require('math_snippet')
require('camera')
require('TEsound')

-- loads all the game functions 
function love.load()

	love.graphics.setDefaultFilter('linear', 'linear')
	-- generates a random number
	math.randomseed(os.time())
	math.random(); math.random(); math.random();

	-- for weapon
	count_t = 0
	check_weapon_time = true

	-- initialize menu
	load_menu = init_menu()
	tiles = init_tiles()
	user = init_player()
	weapon = init_weapon()
	zombie = init_zombie()
	boss_zombie = init_boss_zombie()

	if TEsound.disable then
		TEsound.disable_sound()
		load_menu.sound = false
	end

	-- set camaera
	camera:setBounds(0, 0, tiles.width - 512, tiles.h - 512)
	check_game_paused = false

end


-- if 'esc' is pressed, game paused and menu updates
function love.keypressed(key)

	if key == "escape" then
		check_game_paused = not check_game_paused
	end
	check_menus(load_menu, key)

end


-- quits game
function love.quit()

end



-- for bgm sound
function love.focus(f)

	if f == false then
		check_game_paused = true
		TEsound.disable_sound()
	elseif load_menu.sound then
		TEsound.enable_sound()
		TEsound.playLooping("sound/bgm.mp3", "bgm")
	end

end


-- check if mouse is pressed
function love.mousepressed(x, y, button)
	if check_game_paused then 
		return 
	end
	check_menus(load_menu, _, button)

end


-- update function
function love.update(dt)
	TEsound.cleanup()
	camera:setPosition(user.x - 512 / 2, user.y - 512 / 2)
	m_dx, m_dy = camera:mousePosition()

	-- if game is paused, then updates
	if check_game_paused then 
		return 
	end


	-- updates once game is started
	if load_menu.game_start then
		update_game_start_menu(load_menu)


	-- check if the game is over, if it is then pause for few seconds 
	-- for user to check the score and restart the game
	elseif check_game_over(user, zombie.list) or check_game_over(user, boss_zombie.list) then
		update_game_over_menu(load_menu)
		count_t = count_t + dt
		if count_t > 4 then
			check_weapon_time = false
			love.load()
		end
	else
		update_player_movement(tiles, dt)
		check_weapon(user, weapon, m_dx, m_dy, dt)
		update_bullets_fired(weapon, dt)

		load_zombies(zombie, user, tiles, dt)
		load_boss_zombies(boss_zombie, user, tiles, dt)

		user_kills_zombies(zombie, weapon.bullets, user)
		user_kills_boss_zombies(boss_zombie, weapon.bullets, user)

		zombie_gets_player(user, zombie.list, dt)
		zombie_gets_player(user, boss_zombie.list, dt)

		calculate_player_angle(user, m_dx, m_dy)
		update_player_sprite(user)
		update_players_shots(user, weapon)
	end

end


-- draw function
function love.draw()

	camera:set()
	draw_tiles(tiles)
	draw_dead_zombie(zombie)
	draw_dead_boss_zombie(boss_zombie)
	draw_player(user, load_menu)
	draw_zombie(zombie)
	draw_boss_zombie(boss_zombie)

	-- wave UI up left
	love.graphics.setColor(250, 0, 0)
	love.graphics.print("Wave ", camera:getX() +10, camera:getY() + 5)
	love.graphics.print(zombie.wave, camera:getX() +100, camera:getY() + 5)

	draw_bullets_fired(weapon, user)

	-- loads the correct menu depending on the game state
	if load_menu.game_start then
		draw_game_start_menu(load_menu, user)
	elseif load_menu.game_over then
		draw_game_over_menu(load_menu, user)
	end

	-- white circle for the mouse so user can aim at zombies
	love.graphics.setColor(200, 200, 200)
	love.mouse.setVisible(false)
	love.graphics.circle("line", m_dx, m_dy, 10)
	love.graphics.setColor(250, 0, 0)

	-- UI when the game is paused
	if check_game_paused then
		love.graphics.setColor(10, 10, 10, 200)
		love.graphics.circle("fill", user.x, user.y, 1000)
		love.graphics.setColor(200, 200, 200)
		love.graphics.print("PAUSED", camera:getX() + 220, camera:getY() + 150, 0, 1, 1)
		love.graphics.print("Press escape to continue", camera:getX() + 120, camera:getY() + 350, 0, 1, 1)
	end

	-- end
	camera:unset()
end































