# ConsumableHUD

A lightweight Windower 4 addon for **Final Fantasy XI** that shows a simple, draggable HUD with counts for selected consumables and tools.

ConsumableHUD is intentionally read-only. It does not use items, buy items, send gameplay commands, or modify inventory.

## Current release

**v0.2.2**

## Features

- Displays only the consumables you choose to track.
- Persists per-item On/Off selections through Windower's standard `config` library.
- Includes a maintained catalog of **199 verified Curio Vendor Moogle consumables**:
  - medicines;
  - arrow quivers;
  - bolt quivers;
  - bullet pouches;
  - shuriken pouches;
  - ninjutsu toolbags;
  - food;
  - instant scrolls.
- Adds a separate **REMA Ammo** catalog with eight weapon-dispensed ammunition types from Relic, Mythic, Empyrean, and Aeonic ranged weapons.
- Retains the existing custom rows for Shihei, Super Reraiser, and Vaccine.
- Counts enabled real-ID items across:
  - Inventory
  - Mog Satchel
  - Mog Sack
  - Mog Case
- Refreshes once per second while visible.
- Scans only enabled item IDs.
- Draggable HUD.
- Adds a persistent three-state HUD visibility mode: **Always**, **Town**, or **Off**.
- `Town` preserves the existing supported city/hub zone allowlist.
- Skips inventory rescanning while hidden.
- No gameplay automation.

New Curio catalog entries and all REMA ammunition entries default to **Off**, while the items displayed by v0.1.2 remain **On** by default.

> **Vaccine note:** the current Windower Resources dataset does not expose a player-item entry named `Vaccine`, so the retained legacy row displays `0` when enabled.

## Curio catalog scope

The catalog intentionally treats repeat-purchase consumables as:

- medicines;
- ammunition containers;
- ninjutsu toolbags;
- foodstuffs;
- instant scrolls.

Curio-sold equipment, keys, Limbus materials, permanent/key items, and other non-consumable merchandise are outside ConsumableHUD scope.

## REMA ammunition

The separate `rema_ammo` category contains the eight special ammunition types dispensed by level-119 III REMA ranged weapons (or by their replacement dispenser waist pieces after REMA augmentation):

- Relic:
  - Yoichinoyumi -> Yoichi's Arrow
  - Annihilator -> Eradicating Bullet
- Mythic:
  - Gastraphetes -> Quelling Bolt
  - Death Penalty -> Living Bullet
- Empyrean:
  - Gandiva -> Artemis's Arrow
  - Armageddon -> Devastating Bullet
- Aeonic:
  - Fail-Not -> Chrono Arrow
  - Fomalhaut -> Chrono Bullet

These eight entries default to Off and are tracked as the ammunition stacks themselves, not the dispenser weapons or waist equipment.

## Commands

Turn individual items on, off, or toggle them:

```
//consumablehud on <item name or key>
//consumablehud off <item name or key>
//consumablehud toggle <item name or key>
```

Examples:

```
//consumablehud off Vaccine
//consumablehud on Grape Daifuku
//consumablehud on Vile Elixir +1
```

Manage whole catalog sections:

```
//consumablehud category <category> <on|off|toggle>
```

Category keys:

```
medicines
ammo_arrows
ammo_bolts
ammo_bullets
ammo_shuriken
ninjutsu
food
scrolls
rema_ammo
extras
```

Examples:

```
//consumablehud category food on
//consumablehud category ammo_bullets off
//consumablehud category rema_ammo on
```

HUD visibility mode:

```
//consumablehud hud always
//consumablehud hud town
//consumablehud hud off
//consumablehud hud cycle
```

`//consumablehud hud` with no argument also cycles the three states. `//consumablehud mode ...` is an alias.

- **Always** — show the HUD in any zone.
- **Town** — show the HUD only in the existing city/hub allowlist.
- **Off** — hide the HUD everywhere.

Item selection remains independent from HUD mode. If no items are enabled, there is no useful HUD content to display.

Other commands:

```
//consumablehud all <on|off|toggle>
//consumablehud status
//consumablehud reset
//consumablehud help
```

`reset` restores the v0.2.2 default item selection **and resets HUD mode to Town**. Item names with spaces may be entered normally because the addon joins the remaining command words when resolving an item.

## Supported zones

These zones are used when HUD mode is **Town**:

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

To unload it:

```
//lua unload ConsumableHUD
```

To load it automatically with Windower, add this line to your normal Windower startup script:

```
lua load ConsumableHUD
```

## Configuration

On first v0.2.2 load, ConsumableHUD creates/updates its normal Windower settings file through the standard `config` library. Every catalog item has a persistent boolean setting, and `hud_mode` persists as `always`, `town`, or `off`.

Default HUD mode: **Town**.

You can change item selection with the addon commands above or by editing the normal generated settings file while the addon is unloaded.

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

Its command surface changes only local HUD-selection and HUD-visibility settings. It does **not**:

- use consumables;
- move inventory;
- purchase items;
- send FFXI gameplay commands;
- alter GearSwap;
- alter Trust;
- interact with VanaAgent;
- inject packets;
- use IPC;
- automate movement or combat.

## Requirements

- Windower 4
- Windower's standard `texts` library
- Windower's standard `config` library

## Data provenance

Curio Vendor Moogle catalog membership was reconciled against current retail Curio Vendor references. Exact item identities and IDs are pinned to:

- `Windower/Resources` commit `99f552fa7cdd8e4a65e3dfa5bbd7d9462ac60b89`
- `resources_data/items.lua` Git blob `abd1e4103f4a640cafe2ca51e6753e8008c87e7a`

REMA weapon-to-ammunition relationships were separately verified against current retail REMA weapon/ammunition documentation. External references establish provenance/mechanics only; implementation identity remains pinned to the Windower resource IDs and this repository's immutable candidate commit.

## Development

ConsumableHUD is maintained by **Zaknzt**.

The addon was developed and live-tested as part of the FFXI Development II tooling project, then published here as a standalone community addon.

## Feedback / issues

If you find a bug or have a suggestion, open a GitHub issue with:

- the zone you were in;
- what the HUD displayed;
- what you expected;
- relevant item counts/bags;
- any Windower console error text.

## License

ConsumableHUD is released under the [MIT License](LICENSE).

## Disclaimer

Final Fantasy XI is a trademark of Square Enix Holdings Co., Ltd. Windower is a third-party project. ConsumableHUD is an independent community addon and is not affiliated with or endorsed by Square Enix or the Windower project.
