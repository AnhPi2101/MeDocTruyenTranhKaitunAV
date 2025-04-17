--// DỊCH VỤ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

--// UI - MeDocTruyenTranh Raiden Style
local gui = Instance.new("ScreenGui")
gui.Name = "MeDocRaidenUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 160)
frame.Position = UDim2.new(0.03, 0, 0.05, 0)
frame.BackgroundTransparency = 1
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local image = Instance.new("ImageLabel")
image.Size = UDim2.new(1, 0, 1, 0)
image.BackgroundTransparency = 1
image.Image = "rbxassetid://99255503850752"
image.ScaleType = Enum.ScaleType.Crop
image.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60)),
}
gradient.Rotation = 0
gradient.Parent = image

task.spawn(function()
    local tweenInfo = TweenInfo.new(20, Enum.EasingStyle.Linear)
    while true do
        TweenService:Create(gradient, tweenInfo, { Rotation = gradient.Rotation + 360 }):Play()
        task.wait(20)
    end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.RichText = true
title.Text = '<font color="#00AEEF">MeDoc</font><font color="#EC0B3D">TruyenTranh</font>'
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 50)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Đang hoạt động"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Parent = frame

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 25)
timerLabel.Position = UDim2.new(0, 0, 0, 85)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "00:00:00"
timerLabel.Font = Enum.Font.Gotham
timerLabel.TextScaled = true
timerLabel.TextXAlignment = Enum.TextXAlignment.Center
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.Parent = frame

task.spawn(function()
    local startTime = os.time()
    while true do
        local elapsed = os.time() - startTime
        timerLabel.Text = string.format("%02d:%02d:%02d", math.floor(elapsed / 3600), math.floor((elapsed % 3600) / 60), elapsed % 60)
        task.wait(1)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)

local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

--// GAME LOGIC
local replicated = ReplicatedStorage:WaitForChild("Remotes")
local remotes = replicated
local act = 1
local maxAct = 4
local mapName = "Planet Namak"
local replayingInfinity = false

local function optimize()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

local function hasLegendary()
    for _, unit in pairs(lp.Units:GetChildren()) do
        local rarity = unit:FindFirstChild("Rarity")
        if rarity and rarity.Value == "Legendary" then
            return true
        end
    end
    return false
end

local function pickGoku()
    updateStatus("Chọn Goku...")
    local pick = remotes:WaitForChild("PickUnit")
    for _, unit in pairs(lp.Units:GetChildren()) do
        if unit.Name:lower():find("goku") then
            pick:InvokeServer(unit.Name)
            break
        end
    end
end

local function joinAct(actNumber)
    updateStatus("Vào map " .. mapName .. " - Act " .. actNumber)
    remotes:WaitForChild("StartMission"):FireServer(mapName, tostring(actNumber))
end

local function joinInfinity()
    updateStatus("Vào Infinity Map 1...")
    remotes:WaitForChild("StartMission"):FireServer(mapName, "Infinite")
end

local function teleportLobby()
    updateStatus("Teleport về Lobby...")
    local tele = remotes:FindFirstChild("TeleportToLobby")
    if tele then
        tele:InvokeServer()
    end
end

local function placeGoku()
    updateStatus("Đặt Goku...")
    task.wait(5)
    local placeRemote = remotes:WaitForChild("PlaceUnit")
    local base = Workspace:FindFirstChild("EnemyPaths"):FindFirstChildOfClass("Model")
    local pos = (base and base:GetModelCFrame().p or Vector3.new(0, 0, 0)) + Vector3.new(5, 0, 5)
    placeRemote:FireServer("Goku", pos)
end

local function summonUntilLegendary()
    updateStatus("Không có Legendary - Đang summon...")
    local summon = remotes:FindFirstChild("SummonUnit")
    while not hasLegendary() do
        summon:InvokeServer("Standard", 1)
        task.wait(2)
    end
    updateStatus("Đã summon được Legendary!")
end

local function sellRares()
    updateStatus("Bán nhân vật Rare...")
    local sell = remotes:FindFirstChild("SellUnit")
    for _, unit in pairs(lp.Units:GetChildren()) do
        local rarity = unit:FindFirstChild("Rarity")
        if rarity and rarity.Value == "Rare" then
            sell:InvokeServer(unit.Name)
            task.wait(0.3)
        end
    end
end

--// MAIN LOOP
task.spawn(function()
    optimize()
    pickGoku()
    task.wait(2)

    remotes:WaitForChild("Win").OnClientEvent:Connect(function()
        if replayingInfinity then
            updateStatus("Win Infinity Map - Replay sau 5s")
            task.wait(5)
            joinInfinity()
            return
        end

        updateStatus("Thắng Act " .. act)
        if act < maxAct then
            act += 1
            task.wait(5)
            joinAct(act)
        else
            teleportLobby()
            task.spawn(function()
                repeat task.wait(1) until Workspace:FindFirstChild("Summon NPC") or lp:WaitForChild("PlayerGui"):FindFirstChild("LobbyUI")
                if not hasLegendary() then
                    summonUntilLegendary()
                    task.wait(1)
                    sellRares()
                else
                    updateStatus("Đã có Legendary - không cần summon")
                end
                updateStatus("Chơi lại act cao nhất...")
                task.wait(2)
                joinAct(maxAct)
                act = maxAct + 1
            end)
        end
    end)

    remotes:WaitForChild("Lose").OnClientEvent:Connect(function()
        if replayingInfinity then
            updateStatus("Thua Infinity Map - Retry sau 5s")
            task.wait(5)
            joinInfinity()
            return
        end
        updateStatus("Thua Act " .. act .. " - Retry sau 5s")
        task.wait(5)
        joinAct(act)
    end)

    Workspace.ChildAdded:Connect(function(c)
        if c.Name == "Map" then
            if act <= maxAct then
                updateStatus("Playing Act " .. act)
            else
                updateStatus("Playing Infinity Map")
                replayingInfinity = true
            end
            task.wait(5)
            placeGoku()
        end
    end)

    joinAct(act)
end)

--// ANTI AFK VẬT LÝ (6 hành động)
task.spawn(function()
    while true do
        -- Xoay camera
        TweenService:Create(
            workspace.CurrentCamera,
            TweenInfo.new(1, Enum.EasingStyle.Linear),
            {CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0, math.rad(3), 0)}
        ):Play()

        -- Giả lập phím
        local keys = {"W", "A", "S", "D"}
        local key = keys[math.random(1, #keys)]
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, key, false, game)

        -- Click chuột trái
        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)

        -- Di chuyển chuột
        VirtualInputManager:SendMouseMoveEvent(500 + math.random(-10,10), 500 + math.random(-10,10), game)

        task.wait(20)
    end
end)
