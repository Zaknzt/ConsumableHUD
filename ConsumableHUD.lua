_addon.name = 'ConsumableHUD'
_addon.author = 'Zaknzt / FFXI Development II'
_addon.version = '0.1.2'
_addon.language = 'English'

local texts = require('texts')

local REFRESH_INTERVAL = 1.0
local BAG_IDS = {0, 5, 6, 7} -- Inventory, Satchel, Sack, Case

local ALLOWED_ZONES = {
    -- San d'Oria
    [230] = true, -- Southern San d'Oria
    [231] = true, -- Northern San d'Oria
    [232] = true, -- Port San d'Oria
    [233] = true, -- Chateau d'Oraguille

    -- Bastok
    [234] = true, -- Bastok Mines
    [235] = true, -- Bastok Markets
    [236] = true, -- Port Bastok
    [237] = true, -- Metalworks

    -- Windurst
    [238] = true, -- Windurst Waters
    [239] = true, -- Windurst Walls
    [240] = true, -- Port Windurst
    [241] = true, -- Windurst Woods
    [242] = true, -- Heavens Tower

    -- Jeuno
    [243] = true, -- Ru'Lude Gardens
    [244] = true, -- Upper Jeuno
    [245] = true, -- Lower Jeuno
    [246] = true, -- Port Jeuno

    -- Other approved hubs
    [247] = true, -- Rabao
    [256] = true, -- Western Adoulin
    [257] = true, -- Eastern Adoulin
}

local SECTIONS = {
    {
        title = 'Consumables',
        items = {
            {name = 'Panacea', id = 4149},
            {name = 'Remedy', id = 4155},
            {name = 'Antidote', id = 4148},
            {name = 'Echo Drops', id = 4151},
            {name = 'Holy Water', id = 4154},
            {name = 'Eye Drops', id = 4150},
            -- Current Windower Resources has no player-item entry named Vaccine.
            {name = 'Vaccine', id = nil},
            {name = 'Grape Daifuku', id = 6343},
        },
    },
    {
        title = 'Sneak / Invis',
        items = {
            {name = 'Silent Oil', id = 4165},
            {name = 'Prism Powder', id = 4164},
        },
    },
    {
        title = 'Utsusemi',
        items = {
            {name = 'Shihei', id = 1179},
            {name = 'Toolbag (Shihe)', id = 5314},
        },
    },
    {
        title = 'Reraise',
        items = {
            {name = 'Reraiser', id = 4172},
            {name = 'Hi-Reraiser', id = 4173},
            {name = 'Super Reraiser', id = 5770},
        },
    },
}

local tracked_ids = {}
for _, section in ipairs(SECTIONS) do
    for _, entry in ipairs(section.items) do
        if entry.id then
            tracked_ids[entry.id] = true
        end
    end
end

local hud_settings = {
    pos = {x = 20, y = 220},
    text = {
        font = 'Consolas',
        size = 10,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
    },
    bg = {
        visible = true,
        alpha = 160,
        red = 0,
        green = 0,
        blue = 0,
    },
    flags = {
        draggable = true,
    },
    padding = 6,
}

local hud = texts.new('', hud_settings)
local last_refresh = 0
local hud_visible = false

local function scan_counts()
    local counts = {}

    for item_id in pairs(tracked_ids) do
        counts[item_id] = 0
    end

    for _, bag_id in ipairs(BAG_IDS) do
        local bag = windower.ffxi.get_items(bag_id) or {}
        for _, item in pairs(bag) do
            if type(item) == 'table' and tracked_ids[item.id] then
                counts[item.id] = counts[item.id] + (tonumber(item.count) or 0)
            end
        end
    end

    return counts
end

local function render(counts)
    local lines = {}

    for section_index, section in ipairs(SECTIONS) do
        if section_index > 1 then
            lines[#lines + 1] = ''
        end

        lines[#lines + 1] = section.title
        for _, entry in ipairs(section.items) do
            local count = entry.id and (counts[entry.id] or 0) or 0
            lines[#lines + 1] = string.format('%-16s %4d', entry.name, count)
        end
    end

    return table.concat(lines, '\n')
end

local function refresh()
    hud:text(render(scan_counts()))
end

local function set_hud_visible(visible)
    if visible == hud_visible then
        return
    end

    hud_visible = visible
    if visible then
        hud:show()
    else
        hud:hide()
    end
end

local function apply_zone_visibility(zone_id)
    local visible = zone_id ~= nil and ALLOWED_ZONES[zone_id] == true
    set_hud_visible(visible)
    return visible
end

local info = windower.ffxi.get_info()
if apply_zone_visibility(info and info.zone or nil) then
    refresh()
end
last_refresh = os.clock()

windower.register_event('zone change', function(new_zone)
    apply_zone_visibility(new_zone)
    last_refresh = os.clock() - REFRESH_INTERVAL
end)

windower.register_event('prerender', function()
    local now = os.clock()
    if now - last_refresh < REFRESH_INTERVAL then
        return
    end

    last_refresh = now

    local current_info = windower.ffxi.get_info()
    if not apply_zone_visibility(current_info and current_info.zone or nil) then
        return
    end

    refresh()
end)

windower.register_event('unload', function()
    if hud then
        hud:destroy()
        hud = nil
    end
end)
