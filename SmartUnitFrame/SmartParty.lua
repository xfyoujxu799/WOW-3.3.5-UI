--------------------------------------------
--
-- SMART - PARTY
--
--------------------------------------------
SMART_PARTY_ENABLE = true

SMART_PARTY_Config = {  --fishuiedit
	statusbartext=false,
	percent=false,
	loss=true,
	losstopercent=true,
	level=true,
	color=true,
	namewithserver=true,
	bufffilter=false,
	debufffilter=true,
	showauracooldown=true,
	groupicon=true,
	movable=true,
	movablegroup=true,
	castingbar=false,
	target=true,
};

------------------------------------------------------------------------------------
-- Party Frame
------------------------------------------------------------------------------------
function SmartParty_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("RAID_TARGET_UPDATE")

	local blizFrame = self:GetParent()

	blizFrame.smartFrame = self

	self:SetFrameLevel(blizFrame:GetFrameLevel()+2)
	blizFrame:SetMovable(true)
	blizFrame:SetHitRectInsets(0, 8, 4, 4)

	local f

	f = getglobal(blizFrame:GetName().."HealthBar")
	f:SetHitRectInsets(0, f:GetWidth(), 0, f:GetHeight())

	f.OnValueChangedFunc = f:GetScript("OnValueChanged")
	f:SetScript("OnValueChanged", function(self, ...)
		if self.OnValueChangedFunc then
			self:OnValueChangedFunc(...) end

		SmartParty_SetStatusText(getglobal("SmartPartyFrame"..self:GetParent():GetID()))
		SmartParty_HealthUpdate(getglobal("SmartPartyFrame"..self:GetParent():GetID()))
	end)

	f = getglobal(blizFrame:GetName().."ManaBar")
	f:SetHitRectInsets(0, f:GetWidth(), 0, f:GetHeight())

	f.OnValueChangedFunc = f:GetScript("OnValueChanged")
	f:SetScript("OnValueChanged", function(self, ...)
		if self.OnValueChangedFunc then
			self:OnValueChangedFunc(...)
		end

		SmartParty_ManaUpdate(getglobal("SmartPartyFrame"..self:GetParent():GetID()))
	end)

	-- Hide Blizzard Frames
	f = getglobal(blizFrame:GetName().."HealthBarText")
	f:SetAlpha(0)
	f:Hide()

	f = getglobal(blizFrame:GetName().."ManaBarText")
	f:SetAlpha(0)
	f:Hide()

	self.statusCounter = 0
	self.statusSign = -1

	-- Raid Target
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

	-- Voice Chat
	_G[blizFrame:GetName().."Speaker"]:ClearAllPoints();
	_G[blizFrame:GetName().."Speaker"]:SetPoint("TOP", self:GetName().."LevelText", "BOTTOM", 0, 0);

	f = _G[blizFrame:GetName().."SpeakerFrame"];
	f.LeaderIcon = _G[blizFrame:GetName().."LeaderIcon"];
	f.OnShowFunc = f:GetScript("OnShow");
	f.OnHideFunc = f:GetScript("OnHide");

	f:SetScript("OnShow", function(self)
		if self.OnShowFunc then
			self.OnShowFunc(self);
		end

		self.LeaderIcon:SetAlpha(0);
		self.LeaderIcon:Hide();
	end);

	f:SetScript("OnHide", function(self)
		if self.OnHideFunc then
			self.OnHideFunc(self);
		end

		self.LeaderIcon:SetAlpha(1);

		if (GetPartyLeaderIndex() == self:GetParent():GetID()) then
			self.LeaderIcon:Show();
		end
	end);

	f:SetPoint("TOPLEFT");
end

function SmartParty_OnUpdate(self, elapsed)
	local texture = getglobal(self:GetParent():GetName().."StatusTexture")
	local unit = self:GetParent().unit

	if UnitAffectingCombat(unit) then
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
			alpha = (55 + (counter * 400)) / 255
		else
			alpha = (255 - (counter * 400)) / 255
		end

		texture:SetAlpha(alpha)
		texture:Show()
	else
		texture:Hide()
	end
end

