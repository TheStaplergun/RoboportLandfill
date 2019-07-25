local Event = require('__stdlib__/stdlib/event/event')
local Interface = require('__stdlib__/stdlib/scripts/interface')
local Position = require('__stdlib__/stdlib/area/position')
local Player = require('__stdlib__/stdlib/event/player')

--500
--20x25
local tick_options = {
    skip_valid = true,
    protected_mode = false
}

local function get_lr(wt)
    local ulx = wt.ul_pos_x
    local uly = wt.ul_pos_y
    ulx = wt.current_x < wt.x_iterations and ulx + 15 or ulx + wt.x_remainder
    uly = wt.current_y < wt.y_iterations and uly + 15 or uly + wt.y_remainder
    return ulx,uly
end

local function get_tiles(wt)
    local current_x_lr, current_y_lr = get_lr(wt)
    local search_area = {{wt.ul_pos_x, wt.ul_pos_y},{current_x_lr,current_y_lr}}
    return wt.surface.find_tiles_filtered({
        area = search_area,
        collision_mask = "water-tile"
    })
end

local function place_ghosts(event)
    local entity = event.created_entity
    local player = Player.get(event.player_index)
    if not player.is_shortcut_toggled('roboport-landfill-toggle-on-off') then
        return
    end
    if entity.type == "roboport" then
        local radius = player.is_shortcut_toggled('roboport-landfill-toggle-radius') and entity.prototype.construction_radius or entity.prototype.logistic_radius
        local epos = entity.position
        local surface = entity.surface
        local x_iterations = radius > 7.5 and math.floor((2*radius)/15) or 1
        local y_iterations = x_iterations
        local x_remainder = (2*radius)%15
        local y_remainder = x_remainder
        local wt = {
            x_iterations = x_iterations,
            y_iterations = y_iterations,
            x_remainder = x_remainder,
            y_remainder = y_remainder,
            current_x = 0,
            current_y = 0,
            ul_pos_x = epos.x-radius,
            ul_start_pos_x = epos.x-radius,
            ul_pos_y = epos.y-radius,
            surface = surface,
            force = entity.force,
            entity = entity
        }
        if x_iterations > 1 then
            global.placing_ghosts = true
            remote.call('PickerAtheneum', 'event_queue_add', 'on_roboport_place', nil, tick_options)
            global.tile_queue = global.tile_queue or {}
            global.tile_queue[#global.tile_queue + 1] = wt
        end
    end
end
Event.register({defines.events.on_built_entity,defines.events.on_robot_built_entity},place_ghosts)

local function tile_ghost_placer()
    if not next(global.tile_queue) then
        global.placing_ghosts = false
        return
    end
    local wt = global.tile_queue[1]
    local surface = wt.surface
    if wt.entity.valid then
        if wt.current_x > wt.x_iterations then
            wt.ul_pos_x = wt.ul_start_pos_x
            wt.ul_pos_y = wt.ul_pos_y + 15
            wt.current_x = 0
            wt.current_y = wt.current_y + 1
            if wt.current_y > wt.y_iterations then
                table.remove(global.tile_queue, 1)
                if not next(global.tile_queue) then
                    global.placing_ghosts = false
                end
                return
            end
        end
        local tile_set = get_tiles(wt)
        for i,tiles in pairs(tile_set) do
            if tiles.name ~= "out-of-map" and not surface.find_entity("tile-ghost", Position.add(tiles.position, {0.5,0.5})) then
                surface.create_entity({name = "tile-ghost", inner_name = "landfill", position = tiles.position, expires = false, force = wt.force})
            end
        end
        wt.current_x = wt.current_x + 1
        wt.ul_pos_x = wt.ul_pos_x + 15
    else
        table.remove(global.tile_queue, 1)
    end
end

local function tile_tick_handler()
    if global.placing_ghosts then
        tile_ghost_placer()
    else
        remote.call('PickerAtheneum', 'event_queue_remove', 'on_roboport_place', nil, tick_options)
    end
end

local function on_lua_shortcut(event)
    if event.prototype_name == 'roboport-landfill-toggle-radius' then
        local player = Player.get(event.player_index)
        if player.is_shortcut_available('roboport-landfill-toggle-radius') then
            player.set_shortcut_toggled('roboport-landfill-toggle-radius', not player.is_shortcut_toggled('roboport-landfill-toggle-radius'))
        end
    end
    if event.prototype_name == 'roboport-landfill-toggle-on-off' then
        local player = Player.get(event.player_index)
        if player.is_shortcut_available('roboport-landfill-toggle-on-off') then
            player.set_shortcut_toggled('roboport-landfill-toggle-on-off', not player.is_shortcut_toggled('roboport-landfill-toggle-on-off'))
        end
    end
end
Event.register(defines.events.on_lua_shortcut, on_lua_shortcut)

local function on_init_and_load()
    local build_tiles = Event.set_event_name('on_roboport_place', remote.call('PickerAtheneum', 'generate_event_name', 'on_roboport_place'))
    Event.register(build_tiles, tile_tick_handler, nil, nil, tick_options)
end
Event.on_event({Event.core_events.on_init, Event.core_events.on_load}, on_init_and_load)
