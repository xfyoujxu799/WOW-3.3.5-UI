sUnitFrames_info = { name = "SUF頭像增強(漁漁版)", ver="3.3.3.1" }; --fishuiedit

SUF_Config = {
	Version = sUnitFrames_info.ver,
	HealthBarColoredByClass = true,  --fishuiedit
}

CreateFrame("Frame", "SmartUnitFrame", UIParent);
SmartUnitFrame:RegisterEvent("VARIABLES_LOADED")
SmartUnitFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
SmartUnitFrame:SetScript("OnEvent", function(self, event, ...) SmartUnitFrame_OnEvent(self, event, ...) end);

---------------------------------------------------------------------------------------------
-- Override Blizzard Functions
---------------------------------------------------------------------------------------------
function __UnitFrame_Update(self)
	local nameServer;

	if (self.unit == "party1") or (self.unit == "party2") or (self.unit == "party3") or (self.unit == "party4") then
		nameServer = SMART_PARTY_Config.namewithserver;
	end

	if (self.overrideName) then
		self.name:SetText(GetUnitName(self.overrideName, nameServer));
	else
		self.name:SetText(GetUnitName(self.unit, nameServer));
	end

	UnitFramePortrait_Update(self);
	UnitFrameHealthBar_Update(self.healthbar, self.unit)
	UnitFrameManaBar_Update(self.manabar, self.unit)
	--UnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator)
end

-- CHECK ADDON_BLOCKED
-- local f = CreateFrame("Frame","SmartAddonsBlockCheckTestFrame");
-- f:SetScript("OnEvent",function() DEFAULT_CHAT_FRAME:AddMessage("BLOCKED: "..tostring(arg1)..", "..tostring(arg2)) end);
-- f:RegisterEvent("ADDON_ACTION_BLOCKED");
function SmartUnitFrame_OnEvent(self, event, ...)
	if (event == "VARIABLES_LOADED") then
		SmartUnitFrameRelocator_Initialize();

		SlashCmdList["SUF"] = SmartUnitFrame_CmdHandler;
		SLASH_SUF1 = "/suf";

		UnitFrame_Update = __UnitFrame_Update;
		TargetFrame_OnUpdate = function() end;
		TargetofTarget_Update = function() end;
		TargetofTarget_OnUpdate = function() end;

		DEFAULT_CHAT_FRAME:AddMessage(sUnitFrames_info.name.." v"..sUnitFrames_info.ver.." (設置: /suf)", 1,0.82,0);

		if SCONFIG_ENABLE then
			DEFAULT_CHAT_FRAME:AddMessage("   CONFIG.UI 已載入", 1,0.82,0);
		end

		if SMART_FOCUS_ENABLE then
			DEFAULT_CHAT_FRAME:AddMessage("   FOCUS 已載入", 1,0.82,0);
		end

		if SMART_SETSCALE_ENABLE then
			DEFAULT_CHAT_FRAME:AddMessage("   SET.SCALE 已載入", 1,0.82,0);
		end

		if SMART_GROUPICON_ENABLE then
			DEFAULT_CHAT_FRAME:AddMessage("   GROUP.ICON 已載入", 1,0.82,0);
		end

		if SMART_CLASSICON_ENABLE then
			DEFAULT_CHAT_FRAME:AddMessage("   CLASS.ICON 已載入", 1,0.82,0);
		end

		-- 본래 블리자드 FrameXML에서 생명력에 따라 색을 바꾸는 코드가 있지만,
		-- HealthBar_OnValueChanged의 세번째 인자를 넣지 않아 작동되지 않고 있다.
		-- 바 색 조정을 위해 SUF에서 따로 처리한다. 08.11.07 - Isidur
		SmartUnitFrame_SetHealthBarColoring()

		-- UnitFrameHealthBar_Update 이후에 직접 HealthBar_OnValueChanged를 불러줘야
		-- 생명력 바 색이 바뀐다.
		hooksecurefunc("UnitFrameHealthBar_Update",
			function(bar, unit)
				HealthBar_OnValueChanged(bar, bar:GetValue())
			end);
	elseif (event == "PLAYER_REGEN_ENABLED") then
		if not InCombatLockdown() then
			if ((UnitInParty("player") or UnitInRaid("player")) and GetNumPartyMembers() > 0) then
				RaidOptionsFrame_UpdatePartyFrames()
			end
		end
	end
end

