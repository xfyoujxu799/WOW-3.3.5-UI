SUF =
{
	skin = nil,
}

SmartManaBarColor =
{
	[0] = { r = 0.00, g = 0.82, b = 1.00, prefix = TEXT(MANA) },
	[1] = { r = 1.00, g = 0.41, b = 0.41, prefix = TEXT(RAGE) },
	[2] = { r = 1.00, g = 0.50, b = 0.25, prefix = TEXT(FOCUS) },
	[3] = { r = 1.00, g = 0.82, b = 0.00, prefix = TEXT(ENERGY) },
	[4] = { r = 0.00, g = 1.00, b = 0.82, prefix = TEXT(HAPPINESS) },
	[5] = { r = 0.50, g = 0.50, b = 0.50, prefix = TEXT(RUNES) },
	[6] = { r = 0.00, g = 0.50, b = 1.00, prefix = TEXT(RUNIC_POWER) },
}

SmartEliteText = {boss="首領",rareelite="稀有精英",elite="精英",rare="稀有"}

-------------------------------------------------------
--
-- SMART - Common Library
--
-------------------------------------------------------
local hpColorRed = { r = 1, g = 0, b = 0 }
local hpColorNormal = { r = 1, g = 1, b = 1 }

function SMART_HealthColor(unit)
	if (UnitHealth(unit) / UnitHealthMax(unit)) < 0.2 then
		return hpColorRed
	else
		return hpColorNormal
	end
end

function SMART_PortraitColor(self, unit)
	local hpColor = SMART_HealthColor(unit)
	self:SetVertexColor(hpColor.r, hpColor.g, hpColor.b)
end

function SMART_ManaPercent(self, unit)
	if UnitIsConnected(unit) then
		if UnitManaMax(unit) > 0 then
			self:SetText(string.format("%d%%", floor((UnitMana(unit) / UnitManaMax(unit)) * 100)))
		else
			self:SetText(string.format("%d%%", 0))
		end

		SMART_ManaType(self, unit)

		self:Show()
	else
		self:Hide()
	end
end

function SMART_HealthPercent(self, unit)
	if UnitIsConnected(unit) then
		local hpColor = SMART_HealthColor(unit)

		self:SetTextColor(hpColor.r, hpColor.g, hpColor.b)
		self:SetText(string.format("%d%%", floor((UnitHealth(unit) / UnitHealthMax(unit)) * 100)))
		self:Show()
	else
		self:Hide()
	end
end

local function formatShortenNumber(n)
	if n < 100000 then
		return n
	elseif n < 1000000 then
		return string.format("%.1fk", n / 1000)
	elseif n < 10000000 then
		return string.format("%.2fm", n / 1000000)
	else
		return string.format("%.1fm", n / 1000000)
	end
end

function SMART_OldStyleHealthUpdate(self, unit)
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)

	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		self:SetText(floor((cur / max) * 100).." / 100")
		self:Show();
	else
		self:Hide();
	end
end

function SMART_HealthUpdate(self, unit, shortenvalue)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local txt
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)

		if shortenvalue then
			txt = string.format("%s / %s", formatShortenNumber(cur), formatShortenNumber(max));
		else
			txt = string.format("%d / %d", cur, max)
		end

		self:SetText(txt)
		self:Show()
	else
		self:Hide()
	end
end

function SMART_HealthLoss(self, unit, shortenvalue)
	if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
		local loss = UnitHealthMax(unit) - UnitHealth(unit);

		if (loss > 0) then
			local txt;
			local color = SMART_HealthColor(unit)

			if shortenvalue then
				txt = string.format("-%s", formatShortenNumber(loss));
			else
				txt = string.format("-%d", loss);
			end

			self:SetTextColor(color.r, color.g, color.b)
			self:SetText(txt)
			self:Show()
		else
			self:Hide()
		end
	else
		self:Hide()
	end
end

function SMART_ManaUpdate(self, unit, shortenvalue)
	if (unit == "target") or (unit == "player") or (unit == "pet") or (unit == "focus") then
		self:SetTextColor(1, 1, 1)
	else
		SMART_ManaType(self, unit)
	end

	if UnitIsConnected(unit) then
		local txt
		local cur, max = UnitMana(unit), UnitManaMax(unit);

		if shortenvalue then
			txt = string.format("%s / %s", formatShortenNumber(cur), formatShortenNumber(max));
		else
			txt = string.format("%d / %d", cur, max)
		end

		self:SetText(txt)
		self:Show()
	else
		self:Hide()
	end
end

