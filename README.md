# oUF_AuraTrack

Aura track on raid frame support for oUF lauouts.

## Element: AuraTrack

Handles the visibility and updating of aura tracker on raid frame.

### Widgets:

- `AuraTrack`: A 'Texture" to represent spell duration.

### Options

-   `.Thickness` : Thickness of the statusbar
-   `.Tracker` : Table of buffs spell id to track, if not spiecified, use default listing
-   `.Texture` : Texture you want to use for status bars
-   `.Icons` : Set to true if you wish to use squared icons instead of status bars
-   `.SpellTextures` : Spell Textures instead of colored squares
-   `.MaxAuras` : Set the max amount of status or icons shows

### Example

```lua
local AuraTrack = CreateFrame("Frame", nil, Health)
AuraTrack:SetAllPoints()
AuraTrack.Texture = C.Medias.Normal
AuraTrack.Icons = true
AuraTrack.SpellTextures = true
AuraTrack.Thickness = 5
AuraTrack.Font = C.Medias.Font

self.AuraTrack = AuraTrack
```