--
-- Health Bar Coloring
--
local UnitIsPlayer, UnitClass, RAID_CLASS_COLORS = UnitIsPlayer, UnitClass, RAID_CLASS_COLORS

function SmartUnitFrame_SetHealthBarColoring(value)
	if not value then
		value = SUF_Config.HealthBarColoredByClass
	else
		SUF_Config.HealthBarColoredByClass = value
	end

	if value then
		HealthBar_OnValueChanged = SmartUnitFrame_HealthBarColoredByClass;
	else
		HealthBar_OnValueChanged = SmartUnitFrame_HealthBarColoredByHealth;
	end
end

function SmartUnitFrame_HealthBarColoredByClass(self, value)
	if ( not value ) then
		return;
	end

	local r, g, b;

	-- 유닛이 없거나 유닛이 플레이어가 아니거나 클래스 색을 찾을 수 없으면
	-- 생명력에 따라 색을 조절한다.
	if not self.unit or not UnitIsPlayer(self.unit) or not RAID_CLASS_COLORS[select(2, UnitClass(self.unit))] then
		local min, max = self:GetMinMaxValues();
		if ( (value < min) or (value > max) ) then
			return;
		end
		if ( (max - min) > 0 ) then
			value = (value - min) / (max - min);
		else
			value = 0;
		end

		if (value > 0.5) then
			r = (1.0 - value) * 2;
			g = 1.0;
		else
			r = 1.0;
			g = value * 2;
		end

		b = 0.0;
	else
		local color = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]

		r = color.r;
		g = color.g;
		b = color.b;

	end

	self:SetStatusBarColor(r, g, b);

	if self.bg then
		local mu = self.bg.multiplier or 1;
		self.bg:SetVertexColor(r * mu, g * mu, b * mu);
	end
end

function SmartUnitFrame_HealthBarColoredByHealth(self, value)
	if ( not value ) then
		return;
	end

	local r, g, b;
	local min, max = self:GetMinMaxValues();
	if ( (value < min) or (value > max) ) then
		return;
	end
	if ( (max - min) > 0 ) then
		value = (value - min) / (max - min);
	else
		value = 0;
	end

	if (value > 0.5) then
		r = (1.0 - value) * 2;
		g = 1.0;
	else
		r = 1.0;
		g = value * 2;
	end

	b = 0.0;
	self:SetStatusBarColor(r, g, b);

	if self.bg then
		local mu = self.bg.multiplier or 1;
		self.bg:SetVertexColor(r * mu, g * mu, b * mu);
	end
end

function SmartUnitFrame_CmdHandler(msg)
	if (strlower(msg) == strlower("reset")) then
		SmartUnitFrame_ResetPosition();
	elseif (strlower(msg) == strlower("reseticon")) then
		if SCONFIG_ENABLE then
			SmartConfigUI_CommandHandler("reseticon");
		else
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: Mini地圖圖標不能使用",1,0.5,0);
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: SmartConfigUI沒有被加載.",1,0.5,0);
		end
	elseif (strlower(msg) == strlower("config")) then
		if SCONFIG_ENABLE then
			SmartConfigUI_OpenConfig();
		else
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: 頭像設置不能使用",1,0.5,0);
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: SmartConfigUI沒有被加載.",1,0.5,0);
		end
	elseif (strlower(msg) == strlower("resetconfig")) then
		if SCONFIG_ENABLE then
			SmartConfigUI_ResetConfig();
		else
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: 頭像設置不能使用",1,0.5,0);
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: SmartConfigUI沒有被加載.",1,0.5,0);
		end
	elseif (strlower(msg) == strlower("scale")) then
		if SMART_SETSCALE_ENABLE then
			SmartSetScale_ToggleMenu()
		else
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: 頭像大小不能設置",1,0.5,0);
			DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: SmartSetScale沒有加載.",1,0.5,0);
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame Command: /suf", 1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("[ reset | reseticon | config | resetconfig | scale ]", 1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("★ reset - 重置頭像位置",0.75,0.75,0.75);
		DEFAULT_CHAT_FRAME:AddMessage("★ reseticon - 重置Mini地圖圖標位置",0.75,0.75,0.75);
		DEFAULT_CHAT_FRAME:AddMessage("★ config - 頭像設置窗口打開/關閉",0.75,0.75,0.75);
		DEFAULT_CHAT_FRAME:AddMessage("★ resetconfig - 重置頭像設置",0.75,0.75,0.75);
		DEFAULT_CHAT_FRAME:AddMessage("★ scale - 頭像大小設置窗口打開/關閉",0.75,0.75,0.75);
	end
