# oUF_AuraTrack

Aura track on raid frame support for oUF lauouts.

## Element: AuraTrack

Handles creation and updating of aura buttons on raid frames.

### Widgets

-   `AuraTrack`: A Frame to hold `Button`s representing buffs.

### Options

-   `.num`: Number of auras to display. Defaults to 4 (number)
-   `.spacing`: Spacing between each button. Defaults to 6 (number)
-   `.spells`: Table of spells to track. the table key is a spellID and value is category.
-   `.display`: Setup how icons are displayed inside the unit frame. Options: "INLINE" or "CORNER". Default: "INLINE"
-   `.onlyShowPlayer`: Shows only auras created by player/vehicle (boolean)

#### Spell Categories
	
-   `"heal"`: display heals casted by the player only, like 'Renew', 'Regrowth', etc.
-   `"buff"`: display auras casted by the player only, like 'Power Infustion'.
-   `"raid"`: display auras casted by any unit which affects other units, like 'Power Word: Barrier', 'Pain Supression', 'Life Cocoon', etc.
-   `"defensive"`: display auras casted by a unit on itself, like 'Dispersion', 'Shield Wall', 'Dampen Harm', etc.

### Example

```lua
-- Position and size
local AuraTrack = CreateFrame("Frame", nil, self)
AuraTrack:SetAllPoints()
AuraTrack.num = 4
AuraTrack.spacing = 6
AuraTrack.onlyShowPlayer = true
AuraTrack.spells = {
    -- PRIEST
    [17]    = "heal", -- Power Word: Shield
    [10060] = "buff", -- Power Infusion
    [33206] = "raid", -- Pain Suppression
    [81782] = "raid", -- Power World: Barrier
    [47585] = "defensive", -- Dispersion
}

-- Register with oUF
self.AuraTrack = AuraTrack
```
