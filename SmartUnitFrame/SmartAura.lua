--
-- Constants
--
SMART_AURA_GENERIC_BUFF_MAX = 32
SMART_AURA_GENERIC_DEBUFF_MAX = 40

SMART_AURA_PARTY_BUFF_MAX = 24;
SMART_AURA_PARTY_DEBUFF_MAX = 16;
SMART_AURA_PARTYPET_BUFF_MAX = 16;
SMART_AURA_PARTYPET_DEBUFF_MAX = 16;

--
-- Config
--
local DefaultConfig = {
	["Aura"] = {
		Party = { buffcount=16, debuffcount=8 },
		PartyPet = { buffcount=8, debuffcount=6 },
		Target = { buffcount=32, debuffcount=24 },
		Focus = { buffcount=32, debuffcount=24 },
	}
};

function SmartAura_ResetConfig()
	SUF_Config.Aura = {}
	SMART_CopyDefaultConfig(SUF_Config, DefaultConfig);
end

-- SmartAuraFrame for initialization
SmartAuraFrame = CreateFrame("Frame")
SmartAuraFrame:Hide()
SmartAuraFrame:RegisterEvent("VARIABLES_LOADED")
SmartAuraFrame:SetScript("OnEvent", function() SmartAura_Initialize() end)

local _PartyMemberFrame_RefreshPetDebuffs
local initialized = false

-- Call from VARIABLES_LOADED
function SmartAura_Initialize()
	local i, j

	if not initialized then
		initialized = true

		SMART_CopyDefaultConfig(SUF_Config, DefaultConfig);

		TargetFrame_UpdateAuras = function(self)
			local debuff = SUF_Config.Aura.TargetDebuff;

			SmartAura_UpdateGenericAuras(self, SUF_Config.Aura.Target.buffcount, SUF_Config.Aura.Target.debuffcount);
		end

		SmartAura_CreatePartyAuras()

		hooksecurefunc("RefreshDebuffs", SmartAura_RefreshDebuffs);

		_PartyMemberFrame_RefreshPetDebuffs= PartyMemberFrame_RefreshPetDebuffs
		PartyMemberFrame_RefreshPetDebuffs= SmartAura_PartyMemberFrame_RefreshPetDebuffs
	end

	-- Party
	if SUF_Config.Aura.Party.buffcount < SMART_AURA_PARTY_BUFF_MAX then
		for j=1, MAX_PARTY_MEMBERS do
			for i=(SUF_Config.Aura.Party.buffcount+1), SMART_AURA_PARTY_BUFF_MAX do
				getglobal("SmartPartyFrame"..j.."Buff"..i):Hide()
			end
		end
	end

	if SUF_Config.Aura.Party.debuffcount < SMART_AURA_PARTY_DEBUFF_MAX then
		for j=1, MAX_PARTY_MEMBERS do
			for i=(SUF_Config.Aura.Party.debuffcount+1), SMART_AURA_PARTY_DEBUFF_MAX do
				getglobal("SmartPartyFrame"..j.."Debuff"..i):Hide()
			end
		end
	end

	-- Party Pets
	if SUF_Config.Aura.PartyPet.buffcount < SMART_AURA_PARTYPET_BUFF_MAX then
		for j=1, MAX_PARTY_MEMBERS do
			for i=(SUF_Config.Aura.PartyPet.buffcount+1),SMART_AURA_PARTYPET_BUFF_MAX do
				getglobal("SmartPartyFrame"..j.."PetFrameBuff"..i):Hide()
			end
		end
	end

	if SUF_Config.Aura.PartyPet.debuffcount < SMART_AURA_PARTYPET_DEBUFF_MAX then
		for j=1, MAX_PARTY_MEMBERS do
			for i=(SUF_Config.Aura.PartyPet.debuffcount+1),SMART_AURA_PARTYPET_DEBUFF_MAX do
				getglobal("SmartPartyFrame"..j.."PetFrameDebuff"..i):Hide()
			end
		end
	end

	--
	-- Hide Blizzard Frames
	--
	for i=1, 4 do
		for j=1, 4 do
			getglobal("PartyMemberFrame"..j.."Debuff"..i):SetAlpha(0)
			getglobal("PartyMemberFrame"..j.."Debuff"..i):Hide()
			getglobal("PartyMemberFrame"..j.."PetFrameDebuff"..i):SetAlpha(0)
			getglobal("PartyMemberFrame"..j.."PetFrameDebuff"..i):Hide()
		end
	end

	for i=1, 4 do
		SmartAura_PartyPosition(getglobal("PartyMemberFrame"..i))
	end
