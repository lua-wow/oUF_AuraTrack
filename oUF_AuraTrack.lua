--[[
	# Element: AuraTrack

	Handles creation and updating of aura buttons on raid frames.

	## Widgets

	AuraTrack	- A Frame to hold `Button`s representing buffs.

	## Options

	.num			- Number of auras to display. Defaults to 4 (number)
	.spacing		- Spacing between each button. Defaults to 6 (number)
	.spells			- Table of spells to track. the table key is a spellID and value is category.
	.display		- Setup how icons are displayed inside the unit frame. Options: "INLINE" or "CORNER". Default: "INLINE"
	.onlyShowPlayer - Shows only auras created by player/vehicle (boolean)

	### Spell Categories
	
	"heal"		-- display heals casted by the player only, like 'Renew', 'Regrowth', etc.
	"buff"		-- display auras casted by the player only, like 'Power Infustion'.
	"raid"		-- display auras casted by any unit which affects other units, like 'Power Word: Barrier', 'Pain Supression', 'Life Cocoon', etc.
	"defensive" -- display auras casted by a unit on itself, like 'Dispersion', 'Shield Wall', 'Dampen Harm', etc.

	## Example

		-- Position and size
		local AuraTrack = CreateFrame("Frame", nil, self)
		AuraTrack:SetAllPoints()
		AuraTrack.num = 4
		AuraTrack.spacing = 6
		AuraTrack.filter = "HELPFUL"
		AuraTrack.spells = {
			[17]    = "heal", -- Power Word: Shield ("heal" display only buffs casted by player)
			[10060] = "buff", -- Power Infusion
			[33206] = "raid", -- Pain Suppression
			[81782] = "raid", -- Power World: Barrier
			[47585] = "defensive", -- Dispersion
		}

		-- Register with oUF
		self.AuraTrack = AuraTrack
--]]

local _, ns = ...
local oUF = ns.oUF
assert(oUF, "oUF_AuraTrack as unable to locate oUF install.")

local _, class = UnitClass("player")

local spells = oUF.auras or {}

