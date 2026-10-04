_addon.name = 'ConsumableHUD'
_addon.author = 'Zaknzt / FFXI Development II'
_addon.version = '0.2.2'
_addon.language = 'English'
_addon.command = 'consumablehud'

local config = require('config')
local texts = require('texts')

local REFRESH_INTERVAL = 1.0
local BAG_IDS = {0, 5, 6, 7} -- Inventory, Satchel, Sack, Case
local CHAT_COLOR = 207
local CURIO_ITEM_COUNT = 199
local REMA_AMMO_COUNT = 8

local HUD_MODE_ORDER = {'always', 'town', 'off'}
local HUD_MODE_VALUES = {
    always = true,
    town = true,
    off = true,
}
local HUD_MODE_LABELS = {
    always = 'Always',
    town = 'Town',
    off = 'Off',
}

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

-- Curio catalog: medicines, ammunition containers, ninjutsu toolbags,
-- food, and instant scrolls. Equipment, keys, materials, and key items
-- are intentionally outside ConsumableHUD scope.
local SECTIONS = {
    {
        key="medicines", title="Medicines", curio=true,
        items={
            {name="Potion", id=4112, default=false},
            {name="Hi-Potion", id=4116, default=false},
            {name="X-Potion", id=4120, default=false},
            {name="Max-Potion", id=4124, default=false},
            {name="Ether", id=4128, default=false},
            {name="Hi-Ether", id=4132, default=false},
            {name="Super Ether", id=4136, default=false},
            {name="Pro-Ether", id=4140, default=false},
            {name="Hi-Elixir", id=4144, default=false},
            {name="Elixir", id=4145, default=false},
            {name="Antidote", id=4148, default=true},
            {name="Panacea", id=4149, default=true},
            {name="Eye Drops", id=4150, default=true},
            {name="Echo Drops", id=4151, default=true},
            {name="Antacid", id=4153, default=false},
            {name="Holy Water", id=4154, default=true},
            {name="Remedy", id=4155, default=true},
            {name="Mulsum", id=4156, default=false},
            {name="Prism Powder", id=4164, default=true},
            {name="Silent Oil", id=4165, default=true},
            {name="Deodorizer", id=4166, default=false},
            {name="Reraiser", id=4172, default=true},
            {name="Hi-Reraiser", id=4173, default=true},
            {name="Vile Elixir", id=4174, default=false},
            {name="Vile Elixir +1", id=4175, default=false},
            {name="Icarus Wing", id=4213, default=false},
        },
    },
    {
        key="ammo_arrows", title="Ammo - Arrows", curio=true,
        items={
            {name="Stone Quiver", id=4219, default=false},
            {name="Bone Quiver", id=4220, default=false},
            {name="Iron Quiver", id=4225, default=false},
            {name="Beetle Quiver", id=4221, default=false},
            {name="Silver Quiver", id=4226, default=false},
            {name="Horn Quiver", id=4222, default=false},
            {name="Sleep Quiver", id=5333, default=false},
            {name="Scorpion Quiver", id=4223, default=false},
            {name="Demon Quiver", id=4224, default=false},
            {name="Kabura Quiver", id=5332, default=false},
            {name="Antlion Quiver", id=5819, default=false},
            {name="Ruszor Quiver", id=5871, default=false},
            {name="Gargouille Quiver", id=5912, default=false, resource_name="Gargou. Quiver"},
            {name="Chapuli Quiver", id=6137, default=false},
            {name="Mantid Quiver", id=6138, default=false},
            {name="Tulfaire Quiver", id=6201, default=false},
            {name="Raaz Quiver", id=6202, default=false},
            {name="Adlivun Quiver", id=6200, default=false},
            {name="Ra'Kaznar Quiver", id=6280, default=false},
            {name="Eminent Quiver", id=6269, default=false},
        },
    },
    {
        key="ammo_bolts", title="Ammo - Bolts", curio=true,
        items={
            {name="Bronze Bolt Quiver", id=4227, default=false, resource_name="B. Bolt Quiver"},
            {name="Blind Bolt Quiver", id=5334, default=false, resource_name="Bln. Bolt Quiver"},
            {name="Acid Bolt Quiver", id=5335, default=false, resource_name="Ac. Bolt Quiver"},
            {name="Sleep Bolt Quiver", id=5337, default=false, resource_name="Slp. Bolt Quiver"},
            {name="Bloody Bolt Quiver", id=5339, default=false, resource_name="Bld. Bolt Quiver"},
            {name="Venom Bolt Quiver", id=5338, default=false, resource_name="Vn. Bolt Quiver"},
            {name="Holy Bolt Quiver", id=5336, default=false, resource_name="Hol. Bolt Quiver"},
            {name="Mythril Bolt Quiver", id=4228, default=false, resource_name="M. Bolt Quiver"},
            {name="Darksteel Bolt Quiver", id=4229, default=false, resource_name="D. Bolt Quiver"},
            {name="Darkling Bolt Quiver", id=5820, default=false, resource_name="Dkl. Bolt Quiver"},
            {name="Fusion Bolt Quiver", id=5821, default=false, resource_name="Fsn. Bolt Quiver"},
            {name="Dark Adaman Bolt Quiver", id=5872, default=false, resource_name="D.A. Bolt Quiver"},
            {name="Adaman Bolt Quiver", id=5913, default=false, resource_name="A. Bolt Quiver"},
            {name="Oxidant Bolt Quiver", id=6141, default=false, resource_name="O. Bolt Quiver"},
            {name="Midrium Bolt Quiver", id=6139, default=false, resource_name="Mid. Bolt Quiver"},
            {name="Damascus Bolt Quiver", id=6140, default=false, resource_name="Dm. Bolt Quiver"},
            {name="Titanium Bolt Quiver", id=6205, default=false, resource_name="T. Bolt Quiver"},
            {name="Bismuth Bolt Quiver", id=6206, default=false, resource_name="Bi. Bolt Quiver"},
            {name="Adlivun Bolt Quiver", id=6204, default=false, resource_name="Ad. Bolt Quiver"},
            {name="Gashing Bolt Quiver", id=6310, default=false, resource_name="Gash. Bolt Quiver"},
            {name="Ra'Kaznar Bolt Quiver", id=6281, default=false, resource_name="Ra. Bolt Quiver"},
            {name="Abrasion Bolt Quiver", id=6278, default=false, resource_name="Abr. Bolt Quiver"},
            {name="Righteous Bolt Quiver", id=6279, default=false, resource_name="Rig. Bolt Quiver"},
            {name="Eminent Bolt Quiver", id=6270, default=false, resource_name="Em. Bolt Quiver"},
        },
    },
    {
        key="ammo_bullets", title="Ammo - Bullets", curio=true,
        items={
            {name="Bronze Bullet Pouch", id=5359, default=false, resource_name="Brz. Bull. Pouch"},
            {name="Bullet Pouch", id=5363, default=false},
            {name="Spartan Bullet Pouch", id=5341, default=false, resource_name="Spar. Bul. Pouch"},
            {name="Iron Bullet Pouch", id=5353, default=false, resource_name="Iron Bull. Pouch"},
            {name="Silver Bullet Pouch", id=5340, default=false, resource_name="Silv. Bul. Pouch"},
            {name="Corsair Bullet Pouch", id=5342, default=false, resource_name="Cor. Bull. Pouch"},
            {name="Steel Bullet Pouch", id=5416, default=false, resource_name="Stl. Bull. Pouch"},
            {name="Dweomer Bullet Pouch", id=5822, default=false, resource_name="Dwm. Bul. Pouch"},
            {name="Oberon Bullet Pouch", id=5823, default=false, resource_name="Obr. Bull. Pouch"},
            {name="Dark Adaman Bullet Pouch", id=5873, default=false, resource_name="D.A. Bull. Pouch"},
            {name="Orichalcum Bullet Pouch", id=5914, default=false, resource_name="O. Bull. Pouch"},
            {name="Adaman Bullet Pouch", id=5915, default=false, resource_name="A. Bull. Pouch"},
            {name="Midrium Bullet Pouch", id=6142, default=false, resource_name="Mid. Bul. Pouch"},
            {name="Damascus Bullet Pouch", id=6143, default=false, resource_name="Dm. Bul. Pouch"},
            {name="Titanium Bullet Pouch", id=6209, default=false, resource_name="Ti. Bull. Pouch"},
            {name="Bismuth Bullet Pouch", id=6210, default=false, resource_name="Bi. Bull. Pouch"},
            {name="Adlivun Bullet Pouch", id=6208, default=false, resource_name="Ad. Bull. Pouch"},
            {name="Decimating Bullet Pouch", id=6311, default=false, resource_name="Dec. Bul. Pouch"},
            {name="Ra'Kaznar Bullet Pouch", id=6282, default=false, resource_name="Ra. Bul. Pouch"},
            {name="Eminent Bullet Pouch", id=6271, default=false, resource_name="Em. Bul. Pouch"},
        },
    },
    {
        key="ammo_shuriken", title="Ammo - Shuriken", curio=true,
        items={
            {name="Shuriken Pouch", id=6299, default=false, resource_name="Sh. Pouch"},
            {name="Juji Shuriken Pouch", id=6297, default=false, resource_name="Juji Sh. Pouch"},
            {name="Manji Shuriken Pouch", id=6298, default=false, resource_name="Manji Sh. Pouch"},
            {name="Fuma Shuriken Pouch", id=6302, default=false, resource_name="Fuma Sh. Pouch"},
            {name="Iga Shuriken Pouch", id=6303, default=false, resource_name="Iga Sh. Pouch"},
            {name="Roppo Shuriken Pouch", id=6304, default=false, resource_name="Rop. Sh. Pouch"},
            {name="Happo Shuriken Pouch", id=6306, default=false, resource_name="Hap. Sh. Pouch"},
            {name="Hachiya Shuriken Pouch", id=6308, default=false, resource_name="Hac. Sh. Pouch"},
            {name="Suppa Shuriken Pouch", id=6309, default=false, resource_name="Sup. Sh. Pouch"},
        },
    },
    {
        key="ninjutsu", title="Ninjutsu Toolbags", curio=true,
        items={
            {name="Toolbag (Uchi)", id=5308, default=false},
            {name="Toolbag (Tsura)", id=5309, default=false},
            {name="Toolbag (Kawa)", id=5310, default=false},
            {name="Toolbag (Maki)", id=5311, default=false},
            {name="Toolbag (Hira)", id=5312, default=false},
            {name="Toolbag (Mizu)", id=5313, default=false},
            {name="Toolbag (Shihe)", id=5314, default=true},
            {name="Toolbag (Jusa)", id=5315, default=false},
            {name="Toolbag (Kagi)", id=5316, default=false},
            {name="Toolbag (Sai)", id=5317, default=false},
            {name="Toolbag (Kodo)", id=5318, default=false},
            {name="Toolbag (Shino)", id=5319, default=false},
            {name="Toolbag (Sanja)", id=5417, default=false},
            {name="Toolbag (Soshi)", id=5734, default=false},
            {name="Toolbag (Kaben)", id=5863, default=false},
            {name="Toolbag (Jinko)", id=5864, default=false},
            {name="Toolbag (Ryuno)", id=5865, default=false},
            {name="Toolbag (Moku)", id=5866, default=false},
            {name="Toolbag (Ino)", id=5867, default=false},
            {name="Toolbag (Shika)", id=5868, default=false},
            {name="Toolbag (Cho)", id=5869, default=false},
            {name="Toolbag (Ranka)", id=6265, default=false},
            {name="Toolbag (Furu)", id=6266, default=false},
        },
    },
    {
        key="food", title="Food", curio=true,
        items={
            {name="Selbina Milk", id=4378, default=false},
            {name="Orange au Lait", id=4299, default=false},
            {name="Uleguerand Milk", id=5703, default=false},
            {name="Apple au Lait", id=4300, default=false},
            {name="Pear au Lait", id=4301, default=false},
            {name="Persikos au Lait", id=4303, default=false},
            {name="Dragon Fruit au Lait", id=5933, default=false, resource_name="D. Fruit au Lait"},
            {name="Orange Juice", id=4422, default=false},
            {name="Melon Juice", id=4424, default=false},
            {name="Yagudo Drink", id=4558, default=false},
            {name="Kitron Juice", id=5932, default=false},
            {name="Rice Ball", id=4405, default=false},
            {name="Meat Jerky", id=4376, default=false},
            {name="Grilled Hare", id=4371, default=false},
            {name="Meat Mithkabob", id=4381, default=false},
            {name="Yellow Curry Bun", id=5757, default=false, resource_name="Ylw. Curry Bun"},
            {name="Rabbit Pie", id=5685, default=false},
            {name="Marinara Slice", id=6211, default=false},
            {name="Red Curry Bun", id=5759, default=false},
            {name="Boiled Crab", id=4456, default=false},
            {name="Fish Mithkabob", id=4398, default=false},
            {name="Black Curry Bun", id=5758, default=false},
            {name="Tavnazian Taco", id=5174, default=false},
            {name="Coeurl Sub", id=5166, default=false},
            {name="Roast Pipira", id=4538, default=false},
            {name="Anchovy Slice", id=6217, default=false},
            {name="Pepperoni Slice", id=6215, default=false},
            {name="Carbonara", id=5190, default=false},
            {name="Pot-au-feu", id=5752, default=false},
            {name="Jack-o'-Lantern", id=4488, default=false},
            {name="Squid Sushi", id=5148, default=false},
            {name="Sole Sushi", id=5149, default=false},
            {name="Bream Sushi", id=5176, default=false},
            {name="Dorado Sushi", id=5178, default=false},
            {name="Crab Sushi", id=5721, default=false},
            {name="Chocolate Crepe", id=5775, default=false},
            {name="Butter Crepe", id=5766, default=false},
            {name="Pear Crepe", id=5777, default=false},
            {name="Fruit Parfait", id=6063, default=false},
            {name="Apple Pie", id=4413, default=false},
            {name="Melon Pie", id=4421, default=false},
            {name="Pumpkin Pie", id=4446, default=false},
            {name="Crimson Jelly", id=5144, default=false},
            {name="Icecap Rolanberry", id=4556, default=false},
            {name="Cream Puff", id=5718, default=false},
            {name="Roast Mushroom", id=4410, default=false},
            {name="Acorn Cookie", id=4510, default=false},
            {name="Ginger Cookie", id=4394, default=false},
            {name="Sugar Rusk", id=5782, default=false},
            {name="Chocolate Rusk", id=5783, default=false},
            {name="Coconut Rusk", id=5784, default=false},
            {name="Cherry Macaron", id=5779, default=false},
            {name="Coffee Macaron", id=5780, default=false},
            {name="Kitron Macaron", id=5781, default=false},
            {name="Saltena", id=5885, default=false},
            {name="Elshena", id=5886, default=false},
            {name="Montagna", id=5887, default=false},
            {name="Maringna", id=5888, default=false},
            {name="Stuffed Pitaru", id=5889, default=false},
            {name="Poultry Pitaru", id=5890, default=false},
            {name="Seafood Pitaru", id=5891, default=false},
            {name="B.E.W. Pitaru", id=5892, default=false},
            {name="Shiromochi", id=6258, default=false},
            {name="Kusamochi", id=6262, default=false},
            {name="Akamochi", id=6260, default=false},
            {name="Rolanberry Daifuku", id=6339, default=false, resource_name="Rolan. Daifuku"},
            {name="Bean Daifuku", id=6341, default=false},
            {name="Grape Daifuku", id=6343, default=true},
            {name="Beef Stewpot", id=5547, default=false},
            {name="Zaru Soba", id=5727, default=false},
            {name="Spicy Cracker", id=4466, default=false},
        },
    },
    {
        key="scrolls", title="Instant Scrolls", curio=true,
        items={
            {name="Instant Warp", id=4181, default=false},
            {name="Instant Reraise", id=4182, default=false},
            {name="Instant Retrace", id=5428, default=false},
            {name="Instant Protect", id=5988, default=false},
            {name="Instant Shell", id=5989, default=false},
            {name="Instant Stoneskin", id=5990, default=false},
        },
    },
    {
        key="rema_ammo", title="REMA Ammo", curio=false,
        items={
            {name="Chrono Bullet", id=21296, default=false},
            {name="Chrono Arrow", id=21297, default=false},
            {name="Artemis's Arrow", id=21298, default=false},
            {name="Yoichi's Arrow", id=21299, default=false},
            {name="Quelling Bolt", id=21311, default=false},
            {name="Devastating Bullet", id=21325, default=false},
            {name="Living Bullet", id=21326, default=false},
            {name="Eradicating Bullet", id=21327, default=false},
        },
    },
    {
        key="extras", title="Extras", curio=false,
        items={
            {name="Shihei", id=1179, default=true},
            {name="Super Reraiser", id=5770, default=true},
            {name="Vaccine", id=nil, default=true},
        },
    },
}