end

function SmartAura_CreatePartyAuras()
	local button
	local textlayer, count

	-- Party buff button creation
	for i=1, MAX_PARTY_MEMBERS do
		for j=1, SMART_AURA_PARTY_BUFF_MAX do
			local button = CreateFrame("Button", "SmartPartyFrame"..i.."Buff"..j, getglobal("PartyMemberFrame"..i), "SmartPartyBuffButtonTemplate")
			if j > 1 then
				button:SetPoint("LEFT", getglobal("SmartPartyFrame"..i.."Buff"..(j-1)), "RIGHT", 2, 0)
			else
				button:SetPoint("TOPLEFT", getglobal("PartyMemberFrame"..i), "TOPLEFT", 48, -33)
			end

			button:SetID(j)
			button.id = j
			button:SetFrameStrata("LOW")

			textlayer = CreateFrame("Frame", button:GetName().."TextLayer", button)
			textlayer:SetPoint("TOPLEFT",button,"TOPLEFT")
			textlayer:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT")

			count = getglobal(button:GetName().."Count")
			count:ClearAllPoints()
			count:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",1,0)
			count:SetJustifyH("RIGHT")
			count:SetParent(textlayer)

			RaiseFrameLevel(getglobal(button:GetName().."Cooldown"))
			RaiseFrameLevel(textlayer)
		end

		for j=1, SMART_AURA_PARTYPET_BUFF_MAX do
			button = CreateFrame("Button", "SmartPartyFrame"..i.."PetFrameBuff"..j, getglobal("PartyMemberFrame"..i.."PetFrame"), "SmartPartyPetBuffButtonTemplate")

			if j > 1 then
				button:SetPoint("LEFT", getglobal("SmartPartyFrame"..i.."PetFrameBuff"..(j-1)), "RIGHT", 2, 0)
			else
				button:SetPoint("TOPLEFT", getglobal("PartyMemberFrame"..i.."PetFrame"), "TOPLEFT", 25, -20)
			end

			button:SetID(j)
			button.id = j
			button:SetFrameStrata("LOW")
			RaiseFrameLevel(button)
		end

		for j=1, SMART_AURA_PARTY_DEBUFF_MAX do
			button = CreateFrame("Button", "SmartPartyFrame"..i.."Debuff"..j, getglobal("PartyMemberFrame"..i), "SmartPartyDebuffButtonTemplate")
			if j > 1 then
				--[[
				한줄에 4개씩
				01 02 03 04
				05 06 07 08
				09 10 11 12
				13 14 15 16
				]]			
				if mod(j, 4) == 1 then
					button:SetPoint("TOPLEFT", getglobal("SmartPartyFrame"..i.."Debuff"..(j-4)), "BOTTOMLEFT", 0, -2)
				else
					button:SetPoint("LEFT", getglobal("SmartPartyFrame"..i.."Debuff"..(j-1)), "RIGHT", 2, 0)
				end
			else
				if SMART_PARTY_Config.statusbartext then
					button:SetPoint("TOPLEFT", getglobal("SmartPartyFrame"..i.."HealthBarText"), "TOPRIGHT", 10, 0)
				else
					button:SetPoint("TOPLEFT", getglobal("PartyMemberFrame"..i), "TOPRIGHT", 2, -13)
				end
			end

			button:SetID(j)
			button.id = j
			button:SetFrameStrata("LOW")

			textlayer = CreateFrame("Frame", button:GetName().."TextLayer", button)
			textlayer:SetPoint("TOPLEFT",button,"TOPLEFT")
			textlayer:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT")

			count = getglobal(button:GetName().."Count")
			count:ClearAllPoints()
			count:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",1,0)
			count:SetJustifyH("RIGHT")
			count:SetParent(textlayer)

			RaiseFrameLevel(getglobal(button:GetName().."Cooldown"))
			RaiseFrameLevel(textlayer)
		end

		for j=1, SMART_AURA_PARTYPET_DEBUFF_MAX do
			button = CreateFrame("Button", "SmartPartyFrame"..i.."PetFrameDebuff"..j, getglobal("PartyMemberFrame"..i.."PetFrame"), "SmartPartyPetDebuffButtonTemplate")

			if j > 1 then
				button:SetPoint("LEFT", getglobal("SmartPartyFrame"..i.."PetFrameDebuff"..(j-1)), "RIGHT", 2, 0)
			else
				button:SetPoint("TOPLEFT", getglobal("PartyMemberFrame"..i.."PetFrame"), "TOPLEFT", 136, -4)
			end

			button:SetID(j)
			button.id = j
			button:SetFrameStrata("LOW")
			RaiseFrameLevel(button)
		end

		getglobal("PartyMemberFrame"..i).numBuffs = 0
		getglobal("PartyMemberFrame"..i).numDebuffs = 0
		getglobal("PartyMemberFrame"..i).buffRows = 0

		getglobal("PartyMemberFrame"..i.."PetFrame").numBuffs = 0
		getglobal("PartyMemberFrame"..i.."PetFrame").numDebuffs = 0
	end
