local function find_entity_in_inventory(player, name)
  local main_inventory = player.get_inventory(defines.inventory.player_main)
  local quickbar       = player.get_inventory(defines.inventory.player_quickbar)
  local tools          = player.get_inventory(defines.inventory.player_tools)
  local entity         = main_inventory.find_item_stack(name)

  if entity == nil then
    entity = quickbar.find_item_stack(name)
  end
  if entity == nil then
    quickbar = player.get_quickbar()
    entity   = tools.find_item_stack(name)
  end
  if entity == nil then
    entity = quickbar.find_item_stack(name)
  end
  return entity
end

local function init_globals()
  if not global['craft-to-hand'] then
    global['craft-to-hand'] = {}
  end
end

local function set_crafting_item(item)
  init_globals()
  global['craft-to-hand'].craft = item
end

script.on_event('craft-to-hand', function(event)
  local player  = game.players[event.player_index]
  local planner = find_planner(player)

  if planner == nil then
    player.begin_crafting{count=1, recipe='craft-to-hand'}
  else
    player.cursor_stack.swap_stack(planner)
  end
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
  local player = game.players[event.player_index]

  local item   = event.item_stack
  if item.name then
    item = item.name
  end

  local entity = find_entity_in_inventory(player, item)

  if entity then
    -- player.print('found item ' .. item .. ' now selecting')
    player.cursor_stack.swap_stack(entity)
    set_crafting_item(nil)
  else
    player.print("setting global to " .. item)
    set_crafting_item(item)
  end
end)

local function get_crafting_item()
  if not global['craft-to-hand'] or global['craft-to-hand'].craft == nil then
      return nil
  end
  return global['craft-to-hand'].craft
end

local function find_last_crafted_entity(player)
    local item = get_crafting_item()
    if not item then
      -- player.print("No global found" .. serpent.block(global['craft-to-hand']))
      return
    end

    -- player.print('seeking last crafted' .. item)

    local  entity = find_entity_in_inventory(player, item)
    return entity
end

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
    local player = game.players[event.player_index]
    local entity = find_last_crafted_entity(player)

    if entity then
      set_crafting_item(nil)
      player.cursor_stack.swap_stack(entity)
    end
end)

script.on_event(defines.events.on_player_quickbar_inventory_changed, function(event)
    local player = game.players[event.player_index]
    local entity = find_last_crafted_entity(player)

    if entity then
      set_crafting_item(nil)
      player.cursor_stack.swap_stack(entity)
    end
end)

