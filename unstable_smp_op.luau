local env = (getgenv and getgenv()) or _G
local old = env.UNSTABLE_SMP
if old and type(old) == "table" and type(old.destroy) == "function" then
	pcall(old.destroy)
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")
local MC = plr.PlayerScripts:WaitForChild("MC")
local Net = require(MC:WaitForChild("Net"))
local Hands = require(MC:WaitForChild("Hands"))
local Controller = require(MC:WaitForChild("Controller"))
local World = require(MC:WaitForChild("World"))

local TOTEM_ID = "totem_of_undying"
local CFG = {
	killaura = true,
	autoTotem = true,
	camLock = true,
	esp = true,
	critOnly = true,
	range = 3.5,
	totemHealth = 8,
	camSmooth = 8
}
env.UNSTABLE_SMP_CFG = CFG

local gui = Instance.new("ScreenGui")
gui.Name = "UNSTABLE_SMP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local espGui = Instance.new("ScreenGui")
espGui.Name = "UNSTABLE_SMP_ESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 999998
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(252, 364)
frame.Position = UDim2.new(0, 20, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(74, 74, 88)
stroke.Thickness = 1
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame

local title = Instance.new("TextButton")
title.Name = "Title"
title.Size = UDim2.new(1, -42, 0, 32)
title.Position = UDim2.fromOffset(0, 0)
title.BackgroundTransparency = 1
title.AutoButtonColor = false
title.Active = true
title.Text = "UNSTABLE SMP"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(238, 238, 242)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local titlePad = Instance.new("UIPadding")
titlePad.PaddingLeft = UDim.new(0, 12)
titlePad.Parent = title

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -34, 0, 1)
close.BackgroundTransparency = 1
close.AutoButtonColor = false
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.fromRGB(220, 92, 92)
close.Parent = frame

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -24, 0, 30)
status.Position = UDim2.fromOffset(12, 300)
status.BackgroundTransparency = 1
status.Text = "HP ?   Offhand ?   Targets 0"
status.Font = Enum.Font.Code
status.TextSize = 11
status.TextColor3 = Color3.fromRGB(178, 178, 190)
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.TextWrapped = true
status.Parent = frame

local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.Size = UDim2.new(1, -24, 0, 14)
footer.Position = UDim2.fromOffset(12, 336)
footer.BackgroundTransparency = 1
footer.Text = "K kill T totem P esp C crit RShift"
footer.Font = Enum.Font.Code
footer.TextSize = 10
footer.TextColor3 = Color3.fromRGB(120, 120, 132)
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = frame

local refresh
local toggleButtons = {}
local valueLabels = {}
local toggleLabels = {
	killaura = "Killaura",
	autoTotem = "Auto Totem",
	camLock = "Camera Lock",
	esp = "ESP",
	critOnly = "Crit Only"
}

local function makeToggle(labelText, key, y)
	local button = Instance.new("TextButton")
	button.Name = key
	button.Size = UDim2.new(1, -24, 0, 28)
	button.Position = UDim2.fromOffset(12, y)
	button.BackgroundColor3 = Color3.fromRGB(38, 96, 56)
	button.AutoButtonColor = false
	button.Text = labelText
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 13
	button.TextColor3 = Color3.fromRGB(245, 245, 248)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = frame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 4)
	buttonCorner.Parent = button

	local buttonPad = Instance.new("UIPadding")
	buttonPad.PaddingLeft = UDim.new(0, 10)
	buttonPad.Parent = button

	button.MouseButton1Click:Connect(function()
		CFG[key] = not CFG[key]
		refresh()
	end)

	toggleButtons[key] = button
end