end

function SmartAura_PartyPosition(self)
	local y = math.max(0, (self.buffRows - 1) * 0.5) * 15
	local button = _G["SmartPartyFrame"..self:GetID().."Debuff1"]

	button:ClearAllPoints();

	if SMART_PARTY_Config.statusbartext then
		button:SetPoint("TOPLEFT", getglobal("SmartPartyFrame"..self:GetID().."HealthBarText"), "TOPRIGHT", 10, y);
	else
		y = y - 13;
		button:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, y);
	end
end

function SmartAura_RefreshDebuffs(self, showBuffs, unit, numBuffs)
	local id = self:GetID()
	local chkBuff, chkDebuff, maxBuff, maxDebuff
	local buffFilter = "HELPFUL"
	local debuffFilter = "HARMFUL"

	local isParty = false;

	if (self == getglobal("PartyMemberFrame"..id)) then
		chkBuff = SUF_Config.Aura.Party.buffcount
		maxBuff = SMART_AURA_PARTY_BUFF_MAX

		chkDebuff = SUF_Config.Aura.Party.debuffcount
		maxDebuff = SMART_AURA_PARTY_DEBUFF_MAX

		if SMART_PARTY_Config.bufffilter then
			buffFilter = buffFilter .. "|RAID"
		end

		if SMART_PARTY_Config.debuffFilter then
			debuffFilter = debuffFilter.."|RAID"
		end

		isParty = true
	else
		return
	end

	self.hasDispellable = nil

	--
	-- Buff Refresh Check
	--
	local name, rank, texture, stack, duration, expirationTime, isMine
	local button, icon, count, cooldown

	local idxBuff = 0

	if chkBuff > 0 then
		for i=1, maxBuff do
			name, rank, texture, stack, _, duration, expirationTime, isMine = UnitBuff(self.unit, i);
			isMine = (isMine == "player");	-- □ □□□ □ □□□ □□ □□□ □□. 09.04.24 - iambz

			if (texture) then
				idxBuff = idxBuff + 1

				if (isParty) then
					button = getglobal("SmartPartyFrame"..id.."Buff"..idxBuff)
					if not SMART_PARTY_Config.showauracooldown then duration = 0; end
				else
					break
				end

				icon = getglobal(button:GetName().."Icon")
				count = getglobal(button:GetName().."Count")
				cooldown = getglobal(button:GetName().."Cooldown")

				if (duration > 0) then
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

				if idxBuff >= chkBuff then
					break
				end
			else
				if not buffFilter then
					break
				end
			end
		end
	end

	if idxBuff < self.numBuffs then
		for i = (idxBuff+1), self.numBuffs do
			if (isParty) then
				getglobal("SmartPartyFrame"..id.."Buff"..i):Hide()
			else
				break;
			end
		end
	end

	self.numBuffs = idxBuff

	--
	-- Debuff Refresh Check
	--
	local idxDebuff = 0
	local debuffTotal = 0
	local debuffType, debuffColor, border, statusColor, unitStatus

	if chkDebuff > 0 then
		if isParty then
			unitStatus = getglobal(self:GetName().."Status")
		end

		for i=1, maxDebuff do
			name, rank, texture, stack, debuffType, duration, expirationTime = UnitDebuff(self.unit, i)

			if (texture) then
				idxDebuff = idxDebuff + 1

				if (isParty) then
					button = getglobal("SmartPartyFrame"..id.."Debuff"..idxDebuff)
					if not SMART_PARTY_Config.showauracooldown then duration = 0; end
				else
					break;
				end

				icon = getglobal(button:GetName().."Icon")
				border = getglobal(button:GetName().."Border")
				count = getglobal(button:GetName().."Count")
				cooldown = getglobal(button:GetName().."Cooldown")

				if (duration > 0) then
					cooldown:Show();
					CooldownFrame_SetTimer(cooldown, expirationTime - duration, duration, 1);
				else
					cooldown:Hide();
				end

				icon:SetTexture(texture)

				if (debuffType) then
					debuffColor = DebuffTypeColor[debuffType]
					statusColor = DebuffTypeColor[debuffType]
					self.hasDispellable = 1
					debuffTotal = debuffTotal + 1
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

				if idxDebuff >= chkDebuff then
					break
				end
			else
				if not debuffFilter then
					break
				end
			end
		end
	end

	if idxDebuff < self.numDebuffs then
		for i = (idxDebuff+1), self.numDebuffs do
			if (isParty) then
				getglobal("SmartPartyFrame"..id.."Debuff"..i):Hide()
			else
				break;
			end
		end
	end

	self.numDebuffs = idxDebuff

	if (isParty) then
		self.buffRows = math.ceil(self.numDebuffs / 4)
		SmartAura_PartyPosition(self)
	end

	-- Reset unitStatus overlay graphic timer
	if (self.numDebuffs) then
		if (debuffTotal >= self.numDebuffs) then
			self.debuffCountdown = 30
		end
	end

	if (unitStatus and statusColor) then
		unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b)
	end
