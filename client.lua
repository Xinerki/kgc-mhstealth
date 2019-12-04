
function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < -180 and t + 180 or t
end

function translateAngle(x1, y1, ang, offset)
  x1 = x1 + math.sin(ang) * offset
  y1 = y1 + math.cos(ang) * offset
  return x1, y1
end

function dxDrawRing (posX, posY, radius, width, startAngle, amount, color, postGUI, absoluteAmount, anglesPerLine)
	if (type (posX) ~= "number") or (type (posY) ~= "number") or (type (startAngle) ~= "number") or (type (amount) ~= "number") then
		return false
	end
	
	if absoluteAmount then
		stopAngle = amount + startAngle
	else
		stopAngle = (amount * 360) + startAngle
	end
	
	anglesPerLine = type (anglesPerLine) == "number" and anglesPerLine or 1
	radius = type (radius) == "number" and radius or 50
	width = type (width) == "number" and width or 5
	color = color or tocolor (255, 255, 255, 255)
	postGUI = type (postGUI) == "boolean" and postGUI or false
	absoluteAmount = type (absoluteAmount) == "boolean" and absoluteAmount or false
	
	for i = startAngle, stopAngle, anglesPerLine do
		local startX = math.cos (math.rad (i)) * (radius - width)
		local startY = math.sin (math.rad (i)) * (radius - width)
		local endX = math.cos (math.rad (i)) * (radius + width)
		local endY = math.sin (math.rad (i)) * (radius + width)
		dxDrawLine (startX + posX, startY + posY, endX + posX, endY + posY, color, width, postGUI)
	end
	return math.floor ((stopAngle - startAngle)/anglesPerLine)
end

steps = {
	--[[
	[1] = {owner = localPlayer, x = 0, y = 0, z = 0, created = 0, volume = 100}
	]]
}

w, h = guiGetScreenSize()

addEventHandler("onClientHUDRender", root, function()
	dxDrawCircle(w*0.11979, h*0.79629, 150, 0, 360, tocolor(0, 0, 0, 150), tocolor(150, 150, 150, 100), 32, 1, false) -- inner circle
	dxDrawCircle(w*0.11979, h*0.79629, 8, 0, 360, tocolor(255, 255, 255, 150), nil, 32, 1, false) -- player circle
	dxDrawRing(w*0.11979, h*0.79629, 150, 5, 0, 1, tocolor(0, 0, 0, 255), false, false, 1)
	for i,v in ipairs(steps) do
		-- if v.owner ~= localPlayer then
			local px, py, pz = getElementPosition(localPlayer)
			-- local vx, vy, vz = getElementPosition(v)
			
			local cx, cy, cz = getElementRotation(getCamera())
			
			local rot = findRotation(px, py, v.x, v.y) - cz
			local distance = getDistanceBetweenPoints3D(px, py, pz, v.x, v.y, v.z)
			local rx, ry = translateAngle(0, 0, math.rad(-rot), distance*5)
			
			local now = getTickCount()
			local endTime = v.created + 300
			local elapsedTime = now - v.created
			local duration = endTime - v.created
			local progress = elapsedTime / duration
			
			local alpha = (1-progress)*255
			local size = (progress * v.volume) * 1-((distance*5)/150)
			
			local color =  tocolor(255, 0, 0, (1-(distance*5)/150)*alpha)
			if v.owner == localPlayer then color = tocolor(100, 100, 250, (1-(distance*5)/150)*alpha) end
			
			if progress >= 0.9 then table.remove(steps, i) end
			
			if distance*5 < 150 then
				dxDrawCircle(w*0.11979+rx, h*0.79629-ry, size, 0, 360, color, nil, 32, 1, false) -- player circle
				-- dxDrawCircle(w*0.11979+rx, h*0.79629-ry, 8, 0, 360, tocolor(255, 0, 0, (1-(distance*10)/150)*alpha), nil, 32, 1, false) -- player circle
				-- dxDrawCircle(w*0.11979, h*0.79629, 8, 0, 360, tocolor(255, 255, 255, 150), nil, 32, 1, false) -- player circle
				
				-- dxDrawText(rot .."\n".. distance*10 .."\n".. rx .."\n".. ry, 100, 100)
				
				-- dxDrawText(1-progress .." - ".. v.created .. " - " .. getTickCount(), 100, i*10)
				-- dxDrawText((1-(distance*10)/150)*255, 100, i*10)
			end
		-- end
	end
	
end)

addEventHandler("onClientPedStep", root, function()
	local owner = source
	local x, y, z = getElementPosition(source)
	local created = getTickCount()
	local volume = 75
	if getPedControlState(source, "walk") and getPedWalkingStyle(source) == 69 then volume = 25 end -- previously was no sound, now it's just quiet
	table.insert(steps, {owner = owner, x = x, y = y, z = z, created = created, volume = volume})
end)

addEventHandler("onClientRequestMuzzle",root,function(hitX, hitY, hitZ, x, y, z)
	local owner = source
	local x, y, z = getElementPosition(source)
	local created = getTickCount()
	table.insert(steps, {owner = owner, x = x, y = y, z = z, created = created, volume = 200})
end)

wasRadarEnabled = isPlayerHudComponentVisible("radar")

addEventHandler("onClientResourceStart", resourceRoot, function()
	setPlayerHudComponentVisible("radar", false)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	if wasRadarEnabled == true then
		setPlayerHudComponentVisible("radar", true)
	end
end)