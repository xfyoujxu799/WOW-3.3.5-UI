--------------------------------------------
--
-- SMART - ToT, ToTT
--
--------------------------------------------
SMART_TOT_ENABLE = true;

SMART_TOT_Config = { --fishuiedit
	enable=true,
	statusbartext=true,
	loss=false,
	losstopercent=false,
	percent=true,
	tott=true,
	movable=true,
	WoWToTOnOff=false,
	raid=true,
	buff=false,
	debuff=true,
	buffswap=false,
	ChkBuff=16,
	MaxBuff=16,
	ChkDebuff=16,
	MaxDebuff=16
};

local StartFrame = CreateFrame("Frame")

StartFrame:RegisterEvent("VARIABLES_LOADED")

StartFrame:SetScript("OnLoad", function(self)
	SlashCmdList["STARGETTARGET"] = SmartToT_CommandHandler;
	SLASH_STARGETTARGET1 = "/stot";

	-- Hide Bliz Frame
	UnregisterUnitWatch(TargetFrameToT);
	TargetFrameToT:SetAlpha(0);
	TargetFrameToT:Hide();
end);

StartFrame:SetScript("OnEvent", function(self)
	SmartToT_CheckWoWToTOnOff();
	SmartToT_AuraLayout();
	SmartToT_AuraInitialize();
end);

function SmartToT_CheckWoWToTOnOff()
	if SMART_TOT_Config.WoWToTOnOff then
		SmartToT_ResetPosition()
	end
end

function SmartToT_ResetPosition()
	SmartToTFrame:ClearAllPoints();

	if SMART_TOT_Config.WoWToTOnOff then
		SmartToTFrame:SetPoint("BOTTOMRIGHT", "TargetFrame", "BOTTOMRIGHT", -8, -18);
		SmartToTFrame:SetUserPlaced(false);
	else
		SmartToTFrame:SetPoint("LEFT", "TargetFrame", "RIGHT", 0, 0);
		SmartToTFrame:SetUserPlaced(true);
	end

	SmartToTTFrame:ClearAllPoints();
	SmartToTTFrame:SetPoint("TOPLEFT", SmartToTFrame, "BOTTOMLEFT", 0, -10);
	SmartToTTFrame:SetUserPlaced(false);
end

function SmartToT_AuraInitialize()
	-- BUFF initial
	if SMART_TOT_Config.ChkBuff < SMART_TOT_Config.MaxBuff then
		for i = (SMART_TOT_Config.ChkBuff+1), SMART_TOT_Config.MaxBuff do
			getglobal("SmartToTFrameBuff"..i):Hide();
			getglobal("SmartToTTFrameBuff"..i):Hide();
		end
	end

	-- DEBUFF initial
	if SMART_TOT_Config.ChkDebuff < SMART_TOT_Config.MaxDebuff then
		for i = (SMART_TOT_Config.ChkDebuff+1), SMART_TOT_Config.MaxDebuff do
			getglobal("SmartToTFrameDebuff"..i):Hide();
			getglobal("SmartToTTFrameDebuff"..i):Hide();
		end
	end
end

