
function init_tiles()
    -- load tiles to map
    tiles = {}
    love.filesystem.load("map/maplist.lua")()
    tiles.map_num = 1
    tiles.maplist = maplist
    tiles.map_amount = #maplist
    return load_map(tiles, maplist[tiles.map_num])
end


-- load map
function load_map(tiles, obj)
    love.filesystem.load(obj)()
    tiles.tileset = love.graphics.newImage(game_map.image)
    local row_num = 1
    local column_num = 1
    tiles.information = {}
    tiles.coor = {}
    tiles.table_list = {}

    -- set collision detection
    tiles.collision = game_map.collision

    for a, chk in ipairs(game_map.quadInfo) do
       tiles.coor[chk[1]] = love.graphics.newQuad(chk[2], chk[3], game_map.tile_width, game_map.tile_height, game_map.set_tile_width, game_map.set_tile_height)
       tiles.information[a] = chk[1]
    end
    
    local w = #(game_map.tiles_list:match("[^\n]+")) 

    -- create tiles/grid 
    for x = 1, w, 1 do 
        tiles.table_list[x] = {}
    end

    for r in game_map.tiles_list:gmatch("[^\n]+") do
        column_num = 1
        for update in r:gmatch(".") do
            tiles.table_list[column_num][row_num] = update
            column_num = column_num + 1
        end
        row_num = row_num + 1
    end
    
    -- draw tiles and update
    tiles.width = game_map.tile_width * (column_num - 1)
    tiles.h = game_map.tile_height * (row_num - 1)
    tiles.new_tile_width = game_map.tile_width
    tiles.new_tile_height = game_map.tile_height
    return tiles
end


-- checks where the player is placed
function check_player_location(player)
    return tiles.table_list[math.ceil(player.x / tiles.new_tile_width)][math.ceil(player.y / tiles.new_tile_height)]
end


-- checks if player is in slow dirt
function check_player_in_slow_dirt(player)
    return check_player_location(player,tiles) == 'm'
end


-- checks if player is in fast grass
function check_player_in_fast_grass(player)
    return check_player_location(player,tiles) == 'g'
end


function check_collision(player)
    return in_table(tiles.collision, check_player_location(player,tiles))
end


-- draw tiles
function draw_tiles(tiles)
    love.graphics.setColor(200, 200, 200)
    for column_num, c in ipairs(tiles.table_list) do
        for row_num, a in ipairs(c) do
            local dx = tiles.new_tile_width * (column_num - 1)
            local dy = tiles.new_tile_height * (row_num - 1)
            love.graphics.draw(tiles.tileset, tiles.coor[a], dx, dy)
        end
    end
end




