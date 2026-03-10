local tooltipscan = CreateFrame("GameTooltip", "AQSalvRemoverBuffTooltip", nil, "GameTooltipTemplate")
tooltipscan:SetOwner(WorldFrame, "ANCHOR_NONE")

local function GetBuffName(buffIndex)
	tooltipscan:SetPlayerBuff(buffIndex)
	local toolTipText1 = getglobal("AQSalvRemoverBuffTooltipTextLeft1")
	local toolTipText2 = getglobal("AQSalvRemoverBuffTooltipTextLeft2")
	if toolTipText1 then
		return toolTipText1:GetText(), toolTipText2:GetText()
	end
	return nil
end

local function Sign(px, py, ax, ay, bx, by)
	return (px - bx) * (ay - by) - (ax - bx) * (py - by)
end

local function PointInTriangle(px, py, ax, ay, bx, by, cx, cy)
	local b1 = Sign(px, py, ax, ay, bx, by) < 0
	local b2 = Sign(px, py, bx, by, cx, cy) < 0
	local b3 = Sign(px, py, cx, cy, ax, ay) < 0
	return (b1 == b2) and (b2 == b3)
end

local function InTargetZone()
	local z = GetZoneText()
	if z and z == "Ahn'Qiraj" then
		return true
	end

	return false
end

local function InTriangle()
	if SetMapToCurrentZone then
		SetMapToCurrentZone()
	end

	local x, y = GetPlayerMapPosition("player")
	if not x or not y or (x == 0 and y == 0) then
		return false
	end

	return PointInTriangle(
		x,
		y,
		0.54224801063538,
		0.70792579650879,
		0.61414384841919,
		0.63108509778976,
		0.62897402048111,
		0.75801616907120
	)
end

local function RemoveSalvIfNeeded()
	if not InTargetZone() then
		return
	end

	if not InTriangle() then
		return
	end

	local buffIndex = 0
	while true do
		local buffId = GetPlayerBuff(buffIndex, "HELPFUL")
		if buffId < 0 then
			break
		end

		local buffName = GetBuffName(buffId)
		--if buffName == "Blessing of Salvation" or buffName == "Greater Blessing of Salvation" then
		if buffName == "Yellow Qiraji Battle Tank" then
			CancelPlayerBuff(buffIndex)
			break
		end

		buffIndex = buffIndex + 1
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_AURAS_CHANGED")

frame:SetScript("OnEvent", function()
	RemoveSalvIfNeeded()
end)