--------------------------------------------
--
-- SMART - TARGET
--
--------------------------------------------
SMART_TARGET_ENABLE = true

SMART_TARGET_Config = {  --fishuiedit
	statusbartext=true,
	statusbarmana=true,
	statusbarloss=false,
	percent=true,
	percenttoloss=false,
	percentmana=true,
	indicator=false,
	ecastbarfixed=false,
	infomation=true,
	showauracooldown=true,
	selfauracooldown=true,
	groupinfo=true,
	classinfo=true,
	aggroinfo=true,
	aggrosound=false,
	groupicon=true,
	movable=true,
	healthtopercent=false,
	statusbarshorten=false,
	shortenvalue=false
};

function SmartTarget_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTER_COMBAT")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_COMBAT")
	self:RegisterEvent("UNIT_TARGET")

	-- Health
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH")

	-- Powers
	self:RegisterEvent("UNIT_MANA")
	self:RegisterEvent("UNIT_RAGE")
	self:RegisterEvent("UNIT_FOCUS")
	self:RegisterEvent("UNIT_ENERGY")
	self:RegisterEvent("UNIT_RUNIC_POWER")

	self:RegisterEvent("UNIT_MAXMANA")
	self:RegisterEvent("UNIT_MAXRAGE")
	self:RegisterEvent("UNIT_MAXFOCUS")
	self:RegisterEvent("UNIT_MAXENERGY")
	self:RegisterEvent("UNIT_DISPLAYPOWER")
	self:RegisterEvent("UNIT_MAXRUNIC_POWER")
	self:RegisterEvent("UNIT_HAPPINESS")

	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	TargetFrame:SetMovable(true)
	--TargetFrame:SetResizable(true)

	local thisName = self:GetName();
	self.deadText = _G[thisName.."TextureFrameDeadText"];

	TargetFrameTextureFrame:CreateTexture("TargetStatusTexture","OVERLAY")
	TargetStatusTexture:SetWidth(64)
	TargetStatusTexture:SetHeight(64)
	TargetStatusTexture:SetPoint("CENTER",TargetFrame.portrait,"CENTER",0,0)
	TargetStatusTexture:SetTexture("Interface\\AddOns\\SmartUnitFrame\\CircleFlash.tga")
	--TargetStatusTexture:SetTexCoordModifiesRect(false)
	TargetStatusTexture:SetTexCoord(0,1,0,1)
	TargetStatusTexture:SetBlendMode("ADD")
	TargetStatusTexture:SetVertexColor(1,0.5,0)

	TargetFrameTextureFrame:CreateTexture("TargetStatusTextureNameFlash","OVERLAY")
	TargetStatusTextureNameFlash:SetPoint("TOPLEFT",TargetFrameNameBackground,"TOPLEFT",2,-2)
	TargetStatusTextureNameFlash:SetPoint("BOTTOMRIGHT",TargetFrameNameBackground,"BOTTOMRIGHT",-2,2)
	TargetStatusTextureNameFlash:SetTexture("Interface\\AddOns\\SmartUnitFrame\\NameFlash.tga")
	--TargetStatusTextureNameFlash:SetTexCoordModifiesRect(false)
	TargetStatusTextureNameFlash:SetTexCoord(0,1,0,1)
	TargetStatusTextureNameFlash:SetBlendMode("ADD")
	TargetStatusTextureNameFlash:SetVertexColor(1,0.5,0)

	self.statusCounter = 0
	self.statusSign = -1
	self.affectingcombat = false

	self.playerclass = nil

	Old_Target_Spellbar_AdjustPosition = Target_Spellbar_AdjustPosition
	Target_Spellbar_AdjustPosition = SmartTarget_Spellbar_AdjustPosition

	TargetFrame:SetHitRectInsets(0,36,6,22)
	TargetFrameHealthBar:SetHitRectInsets(0, TargetFrameHealthBar:GetWidth(), 0, TargetFrameHealthBar:GetHeight())
	TargetFrameManaBar:SetHitRectInsets(0, TargetFrameManaBar:GetWidth(), 0 ,TargetFrameManaBar:GetHeight())

	ComboFrame:ClearAllPoints()
	ComboFrame:SetPoint("TOPRIGHT",TargetFrame,"TOPRIGHT",-44,-9)

	for i=1, 5 do
		getglobal("ComboPoint"..i):SetWidth(12)
		getglobal("ComboPoint"..i):SetHeight(12)
		getglobal("ComboPoint"..i):ClearAllPoints()
	end

	ComboPoint1:SetPoint("TOPRIGHT",ComboFrame,"TOPRIGHT",0,0)
	ComboPoint2:SetPoint("TOP",ComboPoint1,"BOTTOM",7,4)
	ComboPoint3:SetPoint("TOP",ComboPoint2,"BOTTOM",5,2)
	ComboPoint4:SetPoint("TOP",ComboPoint3,"BOTTOM",2,1)
	ComboPoint5:SetPoint("TOP",ComboPoint4,"BOTTOM",0,1)

	RegisterUnitWatch(TargetFrame)
	self.spellbarAnchor = nil
	TargetFrameSpellBar:SetWidth(138)
	TargetFrameSpellBarBorder:SetWidth(185)
	TargetFrameSpellBarBorderShield:SetWidth(185)
	TargetFrameSpellBarFlash:SetWidth(185)
	TargetFrameSpellBar:SetFrameStrata("MEDIUM")
	TargetFrameSpellBar:SetToplevel(true)

	TargetFrameSpellBar:SetScript("OnShow", function() SmartTarget_Spellbar_AdjustPosition(TargetFrameSpellBar); end)
