--fix Pet Buff/Debuff
--By Ｓampson

--PET_WARNING_TIME = 55;
--PET_FLASH_ON_TIME = 0.5;
--PET_FLASH_OFF_TIME = 0.5;

SMART_AURA_PET_BUFF_MAX = 16;
SMART_AURA_PET_DEBUFF_MAX = 16;

SMART_PET_Config = {ChkBuff=8,MaxBuff=16,ChkDebuff=4,MaxDebuff=16};

function SmartPetFrame_OnLoad(self)
	local blizFrame = PetFrame;

	RegisterUnitWatch(blizFrame);

	_G[blizFrame:GetName().."HealthBarText"]:SetAlpha(0);
	_G[blizFrame:GetName().."ManaBarText"]:SetAlpha(0);
	blizFrame:SetMovable(true);

	SmartPetTextureFrame:SetFrameLevel(blizFrame:GetFrameLevel() + 2);

	SmartPetHealthBarText:ClearAllPoints();
	SmartPetHealthBarText:SetPoint("CENTER", PetFrameHealthBar, "CENTER", 0, 1);

	SmartPetManaBarText:ClearAllPoints();
	SmartPetManaBarText:SetPoint("CENTER", PetFrameManaBar,"CENTER", 0, 0);

	local f

	f = getglobal(blizFrame:GetName().."HealthBar")
	f:SetHitRectInsets(0, f:GetWidth(), 0, f:GetHeight())

	f.OnValueChangedFunc = f:GetScript("OnValueChanged")
	f:SetScript("OnValueChanged", function(self, ...)
		if self.OnValueChangedFunc then self:OnValueChangedFunc(...) end
		SmartPetFrame_HealthCheck(self:GetParent());
	end)

	f = getglobal(blizFrame:GetName().."ManaBar")
	f:SetHitRectInsets(0, f:GetWidth(), 0, f:GetHeight())

	f.OnValueChangedFunc = f:GetScript("OnValueChanged")
	f:SetScript("OnValueChanged", function(self, ...)
		if self.OnValueChangedFunc then self:OnValueChangedFunc(...) end
		SmartPetFrame_ManaCheck(self:GetParent());
	end)

	SmartPetFrame_AuraInitialize(blizFrame);
	SmartPetFrame_ResetPosition(blizFrame);

	PetFrame_Update = SmartPetFrame_Update;
	PetFrame_OnEvent = SmartPetFrame_OnEvent;
end

function SmartPetFrame_ResetPosition(self)
	if self == nil then
		self = PetFrame
	end

	self:ClearAllPoints();

	local _, class = UnitClass("player");

	if ( class == "DEATHKNIGHT" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 106, -75);
	elseif ( class == "SHAMAN" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 106, -100);
	else
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 106, -64);
	end

	self:SetUserPlaced(false);

	PetFrameHappiness:ClearAllPoints();
	PetFrameHappiness:SetPoint("RIGHT", "PetFrame", "LEFT", 0, 0);
end

function SmartPetFrame_HealthCheck(self)
	if SMART_PLAYER_Config.petstatusbartext then
		SMART_HealthUpdate(SmartPetHealthBarText, self.unit);
	else
		SmartPetHealthBarText:Hide();
	end
end

function SmartPetFrame_ManaCheck(self)
	if SMART_PLAYER_Config.petstatusbartext and SMART_PLAYER_Config.petstatusbarmana then
		SMART_ManaUpdate(SmartPetManaBarText, self.unit);
	else
		SmartPetManaBarText:Hide();
	end
end