local function CreateButton(element, index)
	local button = CreateFrame("Button", element:GetDebugName() .. "Button" .. index, element)

	if button.CreateBackdrop then
		button:CreateBackdrop()
	end
	
	local cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
	cd:SetAllPoints()
	cd:SetReverse(true)
	cd:SetHideCountdownNumbers(true)
	
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	local countFrame = CreateFrame("Frame", nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)
	
	local count = countFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	count:SetPoint("BOTTOMRIGHT", countFrame, "BOTTOMRIGHT", -1, 0)
	
	button.Cooldown = cd
	button.Icon = icon
	button.Count = count

	--[[ Callback: AuraTrack:PostCreateButton(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if (element.PostCreateButton) then
		element:PostCreateButton(button)
	end

	return button
end

local function SetPosition(element, from, to)
	local display = element.display or "INLINE"
	local size = element.size or 16
	local spacing = element.spacing or 6

	local positions = {
		[1] = "TOPLEFT",
		[2] = "TOPRIGHT",
		[3] = "BOTTOMLEFT",
		[4] = "BOTTOMRIGHT"
	}

	for i = from, to do
		local button = element[i]
		if (not button) then break end

		if (display == "CORNER") then
			local j = ((i - 1) % 4) + 1
			local pos = positions[j]
			local x = pos:match("LEFT") and 3 or -3
			local y = pos:match("TOP") and -3 or 3

			button:ClearAllPoints()
			button:SetPoint(pos, x, y)
		else
			local x = (i * size) - (size) + (i * spacing)
			local y = (size / 3)

			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", x, y)
		end
	end
end

local function Update(element, unit, data, position)
	if (not data.name) then return end

	local button = element[position]
	if (not button) then
		--[[ Override: Auras:CreateButton(position)
		Used to create an aura button at a given position.

		* self     - the widget holding the aura buttons
		* position - the position at which the aura button is to be created (number)

		## Returns

		* button - the button used to represent the aura (Button)
		--]]
		button = (element.CreateButton or CreateButton)(element, position)

		table.insert(element, button)
		element.createdButtons = element.createdButtons + 1
	end

	-- for tooltips
	button.auraInstanceID = data.auraInstanceID
	button.isHarmful = data.isHarmful

	if (button.Cooldown and not element.disableCooldown) then
		if (data.duration > 0) then
			button.Cooldown:SetCooldown(data.expirationTime - data.duration, data.duration, data.timeMod)
			button.Cooldown:Show()
		else
			button.Cooldown:Hide()
		end
	end

	if (button.Icon) then
		button.Icon:SetTexture(data.icon)
	end

	if (button.Count) then
		button.Count:SetText(data.applications > 1 and data.applications or '')
	end

	local size = element.size or 16
	button:SetSize(size, size)
	button:EnableMouse(false)
	button:Show()

	--[[ Callback: AuraTrack:PostUpdateButton(unit, button, data, position)
	Called after the aura button has been updated.

	* self     - the widget holding the aura buttons
	* button   - the updated aura button (Button)
	* unit     - the unit for which the update has been triggered (string)
	* data     - the [UnitAuraInfo](https://wowpedia.fandom.com/wiki/Struct_UnitAuraInfo) object (table)
	* position - the actual position of the aura button (number)
	--]]
	if (element.PostUpdateButton) then
		element:PostUpdateButton(button, unit, data, position)
	end
end

local function FilterAura(element, unit, data)
	if element.onlyShowPlayer then
		return data.isPlayerAura and (element.type ~= nil)
	end
	
	if data.type == "heal" or data.type == "buff" or data.type == true then
		return data.isPlayerAura
	end
	return data.type ~= nil
end

local function SortAuras(a, b)
	if (a.isPlayerAura ~= b.isPlayerAura) then
		return a.isPlayerAura
	end

	if (a.canApplyAura ~= b.canApplyAura) then
		return a.canApplyAura
	end

	-- if aura 'duration' is 'nil' or '0', it do not expires
	local aExpires = a.duration and a.duration > 0
	local bExpires = b.duration and b.duration > 0
	if (aExpires ~= bExpires) then
		return aExpires
	end

	if (aExpires and bExpires and a.duration ~= b.duration) then
		return a.duration < b.duration
	end

	return a.auraInstanceID < b.auraInstanceID
end

local function ProcessData(element, unit, data)
	if (not data) then return end

	data.isPlayerAura = data.sourceUnit and (UnitIsUnit("player", data.sourceUnit) or UnitIsOwnerOrControllerOfUnit("player", data.sourceUnit))
	
	if data.sourceUnit == "player" then
		data.sourceClass = class
		data.type = element.spells[data.spellId]
	elseif data.sourceUnit then
		data.sourceClass = select(2, UnitClass(data.sourceUnit))
		data.type = (spells[data.sourceClass] or {})[data.spellId]
	end

	--[[ Callback: AuraTrack:PostProcessAuraData(unit, data)
	Called after the aura data has been processed.

	* self - the widget holding the aura buttons
	* unit - the unit for which the update has been triggered (string)
	* data - [UnitAuraInfo](https://wowpedia.fandom.com/wiki/Struct_UnitAuraInfo) object (table)

	## Returns

	* data - the processed aura data (table)
	--]]
	if (element.PostProcessAuraData) then
		data = element:PostProcessAuraData(unit, data)
	end

	return data
end

local function UpdateAuras(self, event, unit, info)
	if (self.unit ~= unit) then return end

	local isFullUpdate = (not info) or info.isFullUpdate

	local element = self.AuraTrack
	if (not element) then return end

	element.num = element.num or 4
	element.spacing = element.spacing or 6
	element.size = (element:GetWidth() / element.num) - (element.spacing) - (element.spacing / (element.num))
	element.filter = "HELPFUL"
	if (element.onlyShowPlayer) then
		element.filter = element.filter .. "|PLAYER"
	end

	if (element.PreUpdate) then
		element:PreUpdate(unit, isFullUpdate)
	end

	local changed = false

	if (isFullUpdate) then
		element.all = table.wipe(element.all or {})
		element.active = table.wipe(element.active or {})
		changed = true

		local slots = { C_UnitAuras.GetAuraSlots(unit, element.filter) }
		for i = 2, #slots do
			local data = ProcessData(element, unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]))
			element.all[data.auraInstanceID] = data

			if ((element.FilterAura or FilterAura)(element, unit, data)) then
				element.active[data.auraInstanceID] = true
			end
		end
	else
		if (info.addedAuras) then
			for _, data in next, info.addedAuras do
				if(data.isHelpful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, element.filter)) then
					element.all[data.auraInstanceID] = ProcessData(element, unit, data)

					if ((element.FilterAura or FilterAura)(element, unit, data)) then
						element.active[data.auraInstanceID] = true
						changed = true
					end
				end
			end
		end

		if (info.updatedAuraInstanceIDs) then
			for _, auraInstanceID in next, info.updatedAuraInstanceIDs do
				if(element.all[auraInstanceID]) then
					element.all[auraInstanceID] = ProcessData(element, unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID))

					if (element.active[auraInstanceID]) then
						element.active[auraInstanceID] = true
						changed = true
					end
				end
			end
		end

		if (info.removedAuraInstanceIDs) then
			for _, auraInstanceID in next, info.removedAuraInstanceIDs do
				if(element.all[auraInstanceID]) then
					element.all[auraInstanceID] = nil

					if(element.active[auraInstanceID]) then
						element.active[auraInstanceID] = nil
						changed = true
					end
				end
			end
		end
	end

	if (element.PostUpdateInfo) then
		element:PostUpdateInfo(unit, changed)
	end

	if (changed) then
		element.sorted = table.wipe(element.sorted or {})

		for auraInstanceID in next, element.active do
			table.insert(element.sorted, element.all[auraInstanceID])
		end

		table.sort(element.sorted, element.SortBuffs or element.SortAuras or SortAuras)

		local numVisible = math.min(element.num, #element.sorted)

		for i = 1, numVisible do
			Update(element, unit, element.sorted[i], i)
		end

		local visibleChanged = false

		if (numVisible ~= element.visibleButtons) then
			element.visibleButtons = numVisible
			visibleChanged = element.reanchorIfVisibleChanged
		end

		for i = numVisible + 1, #element do
			element[i]:Hide()
		end

		if (visibleChanged or element.createdButtons > element.anchoredButtons) then
			if (visibleChanged) then
				(element.SetPosition or SetPosition) (element, 1, numVisible)
			else
				(element.SetPosition or SetPosition) (element, element.anchoredButtons + 1, element.createdButtons)
				element.anchoredButtons = element.createdButtons
			end
		end

		if (element.PostUpdate) then
			element:PostUpdate(unit)
		end
	end
end

local function Path(self, ...)
	return (self.AuraTrack.Override or UpdateAuras)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.AuraTrack
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element.createdButtons = element.createdButtons or 0
		element.anchoredButtons = 0
		element.visibleButtons = 0
		element.onlyShowPlayer = ((type(element.onlyShowPlayer) == "boolean") and element.onlyShowPlayer) or false
		element.spells = Mixin(spells[class] or {}, element.spells or {})

		self:RegisterEvent("UNIT_AURA", Path)

		return true
	end
end

local function Disable(self)
	if (self.AuraTrack) then
		self:UnregisterEvent("UNIT_AURA", Path)
	end
end

oUF:AddElement("AuraTrack", Path, Enable, Disable)