end

local NUM_TOT_AURA_ROWS = 2; -- from FrameXML/TargetFrame.lua

function SmartTarget_Spellbar_AdjustPosition(self)
	if SMART_TARGET_Config.ecastbarfixed then
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", "TargetFrame", "TOPLEFT", 8, -18)
	else
		self:ClearAllPoints()
		local parentFrame = self:GetParent();
		if ( parentFrame.haveToT ) then
			if ( parentFrame.auraRows <= 1 ) then
				self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -21 );
			else
				self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
			end
		elseif ( parentFrame.haveElite ) then
			if ( parentFrame.auraRows <= 1 ) then
				self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -5 );
			else
				self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
			end
		else
			if ( parentFrame.auraRows > 0 ) then
				self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
			else
				self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, 7 );
			end
		end
	end
end

function SmartTarget_ResetPosition()
	TargetFrame:ClearAllPoints()
	if SMART_TARGET_Config.percent then
		if SMART_PLAYER_Config.percent then
			TargetFrame:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 295, 0)
		else
			TargetFrame:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 265, 0)
		end
	else
		TargetFrame:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 265, 0)
	end
	TargetFrame:SetUserPlaced(false)
end

function SmartTarget_OnEvent(self, event)
	if (event == "VARIABLES_LOADED") then
		if not TargetFrame:IsUserPlaced() then
			SmartTarget_ResetPosition()
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		self.playerclass = UnitClass("player")
	end

	if UnitExists("target") then
		if (event == "PLAYER_TARGET_CHANGED") then
			TargetFrameAggroIndicator.alert = false
			SmartTarget_HealthUpdate(self)
			SmartTarget_ManaUpdate(self)
			SmartTarget_ClassIndicator()
			SmartTarget_GroupIndicator()
			SmartTarget_AggroIndicator(self)
		elseif (event == "UNIT_TARGET") or (event == "UNIT_COMBAT") then
			if (arg1 == "target") then
				SmartTarget_AggroIndicator(self)
			end
		elseif (event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_REGEN_DISABLED") or (event == "PLAYER_ENTER_COMBAT") or (event == "PLAYER_LEAVE_COMBAT") then
			if UnitExists("target") then
				SmartTarget_AggroIndicator(self)
			end
		elseif (event == "UNIT_HEALTH") or (event == "UNIT_MAXHEALTH") then
			if (arg1 == "target") then
				SmartTarget_HealthUpdate(self)
			end
		elseif (event == "UNIT_MANA") or
			(event == "UNIT_RAGE") or
			(event == "UNIT_FOCUS") or
			(event == "UNIT_ENERGY") or
			(event == "UNIT_RUNIC_POWER") or
			(event == "UNIT_MAXMANA") or
			(event == "UNIT_MAXRAGE") or
			(event == "UNIT_MAXFOCUS") or
			(event == "UNIT_MAXENERGY") or
			(event == "UNIT_DISPLAYPOWER") or
			(event == "UNIT_MAXRUNIC_POWER") or
			(event == "UNIT_HAPPINESS") then
			if (arg1 == "target") then
				SmartTarget_ManaUpdate(self)
			end
		elseif (event == "RAID_ROSTER_UPDATE") then
			SmartTarget_GroupIndicator()
		end
	end
end

local classColor = { r=1, g=1, b=1 }

function SmartTarget_ClassIndicator()
	if SMART_TARGET_Config.infomation and SMART_TARGET_Config.classinfo then
		classColor.r = 1
		classColor.g = 1
		classColor.b = 1

		local targetClass, englishClass = UnitClass("target")

		if targetClass and UnitIsPlayer("target") then
			TargetFrameClassIndicatorText:SetText(targetClass)

			if englishClass then
				classColor.r = RAID_CLASS_COLORS[englishClass].r
				classColor.g = RAID_CLASS_COLORS[englishClass].g
				classColor.b = RAID_CLASS_COLORS[englishClass].b
			end

			TargetFrameClassIndicator:Show()
		else
			if UnitCreatureType("target") then
				TargetFrameClassIndicatorText:SetText(UnitCreatureType("target"))
				TargetFrameClassIndicator:Show()
			else
				TargetFrameClassIndicator:Hide()
			end

			if not UnitIsFriend("target","player") then
				classColor.r = 1
				classColor.g = 0.5
				classColor.b = 0
			end
		end

		TargetFrameClassIndicatorText:SetTextColor(classColor.r, classColor.g, classColor.b)
	else
		TargetFrameClassIndicator:Hide()
	end
end

local groupColor = { r=1, g=1, b=1 }

function SmartTarget_GroupIndicator()
	if SMART_TARGET_Config.infomation and SMART_TARGET_Config.groupinfo and UnitIsPlayer("target") then
		groupColor.r = 1
		groupColor.g = 1
		groupColor.b = 1

		if UnitInRaid("target") then
			local i

			for i=1, GetNumRaidMembers() do
				local name, _, subgroup, _, _, _, _, _, _ = GetRaidRosterInfo(i)

				if UnitIsUnit("raid"..i, "target") then
					TargetFrameGroupIndicatorText:SetText(GROUPS.." "..subgroup)
					break
				end
			end
		else
			local unitRace = UnitRace("target")

			if unitRace == "夜精靈" then
				unitRace = "夜精靈"
			end

			if unitRace == "血精靈" then
				unitRace = "血精靈"
			end

			TargetFrameGroupIndicatorText:SetText(unitRace)

			if not UnitIsFriend("target", "player") then
				groupColor.r = 1
				groupColor.g = 0.5
				groupColor.b = 0
			end
		end

		TargetFrameGroupIndicatorText:SetTextColor(groupColor.r, groupColor.g, groupColor.b)
		TargetFrameGroupIndicator:Show()
	else
		TargetFrameGroupIndicator:Hide()
	end
end

function SmartTarget_AggroIndicator(self)
	if SMART_TARGET_Config.infomation and SMART_TARGET_Config.aggroinfo and UnitIsEnemy("player","target") then
		if UnitAffectingCombat("target") then
			if TargetFrameGroupIndicator:IsShown() then
				TargetFrameAggroIndicator:ClearAllPoints()
				TargetFrameAggroIndicator:SetPoint("RIGHT",TargetFrameGroupIndicator,"LEFT",8,0)
			else
				TargetFrameAggroIndicator:ClearAllPoints()
				TargetFrameAggroIndicator:SetPoint("RIGHT",TargetFrameClassIndicator,"LEFT",8,0)
			end
			TargetFrameAggroIndicator:Show()

			if UnitIsUnit("player","targettarget") then
				if UnitIsTrivial("target") then
					TargetFrameAggroIndicatorText:SetText("FIGHT!!!")
					TargetFrameAggroIndicatorText:SetTextColor(1,0.5,0)
					if SMART_TARGET_Config.aggrosound and (not TargetFrameAggroIndicator.alert) then
						PlaySoundFile("Interface\\AddOns\\SmartUnitFrame\\Sound\\AggroSound_Duel.wav")
						TargetFrameAggroIndicator.alert = true
					end
				elseif (self.playerclass == "戰士") then
					TargetFrameAggroIndicatorText:SetText("FIGHT!!!")
					TargetFrameAggroIndicatorText:SetTextColor(1,0,0)
					if SMART_TARGET_Config.aggrosound and (not TargetFrameAggroIndicator.alert) then
						PlaySoundFile("Interface\\AddOns\\SmartUnitFrame\\Sound\\AggroSound_Duel.wav")
						TargetFrameAggroIndicator.alert = true
					end
				else
					TargetFrameAggroIndicatorText:SetText("危險!!!")
					TargetFrameAggroIndicatorText:SetTextColor(1,0,0)
					if SMART_TARGET_Config.aggrosound and (not TargetFrameAggroIndicator.alert) then
						PlaySoundFile("Interface\\AddOns\\SmartUnitFrame\\Sound\\AggroSound_Ding.wav")
						TargetFrameAggroIndicator.alert = true
					end
				end
			elseif UnitInParty("targettarget") or UnitInRaid("targettarget") or UnitIsUnit("pet","targettarget") then
				TargetFrameAggroIndicator.alert = false
				if (UnitClass("targettarget") == "戰士") and (not UnitIsUnit("pet","targettarget")) then
					TargetFrameAggroIndicatorText:SetText("安全")
					TargetFrameAggroIndicatorText:SetTextColor(1,0.82,0)
				else
					TargetFrameAggroIndicatorText:SetText("注意!!")
					TargetFrameAggroIndicatorText:SetTextColor(1,0.5,0)
				end
			else
				TargetFrameAggroIndicator.alert = false
				TargetFrameAggroIndicatorText:SetText("戰鬥!!")
				TargetFrameAggroIndicatorText:SetTextColor(1,0.5,0)
			end
		else
			TargetFrameAggroIndicator.alert = false
			TargetFrameAggroIndicator:Hide()
		end
	else
		TargetFrameAggroIndicator.alert = false
		TargetFrameAggroIndicator:Hide()
	end
end

function SmartTarget_OnUpdate(self, elapsed)
	local unit = TargetFrame.unit
	if not UnitExists(unit) then return end

	if UnitAffectingCombat(unit) then
		if not TargetStatusTexture:IsShown() then
			TargetStatusTexture:Show()
		end
		if not TargetStatusTextureNameFlash:IsShown() then
			TargetStatusTextureNameFlash:Show()
		end
		local alpha = 255
		local counter = self.statusCounter + elapsed
		local sign    = self.statusSign

		if ( counter > 0.5 ) then
			sign = -sign
			self.statusSign = sign
		end
		counter = mod(counter, 0.5)
		self.statusCounter = counter

		if ( sign == 1 ) then
			alpha = (55  + (counter * 400)) / 255
		else
			alpha = (255 - (counter * 400)) / 255
		end
		TargetStatusTexture:SetAlpha(alpha)
		TargetStatusTextureNameFlash:SetAlpha(alpha)
	else
		if TargetStatusTexture:IsShown() then
			TargetStatusTexture:Hide()
		end

		if TargetStatusTextureNameFlash:IsShown() then
			TargetStatusTextureNameFlash:Hide()
		end
	end

	if (SMART_TOT_Config.enable and SMART_TOT_Config.WoWToTOnOff and SmartToTFrame:IsShown()) ~= UnitExists("targettarget") then
		SmartToT_Update(SmartToTFrame)
	end
end

function SmartTarget_HealthUpdate(self)
	local unit = self:GetParent().unit;
	local TargetDeadText = TargetFrame.deadText

	if UnitIsConnected(unit) then
		if (UnitIsDead(unit)) then
			TargetFrameHealthBar:Hide()
			SmartTargetHealthBarText:Hide()
			if SMART_CheckFeign(unit) then
				TargetDeadText:SetText("假死")
			else
				TargetDeadText:SetText("死亡")
			end
			TargetDeadText:Show()
		elseif (UnitIsGhost(unit)) then
			TargetFrameHealthBar:Hide()
			SmartTargetHealthBarText:Hide()
			TargetDeadText:SetText("幽靈")
			TargetDeadText:Show()
		else
			TargetDeadText:Hide()
			TargetFrameHealthBar:Show()

			if SMART_TARGET_Config.statusbartext then
				if SMART_TARGET_Config.statusbarloss then
					SMART_HealthLoss(SmartTargetHealthBarText, unit, SMART_TARGET_Config.shortenvalue)
				elseif SMART_TARGET_Config.healthtopercent then
					SMART_OldStyleHealthUpdate(SmartTargetHealthBarText, unit)
				else
					SMART_HealthUpdate(SmartTargetHealthBarText, unit, SMART_TARGET_Config.shortenvalue)
				end
			else
				SmartTargetHealthBarText:Hide()
			end
		end
	else
		TargetFrameHealthBar:Hide()
		SmartTargetHealthBarText:Hide()
		TargetDeadText:SetText("離線")
		TargetDeadText:Show()
	end

	if SMART_TARGET_Config.percent then
		if SMART_TARGET_Config.percenttoloss then
			SMART_HealthLoss(SmartTargetHealthPercent, unit, SMART_TARGET_Config.shortenvalue)
		else
			SMART_HealthPercent(SmartTargetHealthPercent, unit)
		end
	else
		SmartTargetHealthPercent:Hide()
	end
end

function SmartTarget_ManaUpdate(self)
	local unit = self:GetParent().unit;

	if SMART_TARGET_Config.statusbartext and SMART_TARGET_Config.statusbarmana then
		SMART_ManaUpdate(SmartTargetManaBarText, unit, SMART_TARGET_Config.shortenvalue)
	else
		SmartTargetManaBarText:Hide()
	end

	if SMART_TARGET_Config.percent and SMART_TARGET_Config.percentmana then
		SMART_ManaPercent(SmartTargetManaPercent, unit)
	else
		SmartTargetManaPercent:Hide()
	end
end

function SmartTargetHitIndicator_OnEvent(self, event)
	if SMART_TARGET_Config.indicator then
		if (event == "PLAYER_TARGET_CHANGED") then
			SmartTargetHitIndicator:Hide()
			return
		end

		if (event == "UNIT_COMBAT") and (arg1 == "target") then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5)
			return
		end
	end
end

function SmartTargetHitIndicator_OnUpdate(self, elapsed)
	if SMART_TARGET_Config.indicator then
		CombatFeedback_OnUpdate(self, elapsed)
	end
end