function SmartToT_AuraLayout()
	if SMART_TOT_Config.buffswap then
		SmartToTFrameDebuff1:ClearAllPoints();
		SmartToTFrameDebuff1:SetPoint("BOTTOMLEFT", "SmartToTFrame", "BOTTOMLEFT", 50, -15);

		SmartToTFrameDebuff9:ClearAllPoints();
		SmartToTFrameDebuff9:SetPoint("LEFT", "SmartToTFrameDebuff8", "RIGHT", 2, 0);

		if SMART_TOT_Config.statusbartext then
			SmartToTFrameBuff1:ClearAllPoints();
			SmartToTFrameBuff1:SetPoint("LEFT", "SmartToTFrame", "LEFT", 162, 0);
		else
			SmartToTFrameBuff1:ClearAllPoints();
			SmartToTFrameBuff1:SetPoint("LEFT", "SmartToTFrame", "LEFT", 100, 0);
		end

		SmartToTFrameBuff9:ClearAllPoints();
		SmartToTFrameBuff9:SetPoint("TOPLEFT", "SmartToTFrameBuff1", "BOTTOMLEFT", 0, -2);

		SmartToTTFrameDebuff1:ClearAllPoints();
		SmartToTTFrameDebuff1:SetPoint("BOTTOMLEFT", "SmartToTTFrame", "BOTTOMLEFT", 50, -15);

		SmartToTTFrameDebuff9:ClearAllPoints();
		SmartToTTFrameDebuff9:SetPoint("LEFT", "SmartToTTFrameDebuff8", "RIGHT", 2, 0);

		if SMART_TOT_Config.statusbartext then
			SmartToTTFrameBuff1:ClearAllPoints();
			SmartToTTFrameBuff1:SetPoint("LEFT", "SmartToTTFrame", "LEFT", 162, 0);
		else
			SmartToTTFrameBuff1:ClearAllPoints();
			SmartToTTFrameBuff1:SetPoint("LEFT", "SmartToTTFrame", "LEFT", 100, 0);
		end

		SmartToTTFrameBuff9:ClearAllPoints();
		SmartToTTFrameBuff9:SetPoint("TOPLEFT", "SmartToTTFrameBuff1", "BOTTOMLEFT", 0, -2);
	else
		SmartToTFrameBuff1:ClearAllPoints();
		SmartToTFrameBuff1:SetPoint("BOTTOMLEFT", "SmartToTFrame", "BOTTOMLEFT", 50, -15);

		SmartToTFrameBuff9:ClearAllPoints();
		SmartToTFrameBuff9:SetPoint("LEFT", "SmartToTFrameBuff8", "RIGHT", 2, 0);

		if SMART_TOT_Config.statusbartext then
			SmartToTFrameDebuff1:ClearAllPoints();
			SmartToTFrameDebuff1:SetPoint("LEFT", "SmartToTFrame", "LEFT", 162, 0);
		else
			SmartToTFrameDebuff1:ClearAllPoints();
			SmartToTFrameDebuff1:SetPoint("LEFT", "SmartToTFrame", "LEFT", 100, 0);
		end

		SmartToTFrameDebuff9:ClearAllPoints();
		SmartToTFrameDebuff9:SetPoint("TOPLEFT", "SmartToTFrameDebuff1", "BOTTOMLEFT", 0, -2);

		SmartToTTFrameBuff1:ClearAllPoints();
		SmartToTTFrameBuff1:SetPoint("BOTTOMLEFT", "SmartToTTFrame", "BOTTOMLEFT", 50, -15);

		SmartToTTFrameBuff9:ClearAllPoints();
		SmartToTTFrameBuff9:SetPoint("LEFT", "SmartToTTFrameBuff8", "RIGHT", 2, 0);

		if SMART_TOT_Config.statusbartext then
			SmartToTTFrameDebuff1:ClearAllPoints();
			SmartToTTFrameDebuff1:SetPoint("LEFT", "SmartToTTFrame", "LEFT", 162, 0);
		else
			SmartToTTFrameDebuff1:ClearAllPoints();
			SmartToTTFrameDebuff1:SetPoint("LEFT", "SmartToTTFrame", "LEFT", 100, 0);
		end

		SmartToTTFrameDebuff9:ClearAllPoints();
		SmartToTTFrameDebuff9:SetPoint("TOPLEFT", "SmartToTTFrameDebuff1", "BOTTOMLEFT", 0, -2);
	end
end