function SMART_ManaType(self, unit)
	local powerType = UnitPowerType(unit)

	if SmartManaBarColor[powerType] then
		self:SetTextColor(SmartManaBarColor[powerType].r, SmartManaBarColor[powerType].g, SmartManaBarColor[powerType].b)
	end
end

local SmartNameColors = {
	[1] = FACTION_BAR_COLORS[1],
	[2] = FACTION_BAR_COLORS[2],
	[3] = FACTION_BAR_COLORS[3],
	[4] = FACTION_BAR_COLORS[4],
	[5] = FACTION_BAR_COLORS[5],
	[6] = FACTION_BAR_COLORS[6],
	[7] = FACTION_BAR_COLORS[7],
	[8] = FACTION_BAR_COLORS[8],
	[0] = { r = 1, g = 0.82, b = 0 },
	[99] = { r = 0.35, g = 0.35, b = 0.35 },
};

function SMART_ColorName(self, unit)
	local idx = 0

	if (UnitPlayerControlled(unit)) then
		if (UnitCanAttack(unit, "player")) then
			idx = 2
		elseif (UnitCanAttack("player", unit)) then
			idx = 4
		elseif (UnitIsPVP(unit)) then
			idx = 6
		end
		-- □□ □□□□ □□
	elseif (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		idx = 99
	else
		local reaction = UnitReaction("player", unit)

		if (reaction) then
			idx = reaction
		end
	end

	self:SetTextColor(SmartNameColors[idx].r, SmartNameColors[idx].g, SmartNameColors[idx].b)
	self:SetText(GetUnitName(unit, true))
	self:Show()
end

function SMART_CheckElite(self, unit)
	local classification = UnitClassification(unit)
	local chkElite

	if ( classification == "worldboss" ) then
		chkElite = SmartEliteText.boss
	elseif ( classification == "rareelite"  ) then
		chkElite = SmartEliteText.rareelite
	elseif ( classification == "elite"  ) then
		chkElite = SmartEliteText.elite
	elseif ( classification == "rare"  ) then
		chkElite = SmartEliteText.rare
	else
		chkElite = ""
	end

	self:SetText(chkElite)
	self:Show()
end

function SMART_CheckLevel(self, unit)
	local chkLevel = UnitLevel(unit)

	if (UnitCanAttack("player", unit)) then
		local color = GetQuestDifficultyColor(chkLevel)
		self:SetTextColor(color.r, color.g, color.b)
	else
		self:SetTextColor(1, 0.82, 0)
	end

	if (chkLevel <= 0) then
		chkLevel = "??"
	end

	self:SetText(chkLevel)
	self:Show()
end

function SMART_ClassIcons(self, unit)
	local _, englishClass = UnitClass(unit)

	if englishClass and UnitIsPlayer(unit) then
		self:SetTexture("Interface\\AddOns\\SmartUnitFrame\\Icons\\"..englishClass)
		self:Show()
	else
		self:Hide()
	end
end

function SMART_RaidTargetCheck(self, unit)
	if GetRaidTargetIndex(unit) then
		SetRaidTargetIconTexture(self, GetRaidTargetIndex(unit))
		self:Show()
	else
		self:Hide()
	end
end

function SMART_CheckFeign(unit)
	local _, class = UnitClass(unit)
	if class ~= "HUNTER" then return false end

	local num = 1
	local _, icon = UnitBuff(unit, num)

	while (icon) do
		if (icon == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
			return true
		end
		num = num + 1
		_, icon = UnitBuff(unit, num)
	end

	return false
end

function SMART_FactionGroupCheck(self, unit)
	if not self then
		return
	end

	if (UnitIsPVPFreeForAll(unit)) then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:Show()
	elseif (UnitFactionGroup(unit) and UnitIsPVP(unit)) then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..UnitFactionGroup(unit))
		self:Show()
	else
		self:Hide()
	end
end

function SMART_RegisterUnitWatch(self, enable)
	if self.enable ~= enable then
		if enable then
			if not InCombatLockdown() then self:Show(); end
			RegisterUnitWatch(self);
		else
			if not InCombatLockdown() then self:Hide(); end
			UnregisterUnitWatch(self);
		end

		self.enable = enable;
	end
end

function SMART_CopyDefaultConfig(dest, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if not rawget(dest, k) then rawset(dest, k, {}) end
			if type(dest[k]) == "table" then
				SMART_CopyDefaultConfig(dest[k], v)
			end
		else
			if rawget(dest, k) == nil then
				rawset(dest, k, v)
			end
		end
	end
end