local function makeStep(labelText, key, minimum, maximum, increment, y, format)
	local row = Instance.new("Frame")
	row.Name = key
	row.Size = UDim2.new(1, -24, 0, 28)
	row.Position = UDim2.fromOffset(12, y)
	row.BackgroundTransparency = 1
	row.Parent = frame

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -86, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = labelText
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 13
	text.TextColor3 = Color3.fromRGB(214, 214, 224)
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Parent = row

	local minus = Instance.new("TextButton")
	minus.Size = UDim2.fromOffset(26, 24)
	minus.Position = UDim2.new(1, -86, 0, 2)
	minus.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	minus.AutoButtonColor = false
	minus.Text = "-"
	minus.Font = Enum.Font.GothamBold
	minus.TextSize = 14
	minus.TextColor3 = Color3.fromRGB(230, 230, 238)
	minus.Parent = row

	local minusCorner = Instance.new("UICorner")
	minusCorner.CornerRadius = UDim.new(0, 4)
	minusCorner.Parent = minus

	local value = Instance.new("TextLabel")
	value.Size = UDim2.fromOffset(32, 24)
	value.Position = UDim2.new(1, -58, 0, 2)
	value.BackgroundTransparency = 1
	value.Text = format:format(CFG[key])
	value.Font = Enum.Font.Code
	value.TextSize = 12
	value.TextColor3 = Color3.fromRGB(238, 202, 92)
	value.Parent = row

	local plus = Instance.new("TextButton")
	plus.Size = UDim2.fromOffset(26, 24)
	plus.Position = UDim2.new(1, -26, 0, 2)
	plus.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	plus.AutoButtonColor = false
	plus.Text = "+"
	plus.Font = Enum.Font.GothamBold
	plus.TextSize = 14
	plus.TextColor3 = Color3.fromRGB(230, 230, 238)
	plus.Parent = row

	local plusCorner = Instance.new("UICorner")
	plusCorner.CornerRadius = UDim.new(0, 4)
	plusCorner.Parent = plus

	minus.MouseButton1Click:Connect(function()
		CFG[key] = math.clamp(CFG[key] - increment, minimum, maximum)
		refresh()
	end)

	plus.MouseButton1Click:Connect(function()
		CFG[key] = math.clamp(CFG[key] + increment, minimum, maximum)
		refresh()
	end)

	valueLabels[key] = {
		label = value,
		format = format
	}
end

makeToggle("Killaura", "killaura", 40)
makeToggle("Auto Totem", "autoTotem", 72)
makeToggle("Camera Lock", "camLock", 104)
makeToggle("ESP", "esp", 136)
makeToggle("Crit Only", "critOnly", 168)
makeStep("Killaura Range", "range", 1, 6, 0.5, 200, "%.1f")
makeStep("Totem HP", "totemHealth", 1, 20, 1, 232, "%d")
makeStep("Camera Smooth", "camSmooth", 1, 20, 1, 264, "%d")

refresh = function()
	for key, button in pairs(toggleButtons) do
		local label = toggleLabels[key] or key
		local on = CFG[key] == true
		button.Text = label .. ": " .. (on and "ON" or "OFF")
		button.BackgroundColor3 = on and Color3.fromRGB(38, 96, 56) or Color3.fromRGB(72, 38, 42)
	end
	for key, item in pairs(valueLabels) do
		item.label.Text = item.format:format(CFG[key])
	end
end

refresh()

local connections = {}
local destroyed = false
local totemBusy = false
local lastAttack = 0
local lastStatus = 0
local camTarget = nil
local espElements = {}
local CAMERA_BIND = "UNSTABLE_SMP_CAMERA"
local ESP_BIND = "UNSTABLE_SMP_ESP"