function SmartToT_RefreshDebuffs(self, chkBuff, chkDebuff)
	local smartUnit = self.unit;

	-- Buff Refresh Check
	local idxBuff = 0;

	if SMART_TOT_Config.buff and (chkBuff > 0) then
		local buffImage, buffButton, buffIcon, buffCount, buffStack;
		for i=1, chkBuff do
			_, _, buffImage, buffStack = UnitBuff(smartUnit, i);
			if ( buffImage ) then
				idxBuff = idxBuff + 1;
				buffButton = getglobal(self:GetName().."Buff"..idxBuff);
				buffIcon = getglobal(self:GetName().."Buff"..idxBuff.."Icon");
				buffCount = getglobal(self:GetName().."Buff"..idxBuff.."Count");
				buffIcon:SetTexture(buffImage);
				buffButton:SetID(idxBuff);
				buffButton:Show();
				if ( buffStack > 1 ) then
					buffCount:SetText(buffStack);
					buffCount:Show();
				else
					buffCount:Hide();
				end
			else
				break;
			end
		end
	end

	if idxBuff < self.numbuffs then
		for i = (idxBuff+1), self.numbuffs do
			getglobal(self:GetName().."Buff"..i):Hide();
		end
	end

	self.numbuffs = idxBuff;

	-- Debuff Refresh Check
	local idxDebuff = 0;

	if SMART_TOT_Config.debuff and (chkDebuff > 0)  then
		local debuffImage, debuffStack, debuffType;
		local debuffButton, debuffIcon, debuffBorder, debuffCount, debuffColor;
		for i=1, chkDebuff do
			_, _, debuffImage, debuffStack, debuffType, _, _ = UnitDebuff(smartUnit, i);
			if ( debuffImage ) then
				idxDebuff = idxDebuff + 1;
				debuffButton = getglobal(self:GetName().."Debuff"..idxDebuff);
				debuffIcon = getglobal(self:GetName().."Debuff"..idxDebuff.."Icon");
				debuffBorder = getglobal(self:GetName().."Debuff"..idxDebuff.."Border");
				debuffCount = getglobal(self:GetName().."Debuff"..idxDebuff.."Count");
				if ( debuffType ) then
					debuffColor = DebuffTypeColor[debuffType];
				else
					debuffColor = DebuffTypeColor["none"];
				end
				debuffBorder:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b);
				if ( debuffStack > 1 ) then
					debuffCount:SetText(debuffStack);
					debuffCount:Show();
				else
					debuffCount:Hide();
				end
				debuffIcon:SetTexture(debuffImage);
				debuffButton:SetAlpha(1);
				debuffButton:SetID(idxDebuff);
				debuffButton:Show();
			else
				break;
			end
		end
	end
	if idxDebuff < self.numdebuffs then
		for i = (idxDebuff+1), self.numdebuffs do
			getglobal(self:GetName().."Debuff"..i):Hide();
		end
	end
	self.numdebuffs = idxDebuff;
end

function SmartToT_HealthUpdate(self)
	if SMART_TOT_Config.statusbartext then
		if SMART_TOT_Config.percent then
			self.healthtext:Hide();
			SMART_HealthPercent(self.healthpercent, self.unit);
		else
			self.healthpercent:Hide();
			SMART_HealthUpdate(self.healthtext, self.unit, true);
		end
	else
		self.healthtext:Hide();
		self.healthpercent:Hide();
	end

	if SMART_TOT_Config.loss then
		if SMART_TOT_Config.losstopercent then
			SMART_HealthPercent(self.healthloss, self.unit);
		else
			SMART_HealthLoss(self.healthloss, self.unit, true);
		end
	else
		self.healthloss:Hide();
	end
end

function SmartToT_ManaUpdate(self)
	if SMART_TOT_Config.statusbartext then
		if SMART_TOT_Config.percent then
			self.manatext:Hide();
			SMART_ManaPercent(self.manapercent, self.unit);
		else
			self.manapercent:Hide();
			SMART_ManaUpdate(self.manatext, self.unit, 100000);
		end
	else
		self.manatext:Hide();
		self.manapercent:Hide();
	end
end

function SmartToT_RaidTargetCheck(self)
	if SMART_TOT_Config.raid and UnitExists(self.unit) then
		SMART_RaidTargetCheck(self.raidtargeticon, self.unit);
	else
		self.raidtargeticon:Hide();
	end
end

function SmartToT_Update(self)
	local parent = self:GetParent()	-- i.e. TargetFrame
	if self.enable then
		if not UnitExists(self.unit) then
			self.currentUnitName = nil;
			parent.haveToT = nil
		else
			self.currentUnitName = UnitName(self.unit)

			UnitFrame_Update(self)

			SMART_ColorName(self.name, self.unit)
			SMART_ClassIcons(self.classicon, self.unit)
			SMART_CheckLevel(self.leveltext, self.unit)
			SMART_CheckElite(self.elitetext, self.unit)
			SMART_FactionGroupCheck(self.factiongroup, self.unit)

			SmartToT_RaidTargetCheck(self)
			SmartToT_SetStatusText(self)
			SmartToT_HealthUpdate(self)
			SmartToT_ManaUpdate(self)

			SmartToT_RefreshDebuffs(self, SMART_TOT_Config.ChkBuff, SMART_TOT_Config.ChkDebuff)
			if ( parent.spellbar ) then
				parent.haveToT = true
				SmartTarget_Spellbar_AdjustPosition(parent.spellbar)
			end
		end
	else
		parent.haveToT = nil
		SmartTarget_Spellbar_AdjustPosition(parent.spellbar)
	end
end