end

function SmartUnitFrame_ResetPosition()
	SmartPlayer_ResetPosition()
	SmartTarget_ResetPosition()
	SmartParty_ResetPosition()
	SmartParty_GroupCheck(true)
	SmartToT_ResetPosition()
	SmartPartyTarget_ResetPosition(true)

	if SMART_FOCUS_ENABLE then
		SmartFocusFrame_ResetPosition()
	end

	DEFAULT_CHAT_FRAME:AddMessage("SmartUnitFrame: 重置全部的頭像位置",1,0.5,0);
end

function SmartUnitFrameRelocator_Initialize()
	CreateFrame("Button", "SmartPlayerRelocator", PlayerFrame);

	SmartPlayerRelocator:SetFrameLevel(PlayerFrame:GetFrameLevel()+2);
	SmartPlayerRelocator:SetFrameStrata("HIGH");
	SmartPlayerRelocator:SetPoint("CENTER",PlayerName,"CENTER");
	SmartPlayerRelocator:SetWidth(TargetFrameNameBackground:GetWidth());
	SmartPlayerRelocator:SetHeight(TargetFrameNameBackground:GetHeight());
	SmartPlayerRelocator:SetHitRectInsets(0,0,0,0);
	SmartPlayerRelocator:SetScript("OnEnter", function(self) SmartUnitFrameRelocator_OnEnter(self) end);
	SmartPlayerRelocator:SetScript("OnLeave", SmartUnitFrameRelocator_OnLeave);
	SmartPlayerRelocator:SetScript("OnMouseDown", function(self, arg1) SmartUnitFrameRelocator_OnMouseDown(self, arg1) end);
	SmartPlayerRelocator:SetScript("OnMouseUp", function(self) SmartUnitFrameRelocator_OnMouseUp(self) end);

	CreateFrame("Button","SmartTargetRelocator", TargetFrame);

	SmartTargetRelocator:SetFrameLevel(TargetFrame:GetFrameLevel()+2);
	SmartTargetRelocator:SetFrameStrata("HIGH");
	SmartTargetRelocator:SetPoint("TOPLEFT",TargetFrameNameBackground,"TOPLEFT");
	SmartTargetRelocator:SetPoint("BOTTOMRIGHT",TargetFrameNameBackground,"BOTTOMRIGHT");
	SmartTargetRelocator:SetHitRectInsets(0,0,0,0);
	SmartTargetRelocator:SetScript("OnEnter", function(self) SmartUnitFrameRelocator_OnEnter(self) end);
	SmartTargetRelocator:SetScript("OnLeave", SmartUnitFrameRelocator_OnLeave);
	SmartTargetRelocator:SetScript("OnMouseDown", function(self, arg1) SmartUnitFrameRelocator_OnMouseDown(self, arg1) end);
	SmartTargetRelocator:SetScript("OnMouseUp", function(self) SmartUnitFrameRelocator_OnMouseUp(self) end);

	local frame

	for id=1, MAX_PARTY_MEMBERS do
		frame = CreateFrame("Button", "SmartParty"..id.."Relocator", getglobal("PartyMemberFrame"..id));

		frame:SetFrameLevel(getglobal("PartyMemberFrame"..id):GetFrameLevel()+2);
		frame:SetFrameStrata("HIGH");
		frame:SetPoint("TOPLEFT",getglobal("PartyMemberFrame"..id.."Name"),"TOPLEFT");
		frame:SetPoint("BOTTOMRIGHT",getglobal("PartyMemberFrame"..id.."Name"),"BOTTOMRIGHT");
		frame:SetHitRectInsets(0,0,0,0);

		frame:SetScript("OnEnter", function(self) SmartUnitFrameRelocator_OnEnter(self) end);
		frame:SetScript("OnLeave", SmartUnitFrameRelocator_OnLeave);
		frame:SetScript("OnMouseDown", function(self, arg1) SmartUnitFrameRelocator_OnMouseDown(self, arg1) end);
		frame:SetScript("OnMouseUp", function(self) SmartUnitFrameRelocator_OnMouseUp(self) end);

		frame = CreateFrame("Button", "SmartPartyTarget"..id.."Relocator", getglobal("PartyTargetFrame"..id));
		frame:SetFrameLevel(getglobal("PartyTargetFrame"..id):GetFrameLevel()+2);
		frame:SetFrameStrata("HIGH");
		frame:SetPoint("TOPLEFT",getglobal("PartyTargetFrame"..id.."Name"),"TOPLEFT");
		frame:SetPoint("BOTTOMRIGHT",getglobal("PartyTargetFrame"..id.."Name"),"BOTTOMRIGHT");
		frame:SetHitRectInsets(0,0,0,0);

		frame:SetScript("OnEnter", function(self) SmartUnitFrameRelocator_OnEnter(self) end);
		frame:SetScript("OnLeave", SmartUnitFrameRelocator_OnLeave);
		frame:SetScript("OnMouseDown", function(self, arg1) SmartUnitFrameRelocator_OnMouseDown(self, arg1) end);
		frame:SetScript("OnMouseUp", function(self) SmartUnitFrameRelocator_OnMouseUp(self) end);
	end

	SmartUnitFrameRelocator_Check();
