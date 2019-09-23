SUF.PartyTarget = { xPos = 172 }

function PartyTargetFrame_OnLoad(self)
	local id = self:GetID()
	local prefix = "PartyTargetFrame"..id

	self.classicon = getglobal(self:GetName().."ClassIcon")

	UnitFrame_Initialize(self, "party"..id.."target",
						getglobal(prefix.."Name"),
						getglobal(prefix.."Portrait"),
						getglobal(prefix.."HealthBar"),
						getglobal(prefix.."HealthBarText"),
						getglobal(prefix.."ManaBar"),
						getglobal(prefix.."ManaBarText"),
						nil)

	SetTextStatusBarTextZeroText(getglobal(prefix.."HealthBar"), TEXT(DEAD))

	self:SetAttribute("unit", self.unit)

	if (SMART_PARTY_Config.target == false or
		(GetCVar("hidePartyInRaid") == "1" and GetNumRaidMembers() > 0)) then
		SMART_RegisterUnitWatch(self, false)
	else
		SMART_RegisterUnitWatch(self, true)
	end

	self:SetScale(.80)
	self:SetMovable(true)
	self:SetHitRectInsets(0, 8, 4, 4)

	self.statusCounter = 0
	self.statusSign = -1
	self.unitHPPercent = 1

	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("PARTY_MEMBER_ENABLE")
	self:RegisterEvent("PARTY_MEMBER_DISABLE")
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("UNIT_AURA")
	--self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	--This should fix a few "sync" bugs
	self:RegisterEvent("UNIT_PVP_UPDATE")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH")
	self:RegisterEvent("UNIT_MANA")
	self:RegisterEvent("UNIT_RAGE")
	self:RegisterEvent("UNIT_FOCUS")
	self:RegisterEvent("UNIT_ENERGY")
	self:RegisterEvent("UNIT_TARGET")

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("VARIABLES_LOADED")

	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal(self:GetName().."DropDown"), self:GetName(), 120, 10)
	end

	SecureUnitButton_OnLoad(self, self.unit, showmenu)

	PartyTargetFrame_UpdateMember(self)
end

function PartyTargetFrameDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PartyTargetFrameDropDown_Initialize, "MENU");
end

local dropdownMenu = nil
local dropdownUnit = nil

function PartyTargetFrameDropDown_Initialize(self)
	if self.unit then
		local menu;
		local name;
		local id = nil;
		local unit = self.unit

		if (UnitIsUnit(unit, "pet")) then
			menu = "PET";
		elseif (UnitIsPlayer(unit)) then
			id = UnitInRaid(unit);
			if (id) then
				menu = "RAID_PLAYER";
			elseif (UnitInParty(unit)) then
				menu = "PARTY";
			else
				menu = "PLAYER";
			end
		else
			menu = "RAID_TARGET_ICON";
			name = RAID_TARGET_ICON;
		end

		if (menu) then
			dropdownMenu = getglobal(self:GetName().."DropDown")

			if unit then
				dropdownUnit = self.unit
			end

			if dropdownMenu then
				UnitPopup_ShowMenu(dropdownMenu, menu, unit, name, id);
			end
		end
	else
		if dropdownMenu and dropdownUnit then
			UnitPopup_ShowMenu(dropdownMenu, "RAID_TARGET_ICON", dropdownUnit, RAID_TARGET_ICON, nil);
		end
	end
end

function PartyTargetFrame_UpdatePvPStatus(self)
	local id = self:GetID();
	local icon = getglobal("PartyTargetFrame"..id.."PVPIcon")
	local factionGroup = UnitFactionGroup(self.unit)

	if (UnitIsPVPFreeForAll(self.unit)) then
		icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		icon:Show()
	elseif ( factionGroup and UnitIsPVP(self.unit) ) then
		icon:SetTexture("Interface\\GroupFrame\\UI-Group-PVP-"..factionGroup)
		icon:Show()
	else
		icon:Hide()
	end
end

function PartyTargetFrame_UpdateOnlineStatus(self)
	local selfName = self:GetName();

	if (not UnitIsConnected(self.unit)) then
		-- Handle disconnected state
		local healthBar = _G[selfName.."HealthBar"];
		local unitHPMin, unitHPMax = healthBar:GetMinMaxValues();

		healthBar:SetValue(unitHPMax);
		healthBar:SetStatusBarColor(0.5, 0.5, 0.5);
		SetDesaturation(getglobal(selfName.."Portrait"), 1);
		getglobal(selfName.."Disconnect"):Show();
	else
		SetDesaturation(getglobal(selfName.."Portrait"), nil);
		getglobal(selfName.."Disconnect"):Hide();
	end
