--------------------------------------------
--
-- SMART - PLAYER
--
--------------------------------------------
SMART_PLAYER_ENABLE = true;

SMART_PLAYER_Config = { --fishuiedit
	statusbartext=true,
	statusbarmana=true,
	statusbarloss=false,
	percent=true,
	percenttoloss=false,
	percentmana=true,
	elite=true,
	rare=false,
	petstatusbartext=true,
	petstatusbarmana=true,
	groupicon=true,
	movable=true,
	healthtopercent=false
};

function SmartPlayer_OnLoad(self)
	-- Blizzard Frame
	PlayerFrame:SetMovable(true);

	PlayerFrameHealthBarText:SetAlpha(0);
	PlayerFrameHealthBarText:Hide();

	PlayerFrameManaBarText:SetAlpha(0);
	PlayerFrameManaBarText:Hide();

	PlayerPVPTimerText:SetAlpha(0);
	PlayerPVPTimerText:Hide();


	PlayerStatusTexture:SetTexture("Interface\\AddOns\\SmartUnitFrame\\CircleFlash.tga");
	PlayerStatusTexture:SetWidth(64);
	PlayerStatusTexture:SetHeight(64);
	--PlayerStatusTexture:SetTexCoordModifiesRect(false);
	PlayerStatusTexture:SetTexCoord(0, 1, 0, 1);
	PlayerStatusTexture:ClearAllPoints();
	PlayerStatusTexture:SetPoint("CENTER", PlayerPortrait, "CENTER", 0, 0);

	PlayerFrame:SetHitRectInsets(36, 0, 16, 22);
	-------

	SmartPlayerTextureFrame:SetFrameLevel(PlayerFrame:GetFrameLevel() + 2);
	SmartPlayerHealthBarText:ClearAllPoints();
	SmartPlayerHealthBarText:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 1);
	SmartPlayerManaBarText:ClearAllPoints();
	SmartPlayerManaBarText:SetPoint("CENTER", PlayerFrameManaBar,"CENTER", 0, 0);
	SmartPlayerHealthPercent:ClearAllPoints();
	SmartPlayerHealthPercent:SetPoint("CENTER", PlayerFrameHealthBar, "RIGHT", 20, 1);
	SmartPlayerManaPercent:ClearAllPoints();
	SmartPlayerManaPercent:SetPoint("CENTER", PlayerFrameManaBar, "RIGHT", 20, 0);
	-- DeadText
	SmartPlayerTextureFrame:CreateFontString("PlayerDeadText", "ARTWORK", "GameFontNormalSmall");
	PlayerDeadText:SetPoint("CENTER", PlayerFrame, 50, 3);

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
	self.spellbarAnchor = nil

	PlayerFrame_AnimateOut = SmartPlayer_VehicleAnimate;
	PlayerFrame_UpdateArt = SmartPlayer_UpdateArt;
	PlayerFrame_ToPlayerArt = SmartPlayerFrame_ToPlayerArt;
	PlayerFrame_ToVehicleArt = SmartPlayerFrame_ToVehicleArt;
end

function SafeUnitFrame_SetUnit(self, unit, healthbar, manabar)
	self.unit = unit;
	healthbar.unit = unit;
	if ( manabar ) then	--Party Pet frames don't have a mana bar.
		manabar.unit = unit;
	end

	if not InCombatLockdown() then
		self:SetAttribute("unit", unit);
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
	end

	if ( (self==PlayerFrame or self==PetFrame) and unit=="player") then
		local _,class = UnitClass("player");
		if ( class=="DEATHKNIGHT" ) then
			if ( self==PlayerFrame ) then
				RuneFrame:SetScale(1)
				RuneFrame:ClearAllPoints()
				RuneFrame:SetPoint("TOP", self,"BOTTOM", 52, 34)
			elseif ( self==PetFrame ) then
				RuneFrame:SetScale(0.6)
				RuneFrame:ClearAllPoints()
				RuneFrame:SetPoint("TOP",self,"BOTTOM",25,20)
			end
		end
	end
	securecall("UnitFrame_Update", self);
end

function SmartPlayer_VehicleAnimate(self)
	self.inSeat = false;
	self.inSequence = true;
	self.animFinished = true;
	PlayerFrame_UpdateArt(self);
end

function SmartPlayer_UpdateArt(self)
	if (self.animFinished and self.inSeat and self.inSequence) then
		PlayerFrame_ToVehicleArt(self, UnitVehicleSkin("player"));
		self.inSequence = false;
		PetFrame_Update(PetFrame);
	end
end

function SmartPlayerFrame_ToPlayerArt(self)
	--Unswap frame
	SafeUnitFrame_SetUnit(self, "player", PlayerFrameHealthBar, PlayerFrameManaBar);
	SafeUnitFrame_SetUnit(PetFrame, "pet", PetFrameHealthBar, PetFrameManaBar);

	PetFrame_Update(PetFrame);
	PlayerFrame_Update();
	BuffFrame_Update();
	ComboFrame_Update();

	PlayerFrameTexture:Show();
	PlayerFrameVehicleTexture:Hide();
	PlayerName:SetPoint("CENTER",50,19);
	PlayerLeaderIcon:SetPoint("TOPLEFT",50,-10);
	PlayerMasterIcon:SetPoint("TOPLEFT",80,-10);
	PlayerFrameGroupIndicator:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 97, -20);
	PlayerFrameHealthBar:SetWidth(119);
	PlayerFrameHealthBar:SetPoint("TOPLEFT",106,-41);
	PlayerFrameManaBar:SetWidth(119);
	PlayerFrameManaBar:SetPoint("TOPLEFT",106,-52);
	PlayerFrameBackground:SetWidth(119);
	PlayerLevelText:Show();

	PlayerFrame.state = "player";
