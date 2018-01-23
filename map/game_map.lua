game_map = {}
game_map.image = "map/map_tiles.png"
game_map.set_tile_width = 256
game_map.set_tile_height = 256
game_map.tile_width = 64
game_map.tile_height = 64
game_map.quadInfo =
{
    { '_', 0,    0 }, -- regular grass
    { 'm', 64,   0 }, -- slow dirt
    { 'r', 128,  0 }, -- rock
    { 'g', 192, 0 }, -- fast grass

    { 'w', 0,   64 }, -- | right wall
    { 'H', 64,  64 }, -- _ down wall
    { 'W', 128, 64 }, -- | left wall
    { 'h', 192, 64 }, -- _ up wall
    { 'x', 0,  128 }, -- corner 1
    { 'y', 64, 128 }, -- corner 2
    { 'z', 128,128 }, -- corner 3
    { 'p', 192,128 }, -- corner 4
}
game_map.collision = {'r','h','w','H','W'}

game_map.size = 50
game_map.slow_dirt = math.random(6,14) / 100
game_map.rock = math.random(4,14) / 100
game_map.fast_grass = math.random(6, 14) / 100


-- create randomized map
game_map.tiles_list = {}
game_map.tiles_list = "y"..string.rep("h", 48).."z\n"

for x = 2, 49 do
    game_map.tiles_list = game_map.tiles_list.."w"
    for y = 2, 49 do
        r = math.random()
        ran = math.random(1, 2)
        if r < game_map.fast_grass and ran == 1 then
            game_map.tiles_list = game_map.tiles_list.."g"
        elseif r < game_map.slow_dirt and ran == 2 then
            game_map.tiles_list = game_map.tiles_list.."m"
        elseif r > (1 - game_map.rock) then 
            game_map.tiles_list = game_map.tiles_list.."r"
        else
            game_map.tiles_list = game_map.tiles_list.."_"
        end
    end
    game_map.tiles_list = game_map.tiles_list.."W\n"
end
game_map.tiles_list = game_map.tiles_list.."p"..string.rep("H", 48).."x\n"