function SmartToT_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.25 then
		self.elapsed = 0;

		if UnitExists(self.unit) and self:IsVisible() then
			UnitFrameHealthBar_Update(self.healthbar, self.unit)
			UnitFrameManaBar_Update(self.manabar, self.unit)

			if (self.currentUnitName == nil) or (self.currentUnitName ~= UnitName(self.unit)) then
				self.currentUnitName = UnitName(self.unit)
				SetPortraitTexture(self.portrait, self.unit)
				SMART_ColorName(self.name, self.unit)
				SMART_ClassIcons(self.classicon, self.unit)
				SMART_CheckLevel(self.leveltext, self.unit)
				SMART_CheckElite(self.elitetext, self.unit)
				SMART_FactionGroupCheck(self.factiongroup, self.unit)
			end

			SmartToT_RaidTargetCheck(self)
			SmartToT_SetStatusText(self)
			SmartToT_HealthUpdate(self)
			SmartToT_ManaUpdate(self)

			SmartToT_RefreshDebuffs(self, SMART_TOT_Config.ChkBuff, SMART_TOT_Config.ChkDebuff)
		end
	end
end

function SmartToT_OnHide(self)
	self.currentUnitName = nil
	--CloseDropDownMenus()
end

function SmartToT_SetStatusText(self)
	local status

	if UnitIsConnected(self.unit) then
		if UnitIsDead(self.unit) then
			if SMART_CheckFeign(self.unit) then
				status = "假死"
			else
				status = "死亡"
			end
			self.portrait:SetVertexColor(0.35, 0.35, 0.35);
			self.statustext:SetText(status);
			self.statustext:Show();
		elseif UnitIsGhost(self.unit) then
			self.portrait:SetVertexColor(0.2, 0.2, 0.75);
			self.statustext:SetText("幽靈");
			self.statustext:Show();
		else
			SMART_PortraitColor(self.portrait, self.unit);
			self.statustext:Hide();
		end
	else
		if UnitIsDead(self.unit) then
			if SMART_CheckFeign(self.unit) then
				status = "假死"
			else
				status = "死亡"
			end
		else
			status = "離線"
		end

		self.portrait:SetVertexColor(0.35, 0.35, 0.35);
		self.statustext:SetText(status)
		self.statustext:Show();
	end
end

function SmartToT_HealthCheck(self, value)
	if (UnitIsPlayer(self.unit)) then
		local unitMinHP, unitMaxHP, unitCurrHP;
		unitHPMin, unitHPMax = self:GetMinMaxValues();
		unitCurrHP = value;
		self:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
	end
end

function SmartToT_StatusUpdate(self, elapsed)
	if UnitExists(self.unit) and self:IsVisible() then
		local alpha = 255;
		local counter = self.statusCounter + elapsed;
		local sign    = self.statusSign;

		if (counter > 0.5) then
			sign = -sign;
			self.statusSign = sign;
		end
		counter = mod(counter, 0.5);
		self.statusCounter = counter;

		if (sign == 1) then
			alpha = (127 + (counter * 256)) / 255;
		else
			alpha = (255 - (counter * 256)) / 255;
		end

		if UnitExists(self.unit) and UnitAffectingCombat(self.unit) then
			if not self.statusflash:IsShown() then
				self.statusflash:Show();
			end
			self.statusflash:SetAlpha(alpha);
		else
			if self.statusflash:IsShown() then
				self.statusflash:Hide();
			end
		end

		if UnitIsGhost("focus") or ( (self.unitHPPercent > 0) and (self.unitHPPercent < 0.2) ) then
			self.portrait:SetAlpha(alpha);
		else
			self.portrait:SetAlpha(1);
		end
	end
end