end

function SmartAura_PartyMemberFrame_RefreshPetDebuffs(self, id)
	if (not id) then
		id = self:GetID()
	end

	local petFrame = getglobal("PartyMemberFrame"..id.."PetFrame")

	local unit, maxBuff, maxDebuff
	local filter;

	unit = "partypet"..id
	chkBuff = SUF_Config.Aura.PartyPet.buffcount
	chkDebuff = SUF_Config.Aura.PartyPet.debuffcount

	filter = "HELPFUL"
	if (SMART_PARTY_Config.bufffilter) then filter = filter .. "|RAID" end

	local texture, button, icon

	-- Buff Refresh Check
	local idxBuff = 0

	if chkBuff > 0 then
		for i = 1, SMART_AURA_PARTYPET_BUFF_MAX do
			_, _, texture = UnitAura(unit, i, filter)

			if (texture) then
				idxBuff = idxBuff + 1

				button = getglobal("SmartPartyFrame"..id.."PetFrameBuff"..idxBuff)

				icon = getglobal(button:GetName().."Icon")
				icon:SetTexture(texture)

				button:SetID(idxBuff)
				button.id = idxBuff

				button:Show()

				if idxBuff == chkBuff then
					break
				end
			else
				break
			end
		end
	end

	if idxBuff < petFrame.numBuffs then
		for i = (idxBuff+1), petFrame.numBuffs do
			getglobal("SmartPartyFrame"..id.."PetFrameBuff"..i):Hide()
		end
	end

	petFrame.numBuffs = idxBuff

	filter = "HARMFUL"

	if SMART_PARTY_Config.debufffilter then
		filter = filter .. "|RAID"
	end

	-- Debuff Refresh Check
	local idxDebuff = 0

	if chkDebuff > 0 then
		local debuffStack, debuffType
		local border, count, debuffColor

		for i = 1, SMART_AURA_PARTYPET_DEBUFF_MAX do
			_, _, texture, debuffStack, debuffType, _, _ = UnitAura(unit, i, filter)

			if (texture) then
				idxDebuff = idxDebuff + 1
				button = getglobal("SmartPartyFrame"..id.."PetFrameDebuff"..i)
				icon = getglobal(button:GetName().."Icon")
				border = getglobal(button:GetName().."Border")
				count = getglobal(button:GetName().."Count")

				if (debuffType) then
					debuffColor = DebuffTypeColor[debuffType]
				else
					debuffColor = DebuffTypeColor["none"]
				end

				border:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b)

				if (debuffStack > 1) then
					count:SetText(debuffStack)
					count:Show()
				else
					count:Hide()
				end

				icon:SetTexture(texture)
				button:SetID(idxDebuff)
				button.id = idxDebuff
				button:Show()

				if idxDebuff == chkDebuff then
					break
				end
			else
				break
			end
		end
	end

	if idxDebuff < petFrame.numDebuffs then
		for i = (idxDebuff+1), petFrame.numDebuffs do
			getglobal("SmartPartyFrame"..id.."PetFrameDebuff"..i):Hide()
		end
	end

	petFrame.numDebuffs = idxDebuff
