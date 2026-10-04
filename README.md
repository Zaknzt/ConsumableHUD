# ConsumableHUD

A lightweight Windower 4 addon for **Final Fantasy XI** that shows a simple, draggable HUD with counts for commonly used consumables and tools.

ConsumableHUD is intentionally small and read-only. It does not use items, buy items, send gameplay commands, or modify inventory.

## Current release

**v0.1.2**

## Features

- Displays counts for commonly carried consumables.
- Counts items across:
  - Inventory
  - Mog Satchel
  - Mog Sack
  - Mog Case
- Refreshes once per second while visible.
- Draggable HUD.
- Automatically hides outside supported city/hub zones.
- Skips inventory rescanning while hidden.
- No gameplay automation.

## Tracked items

### Consumables

- Panacea
- Remedy
- Antidote
- Echo Drops
- Holy Water
- Eye Drops
- Vaccine
- Grape Daifuku

### Sneak / Invisible

- Silent Oil
- Prism Powder

### Utsusemi

- Shihei
- Toolbag (Shihe)

### Reraise

- Reraiser
- Hi-Reraiser
- Super Reraiser

> **Vaccine note:** the current Windower Resources dataset does not expose a player-item entry named `Vaccine`, so ConsumableHUD currently displays it as `0`.

## Supported zones

The HUD appears only in the following city/hub areas.

### San d'Oria

- Southern San d'Oria
- Northern San d'Oria
- Port San d'Oria
- Chateau d'Oraguille

### Bastok

- Bastok Mines
- Bastok Markets
- Port Bastok
- Metalworks

### Windurst

- Windurst Waters
- Windurst Walls
- Port Windurst
- Windurst Woods
- Heavens Tower

### Jeuno

- Ru'Lude Gardens
- Upper Jeuno
- Lower Jeuno
- Port Jeuno

### Other hubs

- Rabao
- Western Adoulin
- Eastern Adoulin

## Installation

### Option 1 — download the Lua file

1. Create:

   `Windower/addons/ConsumableHUD/`

2. Download `ConsumableHUD.lua` from this repository and place it in that folder.

3. In game:

   ```
   //lua load ConsumableHUD
   ```

4. Drag the HUD to your preferred location.

### Option 2 — clone the repository

From `Windower/addons/`:

```bash
git clone https://github.com/Zaknzt/ConsumableHUD.git ConsumableHUD
```

Then load it in game:

```
//lua load ConsumableHUD
```

To unload:

```
//lua unload ConsumableHUD
```

To load automatically with Windower, add this line to your normal Windower startup script:

```
lua load ConsumableHUD
```

## Configuration

ConsumableHUD v0.1.2 intentionally has no external configuration file or command interface.

The tracked items, supported zones, HUD position/style, bag list, and refresh interval are defined near the top of `ConsumableHUD.lua`.

Default HUD position:

- X: 20
- Y: 220

Default refresh interval:

- 1 second

## Design / safety

ConsumableHUD is deliberately passive.

It only reads:

- current zone information;
- item stacks in Inventory, Satchel, Sack, and Case.

It does **not**:

- use consumables;
- move inventory;
- purchase items;
- send FFXI commands;
- alter GearSwap;
- alter Trust;
- inject packets;
- automate movement or combat.

## Requirements

- Windower 4
- Windower's standard `texts` library

## Development

ConsumableHUD is maintained by **Zaknzt**.

The addon was developed and live-tested as part of the FFXI Development II tooling project, then published here as a standalone community addon.

## Feedback / issues

If you find a bug or have a suggestion, please open a GitHub issue and include:

- the zone you were in;
- what the HUD displayed;
- what you expected;
- relevant item counts/bags;
- any Windower console error text.

## License

ConsumableHUD is released under the [MIT License](LICENSE).

## Disclaimer

Final Fantasy XI is a trademark of Square Enix Holdings Co., Ltd. Windower is a third-party project. ConsumableHUD is an independent community addon and is not affiliated with or endorsed by Square Enix or the Windower project.