function SmartParty_ResetPosition()
	if PartyMemberFrame1:IsUserPlaced() then
		PartyMemberFrame1:ClearAllPoints()

		if SMART_GROUPICON_ENABLE then
			PartyMemberFrame1:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 40, -180)
		else
			PartyMemberFrame1:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 24, -180)
		end
	else
		local _, _, _, _, yOfs = PartyMemberFrame1:GetPoint()

		PartyMemberFrame1:ClearAllPoints()

		if SMART_GROUPICON_ENABLE then
			PartyMemberFrame1:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 40, yOfs)
		else
			PartyMemberFrame1:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 24, yOfs)
		end
	end

	PartyMemberFrame1:SetUserPlaced(false)
end

function SmartParty_GroupCheck(groupCheck)
	if SMART_PARTY_Config.movablegroup or groupCheck then
		local frame

		for id=2, MAX_PARTY_MEMBERS do
			frame = getglobal("PartyMemberFrame"..id)

			if frame:IsUserPlaced() then
				frame:ClearAllPoints()
				frame:SetPoint("TOPLEFT", getglobal("PartyMemberFrame"..(id-1).."PetFrame"), "BOTTOMLEFT", -23, -10)
				frame:SetUserPlaced(false)
			end
		end
	end
end

-- Dead or Ghost / Offline
function SmartParty_SetStatusText(self)
	local statusText = getglobal(self:GetName().."StatusText")
	local unit = self:GetParent().unit

	if UnitIsConnected(unit) then
		if UnitIsDead(unit) then
			if SMART_CheckFeign(unit) then
				statusText:SetText("假死")
			else
				statusText:SetText("死亡")
			end
			statusText:Show()
		elseif UnitIsGhost(unit) then
			statusText:SetText("幽靈")
			statusText:Show()
		else
			statusText:SetText("")
			statusText:Hide()
		end
	else
		if UnitIsDead(unit) then
			statusText:SetText("死亡")
			statusText:Show()
		elseif UnitIsPlayer(unit) then
			statusText:SetText("離線")
			statusText:Show()
		else
			statusText:SetText("")
			statusText:Hide()
		end
	end
end

function SmartParty_HealthUpdate(self)
	local unit = self:GetParent().unit

	-- HP/MP Percent or HP/MaxHP MP/MaxMP
	if SMART_PARTY_Config.statusbartext then
		if SMART_PARTY_Config.percent then
			getglobal(self:GetName().."HealthBarText"):Hide()
			SMART_HealthPercent(getglobal(self:GetName().."HealthPercent"), unit)
		else
			getglobal(self:GetName().."HealthPercent"):Hide()
			SMART_HealthUpdate(getglobal(self:GetName().."HealthBarText"), unit, self.shortenvalue)
		end
	else
		getglobal(self:GetName().."HealthBarText"):Hide()
		getglobal(self:GetName().."HealthPercent"):Hide()
	end

	-- Health Loss SHOW/HIDE
	if SMART_PARTY_Config.loss then
		if SMART_PARTY_Config.losstopercent then
			SMART_HealthPercent(getglobal(self:GetName().."HealthLoss"), unit)
		else
			SMART_HealthLoss(getglobal(self:GetName().."HealthLoss"), unit, self.shortenvalue)
		end
	else
		getglobal(self:GetName().."HealthLoss"):Hide()
	end
end

-- HP/MP Percent or HP/MaxHP MP/MaxMP
function SmartParty_ManaUpdate(self)
	local unit = self:GetParent().unit

	if SMART_PARTY_Config.statusbartext then
		if SMART_PARTY_Config.percent then
			getglobal(self:GetName().."ManaBarText"):Hide()
			SMART_ManaPercent(getglobal(self:GetName().."ManaPercent"), unit)
		else
			getglobal(self:GetName().."ManaPercent"):Hide()
			SMART_ManaUpdate(getglobal(self:GetName().."ManaBarText"), unit, self.shortenvalue)
		end
	else
		getglobal(self:GetName().."ManaBarText"):Hide()
		getglobal(self:GetName().."ManaPercent"):Hide()
	end
end