end

function PartyMemberBuffTooltip_Update(isPet)
	-- Intentionally empty: Since we already have a more advanced buff/debuff
	-- display than the tooltip, the tooltip doesn't make much sense to show.
end

------------------------------------------------------------------------------------
-- Target & Focus Aura
------------------------------------------------------------------------------------

-- aura positioning constants
local AURA_START_X = 5;
local AURA_START_Y = 32;
local AURA_OFFSET_Y = 3;
local LARGE_AURA_SIZE = 27; -- Default: 21(目標DEFUFF大尺寸.預設21)
local SMALL_AURA_SIZE = 20; -- Default: 17(目標DEBUFF小尺寸.預設17)
local AURA_ROW_WIDTH = 122;
local TOT_AURA_ROW_WIDTH = 101;
local NUM_TOT_AURA_ROWS = 2;	-- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

local largeBuffList = {};
local largeDebuffList = {};

local function __UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX)
	-- a lot of this complexity is in place to allow the auras to wrap around the target of target frame if it's shown

	-- Position auras
	local size;
	local offsetY = AURA_OFFSET_Y;
	-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
	local rowWidth = 0;
	local firstBuffOnRow = 1;

	for i=1, numAuras do
		-- update size and offset info based on large aura status
		if ( largeAuraList[i] ) then
			size = LARGE_AURA_SIZE;
			offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
		else
			size = SMALL_AURA_SIZE;
		end

		-- anchor the current aura
		if ( i == 1 ) then
			rowWidth = size;
			self.auraRows = self.auraRows + 1;
		else
			rowWidth = rowWidth + size + offsetX;
		end
		if ( rowWidth > maxRowWidth ) then
			-- this aura would cause the current row to exceed the max row width, so make this aura
			-- the start of a new row instead
			updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY);

			rowWidth = size;
			self.auraRows = self.auraRows + 1;
			firstBuffOnRow = i;
			offsetY = AURA_OFFSET_Y;

			if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
				-- if we exceed the number of tot rows, then reset the max row width
				-- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
				maxRowWidth = AURA_ROW_WIDTH;
			end
		else
			updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY);
		end
	end