local function track(connection)
	connections[#connections + 1] = connection
	return connection
end

local function snapshot(look)
	local state = Controller.state
	if not state or not state.pos then
		return nil
	end
	return {
		fall = state.fallDistance or 0,
		ground = state.onGround == true,
		sprint = state.sprinting == true,
		water = state.inWater == true,
		gliding = state.gliding == true,
		vel = state.vel or Vector3.new(0, 0, 0),
		look = look,
		swap = false,
		pos = state.pos,
		predicted = true
	}
end

local function bestTarget()
	local eye = Controller.eye()
	if not eye then
		return nil
	end
	local ok, targets = pcall(World.targets)
	if not ok or type(targets) ~= "table" then
		return nil
	end
	local best = nil
	local bestDistance = nil
	for _, target in ipairs(targets) do
		local height = target.height or 1.8
		local centre = target.feet + Vector3.new(0, height * 0.5, 0)
		local distance = (centre - eye).Magnitude
		if distance <= CFG.range and (not bestDistance or distance < bestDistance) then
			best = target
			bestDistance = distance
		end
	end
	return best, eye
end

local function updateCameraTarget()
	if not CFG.camLock or Controller.locked then
		camTarget = nil
		return
	end
	camTarget = bestTarget()
end

local function aimCamera(dt)
	if destroyed or not CFG.camLock or not camTarget then
		return
	end
	if Controller.locked or Controller.frozen then
		return
	end
	local eye = Controller.eye()
	if not eye then
		return
	end
	local target = camTarget
	local height = target.height or 1.8
	local delta = target.feet + Vector3.new(0, height * 0.6, 0) - eye
	if delta.Magnitude < 0.0001 then
		return
	end
	local desiredYaw = math.atan2(-delta.X, -delta.Z)
	local desiredPitch = math.atan2(delta.Y, math.sqrt(delta.X * delta.X + delta.Z * delta.Z))
	local smooth = math.clamp(CFG.camSmooth or 8, 1, 20)
	local alpha = 1 - math.exp(-(dt or (1 / 60)) * (21 - smooth) * 1.2)
	local difference = (desiredYaw - Controller.yaw + math.pi) % (2 * math.pi) - math.pi
	Controller.yaw = (Controller.yaw + difference * alpha + math.pi) % (2 * math.pi) - math.pi
	Controller.pitch = Controller.pitch + (desiredPitch - Controller.pitch) * alpha
	Controller.pitch = math.clamp(Controller.pitch, -math.pi / 2, math.pi / 2)
end

local function canCrit()
	if not CFG.critOnly then
		return true
	end
	local state = Controller.state
	if not state then
		return false
	end
	if (state.fallDistance or 0) <= 0 then
		return false
	end
	if state.onGround == true or state.inWater == true or state.sprinting == true or state.gliding == true or state.flying == true then
		return false
	end
	return true
end

local function hideEsp(element)
	element.box.Visible = false
	element.name.Visible = false
	element.healthBg.Visible = false
	element.healthFill.Visible = false
end

local function makeEspElement(id)
	local box = Instance.new("Frame")
	box.Name = "ESP_" .. tostring(id)
	box.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
	box.BackgroundTransparency = 0.88
	box.BorderSizePixel = 0
	box.Visible = false
	box.Parent = espGui

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(255, 80, 80)
	boxStroke.Thickness = 1.5
	boxStroke.Parent = box

	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.Code
	name.TextSize = 12
	name.TextColor3 = Color3.fromRGB(255, 255, 255)
	name.TextStrokeTransparency = 0.2
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.TextYAlignment = Enum.TextYAlignment.Bottom
	name.Visible = false
	name.Parent = espGui

	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBg"
	healthBg.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	healthBg.BorderSizePixel = 0
	healthBg.Visible = false
	healthBg.Parent = espGui

	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.AnchorPoint = Vector2.new(0, 1)
	healthFill.Position = UDim2.new(0, 0, 1, 0)
	healthFill.Size = UDim2.new(1, 0, 1, 0)
	healthFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
	healthFill.BorderSizePixel = 0
	healthFill.Visible = false
	healthFill.Parent = healthBg

	local element = {
		box = box,
		stroke = boxStroke,
		name = name,
		healthBg = healthBg,
		healthFill = healthFill
	}
	espElements[id] = element
	return element
end

local function updateEsp()
	if destroyed then
		return
	end
	if not CFG.esp then
		for _, element in pairs(espElements) do
			hideEsp(element)
		end
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local ok, targets = pcall(World.targets)
	if not ok or type(targets) ~= "table" then
		for _, element in pairs(espElements) do
			hideEsp(element)
		end
		return
	end
	local eye = Controller.eye()
	local seen = {}
	for _, target in ipairs(targets) do
		local model = target.model
		if model and model.Parent and target.id ~= nil then
			local okBox, bounds, size = pcall(function()
				return model:GetBoundingBox()
			end)
			if okBox and bounds and size then
				local top = bounds.Position + Vector3.new(0, size.Y * 0.5, 0)
				local bottom = bounds.Position - Vector3.new(0, size.Y * 0.5, 0)
				local topScreen = camera:WorldToViewportPoint(top)
				local bottomScreen = camera:WorldToViewportPoint(bottom)
				if topScreen.Z > 0 and bottomScreen.Z > 0 then
					local centerX = (topScreen.X + bottomScreen.X) * 0.5
					local topY = math.min(topScreen.Y, bottomScreen.Y)
					local bottomY = math.max(topScreen.Y, bottomScreen.Y)
					local height = bottomY - topY
					if height >= 8
						and centerX > -100
						and centerX < camera.ViewportSize.X + 100
						and bottomY > -100
						and topY < camera.ViewportSize.Y + 100
					then
						local width = math.clamp(height * ((target.width or 0.6) / (target.height or 1.8)), 10, 220)
						local element = espElements[target.id] or makeEspElement(target.id)
						local dummy = model:GetAttribute("Dummy") == true
						local health = tonumber(model:GetAttribute("Health")) or 0
						local maxHealth = tonumber(model:GetAttribute("MaxHealth")) or 20
						local display = model:GetAttribute("DisplayName") or model.Name
						local distance = eye and math.floor((target.feet - eye).Magnitude + 0.5) or 0
						local healthFraction = maxHealth > 0 and math.clamp(health / maxHealth, 0, 1) or 0

						element.stroke.Color = dummy and Color3.fromRGB(255, 180, 80) or Color3.fromRGB(255, 80, 80)
						element.box.Position = UDim2.fromOffset(math.floor(centerX - width * 0.5), math.floor(topY))
						element.box.Size = UDim2.fromOffset(math.floor(width), math.floor(height))
						element.box.Visible = true
						element.name.Text = string.format("%s  %d/%d  %dm", tostring(display), health, maxHealth, distance)
						element.name.Position = UDim2.fromOffset(math.floor(centerX - 110), math.floor(topY - 16))
						element.name.Size = UDim2.fromOffset(220, 14)
						element.name.Visible = true
						element.healthBg.Position = UDim2.fromOffset(math.floor(centerX - width * 0.5 - 7), math.floor(topY))
						element.healthBg.Size = UDim2.fromOffset(3, math.floor(height))
						element.healthBg.Visible = true
						element.healthFill.Size = UDim2.new(1, 0, healthFraction, 0)
						element.healthFill.BackgroundColor3 = healthFraction > 0.6 and Color3.fromRGB(80, 220, 100)
							or (healthFraction > 0.3 and Color3.fromRGB(235, 200, 70) or Color3.fromRGB(235, 70, 70))
						element.healthFill.Visible = true
						seen[target.id] = true
					end
				end
			end
		end
	end
	for id, element in pairs(espElements) do
		if not seen[id] then
			hideEsp(element)
		end
	end
end

local function doKillaura()
	if not CFG.killaura or Controller.locked then
		return
	end
	if workspace:GetAttribute("JugHold") == true then
		return
	end
	local character = plr.Character
	if not character or character:GetAttribute("Alive") ~= true then
		return
	end
	local okMode, mode = pcall(Hands.gamemode)
	if okMode and mode == "spectator" then
		return
	end
	local okStrength, strength = pcall(Hands.strength)
	if not okStrength or strength < 0.95 then
		return
	end
	if not canCrit() then
		return
	end
	local now = os.clock()
	if now - lastAttack < 0.05 then
		return
	end
	local target, eye = bestTarget()
	if not target then
		return
	end
	local height = target.height or 1.8
	local aim = target.feet + Vector3.new(0, height * 0.6, 0) - eye
	if aim.Magnitude < 0.0001 then
		return
	end
	local state = snapshot(aim.Unit)
	if not state then
		return
	end
	local ok = pcall(Net.send, {
		a = "attack",
		target = target.id,
		st = state
	})
	if ok then
		Hands.attackReset = Controller.tickCount
		Hands.swing = os.clock()
		lastAttack = now
	end
end

local function hotbarTotem()
	local inv = Hands.inv
	if not inv or not inv.hotbar then
		return nil
	end
	for slot = 1, 9 do
		local item = inv.hotbar[slot]
		if item and item.id == TOTEM_ID then
			return slot
		end
	end
	return nil
end

local function inventoryTotem()
	local inv = Hands.inv
	local inventory = inv and inv.inventory
	if not inventory then
		return nil
	end
	local maximum = 0
	for key in pairs(inventory) do
		if type(key) == "number" and key > maximum then
			maximum = key
		end
	end
	for index = 1, maximum do
		local item = inventory[index]
		if item and item.id == TOTEM_ID then
			return index + 10
		end
	end
	return nil
end

local function ensureTotem()
	if not CFG.autoTotem or totemBusy then
		return
	end
	local inv = Hands.inv
	if not inv then
		return
	end
	local offhand = inv.offhand
	local offhandId = type(offhand) == "table" and offhand.id or nil
	if offhandId == TOTEM_ID then
		return
	end
	local offhandEmpty = offhand == nil or offhandId == nil
	local health = plr:GetAttribute("Health") or 20
	if not offhandEmpty and health > CFG.totemHealth then
		return
	end
	if offhandEmpty and inv.cursor and inv.cursor.id == TOTEM_ID then
		Net.send({ a = "inv", op = "click", slot = 10, right = false, shift = false })
		return
	end
	if inv.cursor then
		return
	end
	local slot = hotbarTotem()
	if slot then
		if inv.selected ~= slot then
			pcall(Hands.select, slot)
			return
		end
		if Hands.stopUsing then
			pcall(Hands.stopUsing, false)
		end
		local current = inv.hotbar[inv.selected]
		inv.hotbar[inv.selected] = inv.offhand
		inv.offhand = current
		pcall(Net.send, { a = "swap" })
		Hands.attackReset = Controller.tickCount
		return
	end
	local inventorySlot = inventoryTotem()
	if not inventorySlot or inv.cursor then
		return
	end
	totemBusy = true
	task.spawn(function()
		pcall(function()
			Net.send({ a = "inv", op = "click", slot = inventorySlot, right = false, shift = false })
			task.wait(0.08)
			local cursor = Hands.inv.cursor
			if not cursor or cursor.id ~= TOTEM_ID then
				return
			end
			Net.send({ a = "inv", op = "click", slot = 10, right = false, shift = false })
			task.wait(0.08)
			if Hands.inv.cursor then
				Net.send({ a = "inv", op = "click", slot = inventorySlot, right = false, shift = false })
				task.wait(0.08)
			end
		end)
		totemBusy = false
	end)
end

local function updateStatus()
	local health = plr:GetAttribute("Health")
	local offhand = Hands.inv and Hands.inv.offhand
	local offhandText = offhand and offhand.id or "empty"
	local count = 0
	local ok, targets = pcall(World.targets)
	if ok and type(targets) == "table" then
		count = #targets
	end
	local critText = not CFG.critOnly and "crit off" or (canCrit() and "CRIT" or "no crit")
	status.Text = string.format(
		"HP %s   Offhand %s   Targets %d   %s",
		health and tostring(health) or "?",
		offhandText,
		count,
		critText
	)
end

local function destroy()
	if destroyed then
		return
	end
	destroyed = true
	for _, connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	pcall(function()
		RunService:UnbindFromRenderStep(CAMERA_BIND)
	end)
	pcall(function()
		RunService:UnbindFromRenderStep(ESP_BIND)
	end)
	pcall(function()
		espGui:Destroy()
	end)
	pcall(function()
		gui:Destroy()
	end)
	if env.UNSTABLE_SMP_CFG == CFG then
		env.UNSTABLE_SMP_CFG = nil
	end
	if env.UNSTABLE_SMP and env.UNSTABLE_SMP.destroy == destroy then
		env.UNSTABLE_SMP = nil
	end
end

local api = {
	cfg = CFG,
	destroy = destroy
}
env.UNSTABLE_SMP = api

close.MouseButton1Click:Connect(destroy)

track(RunService.Heartbeat:Connect(function(delta)
	if destroyed then
		return
	end
	if Controller.state then
		ensureTotem()
		doKillaura()
		updateCameraTarget()
	end
	lastStatus = lastStatus + delta
	if lastStatus >= 0.2 then
		lastStatus = 0
		updateStatus()
	end
end))

RunService:BindToRenderStep(CAMERA_BIND, Enum.RenderPriority.Camera.Value - 1, aimCamera)
RunService:BindToRenderStep(ESP_BIND, Enum.RenderPriority.Camera.Value + 2, updateEsp)

track(UIS.InputBegan:Connect(function(input, gameProcessed)
	if destroyed or gameProcessed then
		return
	end
	if UIS:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		frame.Visible = not frame.Visible
	elseif input.KeyCode == Enum.KeyCode.K then
		CFG.killaura = not CFG.killaura
		refresh()
	elseif input.KeyCode == Enum.KeyCode.T then
		CFG.autoTotem = not CFG.autoTotem
		refresh()
	elseif input.KeyCode == Enum.KeyCode.P then
		CFG.esp = not CFG.esp
		refresh()
	elseif input.KeyCode == Enum.KeyCode.C then
		CFG.critOnly = not CFG.critOnly
		refresh()
	end
end))

local dragging = false
local dragStart = nil
local startPosition = nil

track(title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end))

track(UIS.InputChanged:Connect(function(input)
	if not dragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end))

track(UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end))

updateStatus()