function SmartParty_LevelUpdate(self)
	local unit = self:GetParent().unit
	local levelText = getglobal(self:GetName().."LevelText")
	local highlevelTexture = getglobal(self:GetParent():GetName().."HighLevelTexture");

	if not SMART_PARTY_Config.level or not UnitIsConnected(unit) or UnitIsCorpse(unit) then
		levelText:Hide();
		if highlevelTexture then highlevelTexture:Hide(); end
	else
		local targetLevel = UnitLevel(unit);

		if targetLevel > 0 then
			levelText:SetText(targetLevel)

			if UnitCanAttack(unit, "player") or UnitCanAttack("player", unit) then
				local color = GetQuestDifficultyColor(targetLevel);
				levelText:SetTextColor(color.r, color.g, color.b);
			else
				levelText:SetTextColor(1.0, 0.82, 0.0);
			end

			levelText:Show();
			if highlevelTexture then highlevelTexture:Hide(); end
		else
			levelText:Hide()
			if highlevelTexture then highlevelTexture:Show(); end
		end
	end
end

-- Name coloring by class
function SmartParty_ColorName(self)
	local unit = self:GetParent().unit
	local colorName = getglobal(self:GetParent():GetName().."Name")

	if UnitIsConnected(unit) then
		if UnitCanAttack(unit, "player") or UnitCanAttack("player", unit) then
			colorName:SetTextColor(1, 0, 0)
		else
			if SMART_PARTY_Config.color then
				local _, englishClass = UnitClass(unit)

				if (englishClass) then
					local classColor = RAID_CLASS_COLORS[englishClass]
					colorName:SetTextColor(classColor.r,classColor.g,classColor.b)
				else
					colorName:SetTextColor(1,0.82,0)
				end
			else
				colorName:SetTextColor(1, 0.82, 0)
			end
		end
	else
		colorName:SetTextColor(0.75, 0.75, 0.75)
	end

	colorName:SetText(GetUnitName(unit, SMART_PARTY_Config.namewithserver))
end

-- Raid Target Icon
function SmartParty_RaidTargetIcon(self)
	SMART_RaidTargetCheck(self.raidtargeticon, self:GetParent().unit)
end

function SmartParty_UpdateMember(self)
	if self and self.smartFrame then
		local f = self.smartFrame

		SmartParty_SetStatusText(f)
		SmartParty_HealthUpdate(f)
		SmartParty_ManaUpdate(f)
		SmartParty_LevelUpdate(f)
		SmartParty_ColorName(f)
		SmartParty_RaidTargetIcon(f)
	end
end

function SmartParty_OnEvent(self, event, ...)
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

		hooksecurefunc("PartyMemberFrame_UpdateMember", function(...) SmartParty_UpdateMember(...) end)
		return
	end

	local unit = self:GetParent().unit

	if UnitExists(unit) then
		if (event == "UNIT_FACTION") then
			if UnitIsUnit(unit, arg1) or (arg1 == "player") then
				SmartParty_ColorName(self)
				SmartParty_LevelUpdate(self)
			end
		elseif (event == "UNIT_LEVEL") then
			if UnitIsUnit(unit, arg1) then
				SmartParty_LevelUpdate(self)
			end
		elseif (event == "RAID_TARGET_UPDATE") then
			SmartParty_RaidTargetIcon(self)
		end
	end
end

------------------------------------------------------------------------------------
-- Spell Casting Bar
------------------------------------------------------------------------------------
function SmartParty_Spellbar_OnLoad(self)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PARTY_MEMBER_ENABLE")
	self:RegisterEvent("PARTY_MEMBER_DISABLE")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("CVAR_UPDATE")

	local blizFrame = self:GetParent():GetParent()
	CastingBarFrame_OnLoad(self, blizFrame.unit, false)

	self:SetID(blizFrame:GetID())
	self:SetFrameStrata("MEDIUM")
	RaiseFrameLevel(self)

	local barIcon = getglobal(self:GetName().."Icon")
	barIcon:Hide()

	SmartParty_Spellbar_SetAspect(self)
end