local function make_key(name)
    local key = name:lower():gsub('[^%w]+', '_')
    key = key:gsub('^_+', ''):gsub('_+$', '')
    return key
end

local item_by_key = {}
local item_aliases = {}
local section_by_key = {}
local total_item_count = 0

local function normalize(value)
    return (value or ''):lower():gsub('[^%w]', '')
end

for _, section in ipairs(SECTIONS) do
    section_by_key[section.key] = section

    for _, entry in ipairs(section.items) do
        entry.key = make_key(entry.name)

        if item_by_key[entry.key] then
            error('ConsumableHUD duplicate item key: ' .. entry.key)
        end

        item_by_key[entry.key] = entry
        item_aliases[normalize(entry.key)] = entry
        item_aliases[normalize(entry.name)] = entry

        if entry.resource_name then
            item_aliases[normalize(entry.resource_name)] = entry
        end

        total_item_count = total_item_count + 1
    end
end

local defaults = {items = {}, hud_mode = 'town'}
for key, entry in pairs(item_by_key) do
    defaults.items[key] = entry.default == true
end

local settings = config.load(defaults)

if not HUD_MODE_VALUES[settings.hud_mode] then
    settings.hud_mode = defaults.hud_mode
end

config.save(settings)

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
local tracked_ids = {}