function SmartPetFrame_AuraInitialize(self)
	local button, i
	local j
	local textlayer, count, cooldown

	for j = 1, 4 do
		getglobal("PetFrameDebuff"..j):SetAlpha(0)
		getglobal("PetFrameDebuff"..j):Hide()
	end

	for i=1, SMART_AURA_PET_BUFF_MAX do
		button = getglobal("SmartPetFrameBuff"..i)

		if (not button) then
			button = CreateFrame("Button", "SmartPetFrameBuff"..i, self, "SmartPetBuffButtonTemplate")
		end

		if i > 1 then
			button:SetPoint("LEFT", getglobal("SmartPetFrameBuff"..(i-1)), "RIGHT", 2, 0)
		else
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 48, -42)
		end

		button:SetID(i)
		button.id = i
		button:SetFrameStrata("LOW")

		textlayer = CreateFrame("Frame", button:GetName().."TextLayer", button)
		textlayer:SetPoint("TOPLEFT",button,"TOPLEFT")
		textlayer:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT")

		count = getglobal(button:GetName().."Count")
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",1,0)
		count:SetJustifyH("RIGHT")
		count:SetParent(textlayer)

		cooldown = getglobal(button:GetName().."Cooldown")
		cooldown:SetPoint("CENTER",button,"CENTER",0,2)

		RaiseFrameLevel(cooldown)
		RaiseFrameLevel(textlayer)
	end

	for i=1, SMART_AURA_PET_DEBUFF_MAX do
		button = getglobal("SmartPetFrameDebuff"..i)
		if (not button) then
			button = CreateFrame("Button", "SmartPetFrameDebuff"..i, self, "SmartPetDebuffButtonTemplate")
		end

		if i > 1 then
			button:SetPoint("LEFT", getglobal("SmartPetFrameDebuff"..(i-1)), "RIGHT", 2, 0)
		else
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 124, -25)
		end

		button:SetID(i)
		button.id = i
		button:SetFrameStrata("LOW")

		textlayer = CreateFrame("Frame", button:GetName().."TextLayer", button)
		textlayer:SetPoint("TOPLEFT", button, "TOPLEFT")
		textlayer:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")

		count = getglobal(button:GetName().."Count")
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
		count:SetJustifyH("RIGHT")
		count:SetParent(textlayer)

		cooldown = getglobal(button:GetName().."Cooldown")
		cooldown:SetPoint("CENTER",button,"CENTER",0,2)

		RaiseFrameLevel(cooldown)
		RaiseFrameLevel(textlayer)
	end

--	self.numBuffs = 16
--	self.numDebuffs = 16
end

function SmartPetFrame_RefreshBuffs(self)
	local name, rank, texture, stack
	local duration, expirationTime, cooldown
	local button, icon, count

	local idxBuff = 0

	--
	-- Buff
	--
	if SMART_PET_Config.ChkBuff > 0 then
		for i=1, SMART_PET_Config.MaxBuff do
--			name, rank, texture, stack, _, _, duration, endtime = UnitAura(self.unit, i, "HELPFUL")
--			name, rank, texture, stack, _, duration, endtime = UnitAura(self.unit, i, "HELPFUL")
			name, rank, texture, stack, _, duration, expirationTime = UnitBuff("pet", i)

			if (not name) then
				break;
			end

			idxBuff = idxBuff + 1

			button = getglobal("SmartPetFrameBuff"..idxBuff)
			icon = getglobal(button:GetName().."Icon")
			count = getglobal(button:GetName().."Count")
			cooldown = getglobal(button:GetName().."Cooldown")

			if (duration and duration > 0 and expirationTime ~= nil) then
				cooldown:Show();
				CooldownFrame_SetTimer(cooldown, expirationTime - duration, duration, 1);
			else
				cooldown:Hide();
			end

			icon:SetTexture(texture)
			button:SetID(idxBuff)
			button.id = idxBuff
			button:Show()

			if (stack > 1) then
				count:SetText(stack)
				count:Show()
			else
				count:Hide()
			end

			if idxBuff >= SMART_PET_Config.ChkBuff then
				break;
			end
		end
	end

	if idxBuff < SMART_AURA_PET_BUFF_MAX then
		for i = (idxBuff+1), SMART_AURA_PET_BUFF_MAX do
			getglobal("SmartPetFrameBuff"..i):Hide()
		end
	end

	SMART_AURA_PET_BUFF_MAX = idxBuff

	--
	-- Debuff
	--
	local debuffType, debuffColor
	local border

	local idxDebuff = 0

	if SMART_PET_Config.ChkDebuff > 0 then
		for i=1, SMART_PET_Config.MaxDebuff do