function SmartParty_Spellbar_SetAspect(self)
	local frameText = getglobal(self:GetName().."Text")

	if (frameText) then
		frameText:SetTextHeight(10)
		frameText:ClearAllPoints()
		frameText:SetPoint("TOP", self, "TOP", 0, 4)
	end

	local frameBorder = getglobal(self:GetName().."Border")

	if (frameBorder) then
		frameBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")
		frameBorder:SetWidth(156)
		frameBorder:SetHeight(49)
		frameBorder:ClearAllPoints()
		frameBorder:SetPoint("TOP", self, "TOP", 0, 20)
	end

	local frameFlash = getglobal(self:GetName().."Flash")
	if (frameFlash) then
		frameFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small")
		frameFlash:SetWidth(156)
		frameFlash:SetHeight(49)
		frameFlash:ClearAllPoints()
		frameFlash:SetPoint("TOP", self, "TOP", 0, 20)
	end
end

function SmartParty_Spellbar_OnShow(self)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", getglobal("PartyMemberFrame"..self:GetParent():GetID().."Name"), "TOPLEFT", 0, 0);
	--[[
	if (UnitIsConnected(self.unit) and UnitExists("partypet"..self:GetParent():GetID()) and SHOW_PARTY_PETS == "1") then
		self:SetPoint("BOTTOM", self:GetParent(), "BOTTOM", 8, -34);
	else
		self:SetPoint("BOTTOM", self:GetParent(), "BOTTOM", 8, -8);
	end
	]]
end

function SmartParty_Spellbar_OnEvent(self, event, ...)
	local arg1 = ...;

	if SMART_PARTY_Config.castingbar then
		if (event == "CVAR_UPDATE") then
			if (self.casting or self.channeling) then
				self:Show()
			else
				self:Hide()
			end
			return
		elseif (event == "PARTY_MEMBERS_CHANGED") or
			   (event == "PARTY_MEMBER_ENABLE") or
			   (event == "PARTY_MEMBER_DISABLE") or
			   (event == "PARTY_LEADER_CHANGED") then
			-- check if the new target is casting a spell
			local nameChannel = UnitChannelInfo(self:GetParent():GetParent().unit)
			local nameSpell = UnitCastingInfo(self:GetParent():GetParent().unit)

			if (nameChannel) then
				event = "UNIT_SPELLCAST_CHANNEL_START"
				arg1 = "party"..self:GetID()
			elseif (nameSpell) then
				event = "UNIT_SPELLCAST_START"
				arg1 = "party"..self:GetID()
			else
				self.casting = nil
				self.channeling = nil
				self:SetMinMaxValues(0, 0)
				self:SetValue(0)
				self:Hide()
				return
			end
		end

		CastingBarFrame_OnEvent(self, event, arg1, select(2, ...))
	else
		self:Hide()
	end
end

------------------------------------------------------------------------------------
-- Pet Frame
------------------------------------------------------------------------------------
function SmartPartyPet_OnLoad(self)
	-- Get Blizzard Party Pet Frame
	local blizFrame = self:GetParent()

	blizFrame:SetMovable(true)
	blizFrame:SetHitRectInsets(0, 8, 3, 3)

	-- Set SmartPartyFrameXPetFrameHealthBarText to Blizzard Party Pet Frame for later use..
	blizFrame.HealthText = getglobal("SmartPartyFrame"..self:GetID().."PetFrameHealthBarText")

	local f

	f = getglobal(blizFrame:GetName().."HealthBar")
	f.OnValueChangedFunc = f:GetScript("OnValueChanged")

	f:SetScript("OnValueChanged", function(self)
		if (self.OnValueChangedFunc) then
			self.OnValueChangedFunc(self)
		end

		SmartPartyPet_HealthUpdate(self:GetParent())
	end)

	f:SetHitRectInsets(0, f:GetWidth(), 0, f:GetWidth())

	self.blizFrame = blizFrame
end

function SmartPartyPet_HealthUpdate(self)
	if SMART_PARTY_Config.statusbartext and UnitExists(self.unit) then
		if SMART_PARTY_Config.percent then
			SMART_HealthPercent(self.HealthText, self.unit)
		else
			SMART_HealthUpdate(self.HealthText, self.unit)
		end
	else
		self.HealthText:Hide()
	end
end