--------------------------------------------
--
-- Target of Target Funtions
--
--------------------------------------------
function SmartToTFrame_OnLoad(self)
	-- 블리자드 프레임 숨기기
	UnregisterUnitWatch(TargetFrameToT);
	TargetFrameToT:SetAlpha(0);
	TargetFrameToT:Hide();
	--
	self.timeleft = 0.25
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_TARGET");
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("RAID_TARGET_UPDATE");

	UnitFrame_Initialize(self, "targettarget", 
						SmartToTName, SmartToTPortrait,
						SmartToTHealthBar, SmartToTHealthText,
						SmartToTManaBar, SmartToTManaText, nil);

	self.raidtargeticon = SmartToTRaidTargetIcon;
	self.healthloss = SmartToTHealthLoss;
	self.healthtext = SmartToTHealthBarText;
	self.manatext = SmartToTManaBarText;
	self.healthpercent = SmartToTHealthPercent;
	self.manapercent = SmartToTManaPercent;
	self.factiongroup = SmartToTFactionGroupIcon;
	self.classicon = SmartToTClassIcon;
	self.leveltext = SmartToTLevelText;
	self.elitetext = SmartToTEliteText;
	self.statustext = SmartToTStatusText;

	self.currentUnitName = nil;
	
	self.numbuffs = 0;
	self.numdebuffs = 0;
	
	SmartToTTextureFrame:CreateTexture("SmartToTStatusTexture", "ARTWORK");
	SmartToTStatusTexture:SetTexture("Interface\\AddOns\\SmartUnitFrame\\CircleFlash.tga");
	SmartToTStatusTexture:SetWidth(self.portrait:GetWidth());
	SmartToTStatusTexture:SetHeight(self.portrait:GetHeight());
	--SmartToTStatusTexture:SetTexCoordModifiesRect(false);
	SmartToTStatusTexture:SetTexCoord(0,1,0,1);
	SmartToTStatusTexture:SetPoint("CENTER",self.portrait,"CENTER",0,0);
	SmartToTStatusTexture:SetBlendMode("ADD");
	SmartToTStatusTexture:SetVertexColor(1, 0.5, 0);

	self.statusflash = SmartToTStatusTexture;

	--self:SetFrameLevel(TargetFrame:GetFrameLevel()+2);
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal(self:GetName().."DropDown"), self:GetName(), 60, 10);
	end

	SecureUnitButton_OnLoad(self, "targettarget", showmenu);
end

function SmartToTFrameDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, SmartToTFrameDropDown_Initialize, "MENU");
end

function SmartToTFrameDropDown_Initialize(self)
	local menu;
	local name;
	local id = nil;
	if ( UnitIsUnit("targettarget", "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit("targettarget", "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer("targettarget") ) then
		id = UnitInRaid("targettarget");
		if ( id ) then
			menu = "RAID_PLAYER";
		elseif ( UnitInParty("targettarget") ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(self, menu, "targettarget", name, id);
	end
end

function SmartToTFrame_OnEvent(self, event, ...)
	local arg1 = ...;

	if (event == "VARIABLES_LOADED") then
		SmartToT_CheckWoWToTOnOff()
		SMART_RegisterUnitWatch(self, SMART_TOT_Config.enable)
	end

	if SMART_TOT_Config.enable then
		if (event == "PLAYER_TARGET_CHANGED") then
			SmartToT_Update(self);
		elseif (event == "UNIT_TARGET") then
			if (arg1 == "target") then
				SmartToT_Update(self);
			end
		end

		if UnitExists(self.unit) then
			if (event == "UNIT_NAME_UPDATE") or (event == "UNIT_CLASSIFICATION_CHANGED") or (event == "UNIT_LEVEL") then
				if (arg1 == self.unit) then
					SMART_ColorName(self.name, self.unit);
					SMART_CheckLevel(self.leveltext, self.unit);
					SMART_FactionGroupCheck(self.factiongroup, self.unit);
				end
			elseif (event == "UNIT_FACTION") then
				if (arg1 == self.unit) or (arg1 == "player")then
					SMART_ColorName(self.name, self.unit);
					SMART_CheckLevel(self.leveltext, self.unit);
					SMART_FactionGroupCheck(self.factiongroup, self.unit);
				end
			elseif (event == "UNIT_PORTRAIT_UPDATE") then
				SetPortraitTexture(self.portrait, self.unit);
			elseif (event == "RAID_TARGET_UPDATE") then
				SmartToT_RaidTargetCheck(self);
			end
		end
	end
end

--------------------------------------------
--
-- Target of Target's Target Funtions
--
--------------------------------------------
function SmartToTTFrame_OnLoad(self)
	self.unit = "targettargettarget"
	self.timeleft = 0.25
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_TARGET");
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("RAID_TARGET_UPDATE");

	UnitFrame_Initialize(self, self.unit, SmartToTTName, SmartToTTPortrait, SmartToTTHealthBar, SmartToTTHealthText, SmartToTTManaBar, SmartToTTManaText, nil);

	self.raidtargeticon = SmartToTTRaidTargetIcon;
	self.healthloss = SmartToTTHealthLoss;
	self.healthtext = SmartToTTHealthBarText;
	self.manatext = SmartToTTManaBarText;
	self.healthpercent = SmartToTTHealthPercent;
	self.manapercent = SmartToTTManaPercent;
	self.factiongroup = SmartToTTFactionGroupIcon;
	self.classicon = SmartToTTClassIcon;
	self.leveltext = SmartToTTLevelText;
	self.elitetext = SmartToTTEliteText;
	self.statustext = SmartToTTStatusText;

	self.currentUnitName = nil;

	self.numbuffs = 0;
	self.numdebuffs = 0;

	SmartToTTTextureFrame:CreateTexture("SmartToTTStatusTexture","ARTWORK");
	SmartToTTStatusTexture:SetTexture("Interface\\AddOns\\SmartUnitFrame\\CircleFlash.tga");
	SmartToTTStatusTexture:SetWidth(self.portrait:GetWidth());
	SmartToTTStatusTexture:SetHeight(self.portrait:GetHeight());
	--SmartToTTStatusTexture:SetTexCoordModifiesRect(false);
	SmartToTTStatusTexture:SetTexCoord(0,1,0,1);
	SmartToTTStatusTexture:SetPoint("CENTER",self.portrait,"CENTER",0,0);
	SmartToTTStatusTexture:SetBlendMode("ADD");
	SmartToTTStatusTexture:SetVertexColor(1, 0.5, 0);
	
	self.statusflash = SmartToTTStatusTexture;

	--self:SetFrameLevel(TargetFrame:GetFrameLevel()+2);
	
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal(self:GetName().."DropDown"), self:GetName(), 60, 10);
	end

	SecureUnitButton_OnLoad(self, self.unit, showmenu);
end

function SmartToTTFrameDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, SmartToTTFrameDropDown_Initialize, "MENU");
end