end

function SmartUnitFrameRelocator_Lock()
	SmartPlayerRelocator.movable = false;
	SmartTargetRelocator.movable = false;

	if SMART_FOCUS_ENABLE then
		SmartFocusRelocator.movable = false;
	end

	local i
	for i=1, MAX_PARTY_MEMBERS do
		getgloba("SmartParty"..i.."Relocator").movable = false
		getgloba("SmartPartyTarget"..i.."Relocator").movable = false
	end
end

function SmartUnitFrameRelocator_Check()
	SmartPlayerRelocator.movable = SMART_PLAYER_Config.movable;

	if SMART_PLAYER_Config.movable then
		SmartPlayerRelocator:Show();
	else
		SmartPlayerRelocator:Hide();
	end

	SmartTargetRelocator.movable = SMART_TARGET_Config.movable;

	if SMART_TARGET_Config.movable then
		SmartTargetRelocator:Show();
	else
		SmartTargetRelocator:Hide();
	end

	SmartToTRelocator.movable = SMART_TOT_Config.movable;
	SmartToTTRelocator.movable = SMART_TOT_Config.movable;

	if SMART_TOT_Config.movable then
		SmartToTRelocator:Show();
		SmartToTTRelocator:Show();
	else
		SmartToTRelocator:Hide();
		SmartToTTRelocator:Hide();
	end

	if SMART_FOCUS_ENABLE then
		SmartFocusRelocator.movable = SMART_TARGET_Config.movable;

		if SMART_TARGET_Config.movable then
			SmartFocusRelocator:Show()
		else
			SmartFocusRelocator:Hide()
		end

		SmartFocusToTRelocator.movable = SMART_TOT_Config.movable;
		SmartFocusToTTRelocator.movable = SMART_TOT_Config.movable;

		if SMART_TOT_Config.movable then
			SmartFocusToTRelocator:Show();
		else
			SmartFocusToTRelocator:Hide();
		end
	end

	local frame

	for i=1, MAX_PARTY_MEMBERS do
		frame = getglobal("SmartParty"..i.."Relocator")

		if i == 1 then
			frame.movable = SMART_PARTY_Config.movable
		else
			frame.movable = SMART_PARTY_Config.movable and not SMART_PARTY_Config.movablegroup
		end

		if frame.movable then
			frame:Show()
		else
			frame:Hide()
		end
	end

	for i=1, MAX_PARTY_MEMBERS do
		frame = getglobal("SmartPartyTarget"..i.."Relocator")

		frame.movable = SMART_PARTY_Config.movable

		if frame.movable then
			frame:Show()
		else
			frame:Hide()
		end
	end
end

function SmartUnitFrameRelocator_OnEnter(self)
	if self.movable then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip:AddLine("移動頭像");
		GameTooltip:AddLine("ALT+滑鼠右鍵或左鍵移動",1,1,1);
		GameTooltip:Show();
	end
end

function SmartUnitFrameRelocator_OnLeave()
	GameTooltip:Hide()
end

function SmartUnitFrameRelocator_OnMouseDown(self, button)
	if self.movable and IsAltKeyDown() then
		if (button == "LeftButton") or (button == "RightButton") then
			if self:GetParent():IsMovable() then
				self:GetParent():StartMoving()
			end
		end
	end
end

function SmartUnitFrameRelocator_OnMouseUp(self)
	self:GetParent():StopMovingOrSizing()
end