--
-- □ □□□□ □□ □ □□□□ □□□ □ □ □□.
-- Taint □□□ □□ □□□ RegisterUnitWatch□ □□□□.
--
SmartPartyDummyFrame = CreateFrame("Frame")
SmartPartyDummyFrame:Hide()
SmartPartyDummyFrame:RegisterEvent("VARIABLES_LOADED")
SmartPartyDummyFrame:RegisterEvent("CVAR_UPDATE")
SmartPartyDummyFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

SmartPartyPet_UpdateQueued = false

SmartPartyDummyFrame:SetScript("OnEvent", function(self, event, ...)
	if (event == "VARIABLES_LOADED") then
		PartyMemberFrame_UpdatePet = __PartyMemberFrame_UpdatePet
		PartyMemberFrame_UpdateOnlineStatus = __PartyMemberFrame_UpdateOnlineStatus

		local showPartyPets = GetCVar("showPartyPets") == "1";

		for id=1, MAX_PARTY_MEMBERS do
			local petFrame = getglobal("PartyMemberFrame"..id.."PetFrame")

			if showPartyPets then
				RegisterUnitWatch(petFrame)
			else
				UnregisterUnitWatch(petFrame)
			end

			PartyMemberFrame_UpdatePet(getglobal("PartyMemberFrame"..id), id);
		end
	elseif (event == "CVAR_UPDATE") then
		if arg1 == "SHOW_PARTY_PETS_TEXT" then
			local showPartyPets = GetCVar("showPartyPets") == "1";

			for id=1, MAX_PARTY_MEMBERS do
				local petFrame = getglobal("PartyMemberFrame"..id.."PetFrame")

				if showPartyPets then
					RegisterUnitWatch(petFrame)
				else
					UnregisterUnitWatch(petFrame)
				end

				PartyMemberFrame_UpdatePet(getglobal("PartyMemberFrame"..id), id);
			end
		end
	elseif (event == "PLAYER_REGEN_ENABLED") then
		if SmartPartyPet_UpdateQueued then
			for id=1, MAX_PARTY_MEMBERS do
				PartyMemberFrame_UpdatePet(getglobal("PartyMemberFrame"..id), id);
			end
			SmartPartyPet_UpdateQueued = false
		end
	end
end)

-- This function is from Blizzard FrameXML/PartyMemberFrame.lua
function __PartyMemberFrame_UpdatePet(self, id)
	if ( not id ) then
		id = self:GetID();
	end

	local frameName = "PartyMemberFrame"..id;
	local petFrame = getglobal(frameName.."PetFrame");

	if InCombatLockdown() then
		SmartPartyPet_UpdateQueued = true
	else
		if ( UnitIsConnected("party"..id) and UnitExists("partypet"..id) and SHOW_PARTY_PETS == "1" ) then
			petFrame:Show();
			petFrame:SetPoint("TOPLEFT", frameName, "TOPLEFT", 23, -56); -- changed y for SUF
		else
			petFrame:Hide();
			petFrame:SetPoint("TOPLEFT", frameName, "TOPLEFT", 23, -40); -- changed y for SUF
		end
	end

	petFrame.portraitType = UnitVehicleSkin("party"..id);

	PartyMemberFrame_RefreshPetDebuffs(self, id);
	UpdatePartyMemberBackground();

	SmartPartyPet_HealthUpdate(petFrame);
end

-- This function is from Blizzard FrameXML/PartyMemberFrame.lua
function __PartyMemberFrame_UpdateOnlineStatus(self)
	if ( not UnitIsConnected("party"..self:GetID()) ) then
		-- Handle disconnected state
		local selfName = self:GetName();
		local healthBar = _G[selfName.."HealthBar"];
		local unitHPMin, unitHPMax = healthBar:GetMinMaxValues();

		healthBar:SetValue(unitHPMax);
		healthBar:SetStatusBarColor(0.5, 0.5, 0.5);
		SetDesaturation(getglobal(selfName.."Portrait"), 1);
		getglobal(selfName.."Disconnect"):Show();

		-- change start
		if InCombatLockdown() then
			SmartPartyPet_UpdateQueued = true
		else
			getglobal(selfName.."PetFrame"):Hide();
		end
		-- change end

		return;
	else
		local selfName = self:GetName();
		SetDesaturation(getglobal(selfName.."Portrait"), nil);
		getglobal(selfName.."Disconnect"):Hide();
	end
end