local function notify(message)
    windower.add_to_chat(CHAT_COLOR, '[ConsumableHUD] ' .. message)
end

local function is_enabled(entry)
    return settings.items[entry.key] == true
end

local function enabled_count()
    local count = 0
    for _, entry in pairs(item_by_key) do
        if is_enabled(entry) then
            count = count + 1
        end
    end
    return count
end

local function rebuild_tracked_ids()
    tracked_ids = {}

    for _, entry in pairs(item_by_key) do
        if is_enabled(entry) and entry.id then
            tracked_ids[entry.id] = true
        end
    end
end

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
    local name_width = 0

    for _, section in ipairs(SECTIONS) do
        for _, entry in ipairs(section.items) do
            if is_enabled(entry) and #entry.name > name_width then
                name_width = #entry.name
            end
        end
    end

    name_width = math.max(name_width, 12)

    for _, section in ipairs(SECTIONS) do
        local section_lines = {}

        for _, entry in ipairs(section.items) do
            if is_enabled(entry) then
                local count = entry.id and (counts[entry.id] or 0) or 0
                section_lines[#section_lines + 1] = string.format('%-' .. name_width .. 's %4d', entry.name, count)
            end
        end

        if #section_lines > 0 then
            if #lines > 0 then
                lines[#lines + 1] = ''
            end

            lines[#lines + 1] = section.title
            for _, line in ipairs(section_lines) do
                lines[#lines + 1] = line
            end
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

local function is_allowed_zone(zone_id)
    return zone_id ~= nil and ALLOWED_ZONES[zone_id] == true
end

local function should_show_in_zone(zone_id)
    if settings.hud_mode == 'off' then
        return false
    end

    if settings.hud_mode == 'always' then
        return true
    end

    return is_allowed_zone(zone_id)
end

local function apply_current_visibility(refresh_now)
    local info = windower.ffxi.get_info()
    local visible = should_show_in_zone(info and info.zone or nil) and enabled_count() > 0
    set_hud_visible(visible)

    if visible and refresh_now then
        refresh()
    end

    return visible
end

local function save_and_refresh()
    config.save(settings)
    rebuild_tracked_ids()
    apply_current_visibility(true)
    last_refresh = os.clock()
end

local function resolve_item(selector)
    return item_aliases[normalize(selector)]
end

local function set_item(entry, mode)
    if mode == 'toggle' then
        settings.items[entry.key] = not is_enabled(entry)
    else
        settings.items[entry.key] = mode == 'on'
    end

    save_and_refresh()
    notify(entry.name .. ': ' .. (is_enabled(entry) and 'ON' or 'OFF'))
end

local function set_section(section, mode)
    local enable

    if mode == 'toggle' then
        enable = false
        for _, entry in ipairs(section.items) do
            if not is_enabled(entry) then
                enable = true
                break
            end
        end
    else
        enable = mode == 'on'
    end

    for _, entry in ipairs(section.items) do
        settings.items[entry.key] = enable
    end

    save_and_refresh()
    notify(section.title .. ': ' .. (enable and 'ON' or 'OFF'))
end

local function set_all(mode)
    local enable

    if mode == 'toggle' then
        enable = enabled_count() < total_item_count
    else
        enable = mode == 'on'
    end

    for key in pairs(item_by_key) do
        settings.items[key] = enable
    end

    save_and_refresh()
    notify('All items: ' .. (enable and 'ON' or 'OFF'))
end

local function set_hud_mode(mode)
    settings.hud_mode = mode
    config.save(settings)
    apply_current_visibility(true)
    last_refresh = os.clock()
    notify('HUD mode: ' .. HUD_MODE_LABELS[settings.hud_mode])
end

local function cycle_hud_mode()
    local current_index = 1

    for index, mode in ipairs(HUD_MODE_ORDER) do
        if mode == settings.hud_mode then
            current_index = index
            break
        end
    end

    local next_index = current_index % #HUD_MODE_ORDER + 1
    set_hud_mode(HUD_MODE_ORDER[next_index])
end

local function reset_items()
    for key, entry in pairs(item_by_key) do
        settings.items[key] = entry.default == true
    end

    settings.hud_mode = defaults.hud_mode
    save_and_refresh()
    notify('Item selection and HUD mode reset to the v0.2.2 defaults.')
end

local function print_help()
    notify('Commands:')
    notify('//consumablehud on|off|toggle <item name or key>')
    notify('//consumablehud category <medicines|ammo_arrows|ammo_bolts|ammo_bullets|ammo_shuriken|ninjutsu|food|scrolls|rema_ammo|extras> <on|off|toggle>')
    notify('//consumablehud all <on|off|toggle>')
    notify('//consumablehud hud [always|town|off|cycle]')
    notify('//consumablehud reset | status | help')
end

rebuild_tracked_ids()
apply_current_visibility(true)
last_refresh = os.clock()

windower.register_event('zone change', function(new_zone)
    local visible = should_show_in_zone(new_zone) and enabled_count() > 0
    set_hud_visible(visible)
    last_refresh = os.clock() - REFRESH_INTERVAL
end)

windower.register_event('prerender', function()
    local now = os.clock()
    if now - last_refresh < REFRESH_INTERVAL then
        return
    end

    last_refresh = now

    if not apply_current_visibility(false) then
        return
    end

    refresh()
end)

windower.register_event('addon command', function(command, ...)
    command = (command or 'help'):lower()
    local args = {...}

    if command == 'on' or command == 'off' or command == 'toggle' then
        local selector = table.concat(args, ' ')
        local entry = resolve_item(selector)

        if not entry then
            notify('Unknown item: ' .. selector)
            return
        end

        set_item(entry, command)
        return
    end

    if command == 'category' then
        local category_key = (args[1] or ''):lower()
        local mode = (args[2] or ''):lower()
        local section = section_by_key[category_key]

        if not section or (mode ~= 'on' and mode ~= 'off' and mode ~= 'toggle') then
            notify('Usage: //consumablehud category <category> <on|off|toggle>')
            return
        end

        set_section(section, mode)
        return
    end

    if command == 'all' then
        local mode = (args[1] or ''):lower()

        if mode ~= 'on' and mode ~= 'off' and mode ~= 'toggle' then
            notify('Usage: //consumablehud all <on|off|toggle>')
            return
        end

        set_all(mode)
        return
    end

    if command == 'hud' or command == 'mode' then
        local requested = normalize(args[1] or 'cycle')

        if requested == 'cycle' or requested == '' then
            cycle_hud_mode()
            return
        end

        local mode_aliases = {
            always = 'always',
            alwayson = 'always',
            on = 'always',
            town = 'town',
            townonly = 'town',
            intown = 'town',
            off = 'off',
            alwaysoff = 'off',
        }

        local mode = mode_aliases[requested]
        if not mode then
            notify('Usage: //consumablehud hud [always|town|off|cycle]')
            return
        end

        set_hud_mode(mode)
        return
    end

    if command == 'reset' then
        reset_items()
        return
    end

    if command == 'status' then
        notify(string.format('HUD %s; enabled %d/%d items; Curio catalog %d; REMA ammo %d.', HUD_MODE_LABELS[settings.hud_mode], enabled_count(), total_item_count, CURIO_ITEM_COUNT, REMA_AMMO_COUNT))
        return
    end

    print_help()
end)

windower.register_event('unload', function()
    if hud then
        hud:destroy()
        hud = nil
    end
end)