end

function PartyTargetFrame_UpdateMember(self)
	if (SMART_PARTY_Config.target == false or
		(GetCVar("hidePartyInRaid") == "1" and GetNumRaidMembers() > 0)) then
		SMART_RegisterUnitWatch(self, false)
		return;
	end

	SMART_RegisterUnitWatch(self, true)

	SMART_ClassIcons(self.classicon, self.unit)

	local id = self:GetID()

	if (GetPartyMember(id) and UnitExists(self.unit)) then
		UnitFrameManaBar_UpdateType(manaBar) --fix
		UnitFrame_Update(self)
	end

	PartyTargetFrame_UpdatePvPStatus(self);
	PartyTargetFrame_UpdateOnlineStatus(self);
end

function PartyTargetFrame_OnUpdate(self, elapsed)
	if ((self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2)) then
		local alpha = 255
		local counter = self.statusCounter + elapsed
		local sign = self.statusSign

		if (counter > 0.5) then
			sign = -sign
			self.statusSign = sign
		end

		counter = mod(counter, 0.5)
		self.statusCounter = counter

		if (sign == 1) then
			alpha = (127  + (counter * 256)) / 255
		else
			alpha = (255 - (counter * 256)) / 255
		end

		getglobal(self:GetName().."Portrait"):SetAlpha(alpha)
	end
end

function PartyTargetFrame_OnEvent(self, event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1 = ...;

	if (event == "PLAYER_ENTERING_WORLD") then
		if (GetPartyMember(self:GetID())) then
			PartyTargetFrame_UpdateMember(self);
			return
		end
	elseif (event == "VARIABLES_LOADED") then
		if (SMART_CLASSICON_ENABLE and SMART_CLASSICON_PARTY) or (IsAddOnLoaded("ClassIcons")) then
			local t = _G[self:GetName().."HighLevelTexture"]
			t:ClearAllPoints()
			t:SetPoint("BOTTOMLEFT", _G[self:GetName().."Portrait"], "BOTTOMLEFT", 2, -2)
		end
	elseif (event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "UNIT_TARGET") then
		PartyTargetFrame_UpdateMember(self);
		return;
	elseif (event == "UNIT_PVP_UPDATE") then
		if (arg1 == self.unit) then
			PartyTargetFrame_UpdatePvPStatus(self)
		end
		return;
	elseif (event == "UNIT_FACTION") then
		if (arg1 == self.unit) then
			PartyTargetFrame_UpdatePvPStatus(self)
		end
		return;
	elseif (event == "UNIT_TARGET") then -- arg1 == who's target was changed
		if (arg1 == "party"..self:GetID()) then
			PartyTargetFrame_UpdateMember(self);
		end
	elseif (event == "UNIT_HEALTH" and (arg1 == self.unit)) then
		PartyTargetFrame_UpdateOnlineStatus(self);
	end
end

function PartyTargetFrame_HealthCheck(self)
	local portrait = getglobal(self:GetParent():GetName().."Portrait")
	local unitHPMin, unitHPMax = self:GetMinMaxValues()
	local unitHPCur = self:GetValue();

	if (unitHPMax > 0) then
		self:GetParent().unitHPPercent = unitHPCur / unitHPMax;
	else
		self:GetParent().unitHPPercent = 0;
	end

	if (UnitIsDead(self:GetParent().unit)) then
		portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0)
	elseif (UnitIsGhost(self:GetParent().unit)) then
		portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0)
	elseif ((self:GetParent().unitHPPercent > 0) and (self:GetParent().unitHPPercent <= 0.2)) then
		portrait:SetVertexColor(1.0, 0.0, 0.0)
	else
		portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0)
	end
end

