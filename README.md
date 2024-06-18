# oUF_AuraTrack

Aura track on raid frame support for oUF lauouts.

## Element: AuraTrack

Handles creation and updating of aura buttons on raid frame.

### Widgets

-   `AuraTrack`: A Frame to hold `Button`s representing buffs.

### Options

-   `.num`: Number of auras to display. Defaults to 4 (number)
-   `.spacing`: Spacing between each button. Defaults to 6 (number)
-   `.filter`: Custom filter list for auras to display. Defaults to 'HELPFUL' (string)
-   `.spells`: Table of spells to track. the table key is a spellID and value is a RGB color.
-   `.icons`: Use icon own textures, else use the a color specified in the spell table.
-   `.display`: "INLINE" or "CORNER"

#### Example

```lua
-- Position and size
local AuraTrack = CreateFrame("Frame", nil, self)
AuraTrack:SetAllPoints()
AuraTrack.icons = true
AuraTrack.num = 4
AuraTrack.spacing = 6
AuraTrack.filter = "HELPFUL"
AuraTrack.spells = {
    [139] = oUF:CreateColor(0.40, 0.70, 0.20), -- Renew
}

-- Register with oUF
self.AuraTrack = AuraTrack
```