function SmartToTTFrameDropDown_Initialize(self)
	local menu;
	local name;
	local id = nil;
	if ( UnitIsUnit("targettargettarget", "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit("targettargettarget", "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer("targettargettarget") ) then
		id = UnitInRaid("targettargettarget");
		if ( id ) then
			menu = "RAID_PLAYER";
		elseif ( UnitInParty("targettargettarget") ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end

	if ( menu ) then
		UnitPopup_ShowMenu(self, menu, "targettargettarget", name, id);
	end
end

function SmartToTTFrame_OnEvent(self, event)
	if (event == "VARIABLES_LOADED") then
		SMART_RegisterUnitWatch(self, SMART_TOT_Config.enable and SMART_TOT_Config.tott);
	end

	if SMART_TOT_Config.tott and SMART_TOT_Config.enable then
		if (event == "PLAYER_TARGET_CHANGED") then
			SmartToT_Update(self);
		elseif (event == "UNIT_TARGET") then
			if (arg1 == "target") or (arg1 == "targettarget") then
				SmartToT_Update(self);
			end
		end

		if UnitExists(self.unit) then
			if (event == "UNIT_NAME_UPDATE") or (event == "UNIT_CLASSIFICATION_CHANGED") or (event == "UNIT_LEVEL") then
				if (arg1 == self.unit) then
					SMART_ColorName(self.name, self.unit);
					SMART_CheckLevel(self.leveltext, self.unit);
					SMART_FactionGroupCheck(self.factiongroup, self.unit);
				end
			elseif (event == "UNIT_FACTION") then
				if (arg1 == self.unit) or (arg1 == "player")then
					SMART_ColorName(self.name, self.unit);
					SMART_CheckLevel(self.leveltext, self.unit);
					SMART_FactionGroupCheck(self.factiongroup, self.unit);
				end
			elseif (event == "UNIT_PORTRAIT_UPDATE") then
				SetPortraitTexture(self.portrait, self.unit);
			elseif (event == "RAID_TARGET_UPDATE") then
				SmartToT_RaidTargetCheck(self);
			end
		end
	end
end

function SmartToT_CommandHandler(msg)
	if (strlower(msg) == strlower("reset")) then
		SmartToT_CheckWoWToTOnOff()

		if SmartFocusToT_CheckWoWToTOnOff then
			SmartFocusToT_CheckWoWToTOnOff()
		end

		SmartToT_ResetPosition();
	else
		DEFAULT_CHAT_FRAME:AddMessage("SmartToT: /stot [復原]");
		DEFAULT_CHAT_FRAME:AddMessage("SmartToT: [reset] -  重置位置");
	end
end