function SmartPartyTarget_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED")

	local blizFrame = self:GetParent()

	blizFrame.smartFrame = self

	self:SetFrameLevel(blizFrame:GetFrameLevel()+2)
	blizFrame:SetMovable(true)
	blizFrame:SetHitRectInsets(0, 8, 4, 4)

	local f

	f = getglobal(blizFrame:GetName().."HealthBar")
	f:SetHitRectInsets(0, f:GetWidth(), 0, f:GetHeight())

	f = getglobal(blizFrame:GetName().."ManaBar")
	f:SetHitRectInsets(0, f:GetWidth(), 0, f:GetHeight())

	-- 블리자드 기본 생명력/마나 텍스트는 숨긴다.
	f = getglobal(blizFrame:GetName().."HealthBarText")
	if f then f:SetAlpha(0) f:Hide() end

	f = getglobal(blizFrame:GetName().."ManaBarText")
	if f then f:SetAlpha(0) f:Hide() end

	self.statusCounter = 0
	self.statusSign = -1

	self:CreateTexture(self:GetName().."RaidTargetIcon", "OVERLAY")
	self.raidtargeticon = getglobal(self:GetName().."RaidTargetIcon")
	self.raidtargeticon:ClearAllPoints()
	self.raidtargeticon:SetPoint("TOPLEFT", blizFrame:GetName().."Portrait", "TOPLEFT", 0, 2)
	self.raidtargeticon:SetWidth(25)
	self.raidtargeticon:SetHeight(25)
	self.raidtargeticon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");

	SmartParty_RaidTargetIcon(self)

	-- Status Texture
	f = blizFrame:CreateTexture(blizFrame:GetName().."StatusTexture", "OVERLAY")
	f:SetPoint("TOPLEFT", getglobal(blizFrame:GetName().."Portrait"), "TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", getglobal(blizFrame:GetName().."Portrait"), "BOTTOMRIGHT", 0, 0)
	f:SetTexture("Interface\\AddOns\\SmartUnitFrame\\CircleFlash.tga")
	--f:SetTexCoordModifiesRect(false)
	f:SetTexCoord(0, 1, 0, 1)
	f:SetBlendMode("ADD")
	f:SetVertexColor(1, 0.5, 0)

	self.shortenvalue = true;

	f = getglobal(self:GetParent():GetName().."HealthBar")
	f.OnValueChangedFunc = f:GetScript("OnValueChanged")

	f:SetScript("OnValueChanged", function(self, ...)
		if self.OnValueChangedFunc then
			self:OnValueChangedFunc(...)
		end

		SmartParty_HealthUpdate(getglobal("SmartPartyTargetFrame"..self:GetParent():GetID()))
	end)

	f = getglobal(self:GetParent():GetName().."ManaBar")
	f.OnValueChangedFunc = f:GetScript("OnValueChanged")

	f:SetScript("OnValueChanged", function(self, ...)
		if self.OnValueChangedFunc then
			self:OnValueChangedFunc(...)
		end

		SmartParty_ManaUpdate(getglobal("SmartPartyTargetFrame"..self:GetParent():GetID()))
	end)
end

function SmartPartyTarget_OnEvent(self, event, ...)
	if (event == "VARIABLES_LOADED") then
		local mastericon = getglobal(self:GetParent():GetName().."MasterIcon")
		local pvpicon = getglobal(self:GetParent():GetName().."PVPIcon")

		if mastericon then
			mastericon:SetPoint("TOPLEFT", mastericon:GetParent(),"TOPLEFT",29,-31)
		end

		if pvpicon then
			pvpicon:ClearAllPoints()
			pvpicon:SetPoint("TOPLEFT", getglobal(self:GetParent():GetName().."Portrait"),"TOPLEFT", -15, -5)
		end

		if (SMART_CLASSICON_ENABLE and SMART_CLASSICON_PARTY) or (IsAddOnLoaded("ClassIcons")) then
			local leveltext = getglobal(self:GetName().."LevelText")
			leveltext:ClearAllPoints()
			leveltext:SetPoint("BOTTOMLEFT", getglobal(self:GetParent():GetName().."Portrait"), "BOTTOMLEFT", 2, -2)
			leveltext:SetJustifyH("LEFT")
		end

		hooksecurefunc("PartyTargetFrame_UpdateMember", function(...) SmartParty_UpdateMember(...) end)
		return
	end
end

function SmartPartyTarget_ResetPosition(force)
	local i

	for i = 1, MAX_PARTY_MEMBERS do
		local frame = getglobal("PartyTargetFrame"..i)

		if force or not frame:IsUserPlaced() then
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", getglobal("PartyMemberFrame"..i), "TOPRIGHT", SUF.PartyTarget.xPos, 0)

			frame:SetUserPlaced(false)
		end
	end
end