end

function SmartPlayerFrame_ToVehicleArt(self, vehicleType)
	if ( not UnitHasVehicleUI("player") ) then
		PlayerFrame_ToPlayerArt(self);
		return;
	end

	--Swap frame
	SafeUnitFrame_SetUnit(self, "vehicle", PlayerFrameHealthBar, PlayerFrameManaBar);
	SafeUnitFrame_SetUnit(PetFrame, "player", PetFrameHealthBar, PetFrameManaBar);

	PetFrame_Update(PetFrame);
	PlayerFrame_Update();
	BuffFrame_Update();
	ComboFrame_Update();

	PlayerFrameTexture:Hide();
	if ( vehicleType == "Natural" ) then
		PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic");
		PlayerFrameHealthBar:SetWidth(103);
		PlayerFrameHealthBar:SetPoint("TOPLEFT",116,-41);
		PlayerFrameManaBar:SetWidth(103);
		PlayerFrameManaBar:SetPoint("TOPLEFT",116,-52);
	else
		PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame");
		PlayerFrameHealthBar:SetWidth(100);
		PlayerFrameHealthBar:SetPoint("TOPLEFT",119,-41);
		PlayerFrameManaBar:SetWidth(100);
		PlayerFrameManaBar:SetPoint("TOPLEFT",119,-52);
	end
	PlayerFrameVehicleTexture:Show();

	PlayerName:SetPoint("CENTER",50,23);
	PlayerLeaderIcon:SetPoint("TOPLEFT",50,0);
	PlayerMasterIcon:SetPoint("TOPLEFT",86,0);
	PlayerFrameGroupIndicator:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 97, -13);

	PlayerFrameBackground:SetWidth(114);
	PlayerLevelText:Hide();

	PlayerFrame.state = "vehicle";
end

function SmartPlayer_ResetPosition()
	if PlayerFrame:IsUserPlaced() then
		PlayerFrame:ClearAllPoints();

		if SMART_PLAYER_Config.elite or SMART_GROUPICON_ENABLE then
			PlayerFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 5, 0);
		else
			PlayerFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", -16, 0);
		end
	else
		local _, _, _, _, yOfs = PlayerFrame:GetPoint();
		PlayerFrame:ClearAllPoints();

		if SMART_PLAYER_Config.elite or SMART_GROUPICON_ENABLE then
			PlayerFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 5, yOfs);
		else
			PlayerFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", -16, yOfs);
		end
	end

	PlayerFrame:SetUserPlaced(false);
end

function SmartPlayer_OnUpdate(self, elapsed)
	SmartPlayer_HealthUpdate(self)
	SmartPlayer_ManaUpdate(self)
end

function SmartPlayer_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5 = ...;

	if (event == "VARIABLES_LOADED") then
		if not PlayerFrame:IsUserPlaced() then
			SmartPlayer_ResetPosition();
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		if SMART_PLAYER_Config.elite then
			if SMART_PLAYER_Config.rare then
				PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp");
			else
				PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp");
			end
		else
			PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame.blp");
		end

		SmartPlayer_HealthUpdate(self);
		SmartPlayer_ManaUpdate(self);

		if not PartyMemberFrame1:IsUserPlaced() then
			SmartParty_ResetPosition()
		end

		SmartPartyTarget_ResetPosition()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		PlayerFrame:SetAttribute("unit", PlayerFrame.unit);
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	end
end

function SmartPlayer_HealthUpdate(self)
	local unit = self:GetParent().unit;

	if UnitIsConnected(unit) then
		if (UnitIsDead(unit)) then
			PlayerFrameHealthBar:Hide()
			SmartPlayerHealthBarText:Hide()
			if SMART_CheckFeign(unit) then
				PlayerDeadText:SetText("假死")
			else
				PlayerDeadText:SetText("死亡")
			end
			PlayerDeadText:Show()
		elseif (UnitIsGhost(unit)) then
			PlayerFrameHealthBar:Hide()
			SmartPlayerHealthBarText:Hide()
			PlayerDeadText:SetText("幽靈")
			PlayerDeadText:Show()
		else
			PlayerDeadText:Hide()
			PlayerFrameHealthBar:Show()

			if SMART_PLAYER_Config.statusbartext then
				if SMART_PLAYER_Config.statusbarloss then
					SMART_HealthLoss(SmartPlayerHealthBarText, unit)
				elseif SMART_PLAYER_Config.healthtopercent then
					SMART_OldStyleHealthUpdate(SmartPlayerHealthBarText, unit)
				else
					SMART_HealthUpdate(SmartPlayerHealthBarText, unit)
				end
			else
				SmartPlayerHealthBarText:Hide()
			end
		end
	else
		PlayerFrameHealthBar:Hide()
		SmartPlayerHealthBarText:Hide()
		PlayerDeadText:SetText("離線")
		PlayerDeadText:Show()
	end

	if SMART_PLAYER_Config.percent then
		if SMART_PLAYER_Config.percenttoloss then
			SMART_HealthLoss(SmartPlayerHealthPercent, unit);
		else
			SMART_HealthPercent(SmartPlayerHealthPercent, unit);
		end
	else
		SmartPlayerHealthPercent:Hide();
	end
end

function SmartPlayer_ManaUpdate(self)
	local unit = self:GetParent().unit;

	if SMART_PLAYER_Config.statusbartext and SMART_PLAYER_Config.statusbarmana then
		SMART_ManaUpdate(SmartPlayerManaBarText, unit);
	else
		SmartPlayerManaBarText:Hide();
	end

	if SMART_PLAYER_Config.percent and SMART_PLAYER_Config.percentmana then
		SMART_ManaPercent(SmartPlayerManaPercent, unit);
	else
		SmartPlayerManaPercent:Hide();
	end
end