--			name, rank, texture, stack, debuffType, duration, endtime = UnitAura(self.unit, i, "HARMFUL");
			name, rank, texture, stack, debuffType, duration, expirationTime = UnitDebuff("pet", i)

			if (not name) then
				break;
			end

			idxDebuff = idxDebuff + 1

			button = getglobal("SmartPetFrameDebuff"..idxDebuff)
			icon = getglobal(button:GetName().."Icon")
			border = getglobal(button:GetName().."Border")
			count = getglobal(button:GetName().."Count")
			cooldown = getglobal(button:GetName().."Cooldown")

			if (duration and duration > 0 and endtime ~= nil) then
				cooldown:Show();
				CooldownFrame_SetTimer(cooldown, expirationTime - duration, duration, 1);
			else
				cooldown:Hide();
			end

			icon:SetTexture(texture)

			if (debuffType) then
				debuffColor = DebuffTypeColor[debuffType]
				self.hasDispellable = 1
			else
				debuffColor = DebuffTypeColor["none"]
			end

			border:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b)

			if (stack > 1) then
				count:SetText(stack)
				count:Show()
			else
				count:Hide()
			end

			button:SetID(idxDebuff)
			button.id = idxDebuff
			button:Show()

			if idxDebuff >= SMART_PET_Config.ChkDebuff then
				break;
			end
		end
	end

	if idxDebuff < SMART_AURA_PET_DEBUFF_MAX then
		for i = (idxDebuff+1), SMART_AURA_PET_DEBUFF_MAX do
			getglobal("SmartPetFrameDebuff"..i):Hide()
		end
	end

	SMART_AURA_PET_DEBUFF_MAX = idxDebuff
end

function SmartPetFrame_OnEvent(self, event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( (event == "UNIT_PET" and arg1 == "player" ) or event == "PET_UI_UPDATE" ) then
		local unit
		if ( UnitInVehicle("player") and UnitHasVehicleUI("player") ) then
			unit = "player";
		else
			unit = "pet";
		end
		safeUnitFrame_SetUnit(self, unit, PetFrameHealthBar, PetFrameManaBar);
		PetFrame_Update(self);
	elseif ( event == "UNIT_COMBAT" ) then
		if ( arg1 == self.unit ) then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			SmartPetFrame_RefreshBuffs(self, self.unit);
		end
	elseif ( event == "PET_ATTACK_START" ) then
		PetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		PetAttackModeTexture:Show();
	elseif ( event == "PET_ATTACK_STOP" ) then
		PetAttackModeTexture:Hide();
	elseif ( event == "UNIT_HAPPINESS" ) then
		PetFrame_SetHappiness(self);
	elseif ( event == "PET_RENAMEABLE" ) then
		StaticPopup_Show("RENAME_PET");
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		self:SetAttribute("unit", self.unit);

		if (UnitIsVisible(self.unit)) then
			if not self:IsShown() then
				self:Show();
			end
		else
			self:Hide();
		end

		self:SetAlpha(1);
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	end
end

function SmartPetFrame_Update(self)
	if ( (not PlayerFrame.animating) or (override) ) then
		if ( UnitIsVisible(self.unit) ) then
			if ( self:IsShown() ) then
				UnitFrame_Update(self);
			elseif InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED");
				self:SetAlpha(1);
			else
				self:Show();
				self:SetAlpha(1);
			end
			--self.flashState = 1;
			--self.flashTimer = PET_FLASH_ON_TIME;
			if ( UnitPowerMax(self.unit) == 0 ) then
				PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame-NoMana");
				PetFrameManaBarText:Hide();
			else
				PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame");
			end
			PetAttackModeTexture:Hide();

			PetFrame_SetHappiness(self);

			SmartPetFrame_RefreshBuffs(self);

			SmartPetFrame_HealthCheck(self)
			SmartPetFrame_ManaCheck(self)
		else
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED");
				self:SetAlpha(0);
			else
				self:Hide();
			end
		end
	end
end