end

local function __UpdateBuffAnchor(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY)
	local buff = _G[buffName..index];

	if ( index == 1 ) then
		if ( UnitIsFriend("player", self.unit) or numDebuffs == 0 ) then
			-- unit is friendly or there are no debuffs...buffs start on top
			buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", AURA_START_X, AURA_START_Y);
		else
			-- unit is not friendly and we have debuffs...buffs start on bottom
			buff:SetPoint("TOPLEFT", _G[self:GetName().."Debuffs"], "BOTTOMLEFT", 0, -offsetY);
		end
		_G[self:GetName().."Buffs"]:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		_G[self:GetName().."Buffs"]:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		self.spellbarAnchor = buff;
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "BOTTOMLEFT", 0, -offsetY);
		_G[self:GetName().."Buffs"]:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		self.spellbarAnchor = buff;
	else
		-- anchor index is the previous index
		buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "TOPRIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
end

local function __UpdateDebuffAnchor(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY)
	local buff = _G[debuffName..index];

	local isFriend = UnitIsFriend("player", self.unit);

	if ( index == 1 ) then
		if ( isFriend and numBuffs > 0 ) then
			-- unit is friendly and there are buffs...debuffs start on bottom
			buff:SetPoint("TOPLEFT", _G[self:GetName().."Buffs"], "BOTTOMLEFT", 0, -offsetY);
		else
			-- unit is not friendly or there are no buffs...debuffs start on top
			buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", AURA_START_X, AURA_START_Y);
		end
		_G[self:GetName().."Debuffs"]:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
		_G[self:GetName().."Debuffs"]:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint("TOPLEFT", _G[debuffName..anchorIndex], "BOTTOMLEFT", 0, -offsetY);
		_G[self:GetName().."Debuffs"]:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_OFFSET_Y);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	else
		-- anchor index is the previous index
		buff:SetPoint("TOPLEFT", _G[debuffName..(index-1)], "TOPRIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
	local debuffFrame =_G[debuffName..index.."Border"];
	debuffFrame:SetWidth(size+2);
	debuffFrame:SetHeight(size+2);
end

function SmartAura_UpdateGenericAuras(self, buffchk, debuffchk)
	local lastidx;
	local button, buttonName;
	local buttonIcon, buttonCount, buttonCooldown, buttonStealable, buttonBorder;

	local name, rank, texture, count, debuffType, duration, expirationTime, isMine, isStealable;
	local playerIsTarget = UnitIsUnit("player", self.unit);

	local numBuffs = 0;

	lastidx = 0;
	for i=1, buffchk do
		lastidx = i;

		name, rank, texture, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(self.unit, i);
		isMine = (isMine == "player");
		buttonName = self:GetName().."Buff"..i;
		button = _G[buttonName];

		if ( not button ) then
			if ( not texture ) then
				break;
			else
				button = CreateFrame("Button", buttonName, self, "SmartBuffButtonTemplate");
				button.unit = self.unit;
			end
		end

		if ( texture ) then
			button:SetID(i);

			-- set the texture
			buttonIcon = _G[buttonName.."Icon"];
			buttonIcon:SetTexture(texture);

			-- set the count
			buttonCount = _G[buttonName.."Count"];
			if ( count > 1 ) then
				buttonCount:SetText(count);
				buttonCount:Show();
			else
				buttonCount:Hide();
			end

			-- Handle cooldowns
			buttonCooldown = _G[buttonName.."Cooldown"];
			if ( duration > 0 and SMART_TARGET_Config.showauracooldown and (not SMART_TARGET_Config.selfauracooldown or isMine ) ) then
				buttonCooldown:Show();
				CooldownFrame_SetTimer(buttonCooldown, expirationTime - duration, duration, 1);
			else
				buttonCooldown:Hide();
			end

			-- Show stealable frame if the target is not a player, the buff is stealable.
			buttonStealable = _G[buttonName.."Stealable"];
			if ( not playerIsTarget and isStealable ) then
				buttonStealable:Show();
			else
				buttonStealable:Hide();
			end

			-- Set the buff to be big if the buff is cast by the player and the target is not the player
			largeBuffList[i] = (isMine and not playerIsTarget and not UnitIsEnemy(self.unit, "player"));

			numBuffs = numBuffs + 1;

			button:ClearAllPoints();
			button:Show();
		else
			button:Hide();
		end
	end

	lastidx = lastidx + 1;

	while (lastidx <= SMART_AURA_GENERIC_BUFF_MAX) do
		button = _G[self:GetName().."Buff"..lastidx];
		if (button) then button:Hide(); end
		lastidx = lastidx + 1;
	end

	local color;
	local numDebuffs = 0;

	lastidx = 0;
	for i=1, debuffchk do
		lastidx = i;

		name, rank, texture, count, debuffType, duration, expirationTime, isMine = UnitDebuff(self.unit, i);
		isMine = (isMine == "player");	-- 여기도 추가
		buttonName = self:GetName().."Debuff"..i;
		button = _G[buttonName];

		if ( not button ) then
			if ( not texture ) then
				break;
			else
				button = CreateFrame("Button", buttonName, self, "SmartDebuffButtonTemplate");
				button.unit = self.unit;
			end
		end

		if ( texture ) then
			button:SetID(i);

			-- set the texture
			buttonIcon = _G[buttonName.."Icon"];
			buttonIcon:SetTexture(texture);

			-- set the count
			buttonCount = _G[buttonName.."Count"];
			if ( count > 1 ) then
				buttonCount:SetText(count);
				buttonCount:Show();
			else
				buttonCount:Hide();
			end

			-- Handle cooldowns
			buttonCooldown = _G[buttonName.."Cooldown"];
			if ( duration > 0 and SMART_TARGET_Config.showauracooldown and (not SMART_TARGET_Config.selfauracooldown or isMine ) ) then
				buttonCooldown:Show();
				CooldownFrame_SetTimer(buttonCooldown, expirationTime - duration, duration, 1);
			else
				buttonCooldown:Hide();
			end

			-- set debuff type color
			if ( debuffType ) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			buttonBorder = _G[buttonName.."Border"];
			buttonBorder:SetVertexColor(color.r, color.g, color.b);

			-- Set the buff to be big if the buff is cast by the player
			largeDebuffList[i] = isMine;

			numDebuffs = numDebuffs + 1;

			button:ClearAllPoints();
			button:Show();
		else
			button:Hide();
		end
	end

	lastidx = lastidx + 1;

	while (lastidx <= SMART_AURA_GENERIC_DEBUFF_MAX) do
		button = _G[self:GetName().."Debuff"..lastidx];
		if (button) then button:Hide(); end
		lastidx = lastidx + 1;
	end

	self.auraRows = 0;
	self.spellbarAnchor = nil;

	-- update buff positions
	__UpdateAuraPositions(self, self:GetName().."Buff", numBuffs, numDebuffs, largeBuffList, __UpdateBuffAnchor, AURA_ROW_WIDTH, 3);

	-- update debuff positions
	__UpdateAuraPositions(self, self:GetName().."Debuff", numDebuffs, numBuffs, largeDebuffList, __UpdateDebuffAnchor, AURA_ROW_WIDTH, 4);
	if ( self.spellbar ) then
		Target_Spellbar_AdjustPosition(self.spellbar)
	end
end
