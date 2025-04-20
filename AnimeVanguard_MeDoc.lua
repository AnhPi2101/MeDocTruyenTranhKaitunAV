repeat wait() until game:IsLoaded()

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local vu = rs:WaitForChild("Remote"):WaitForChild("Function")

-- Auto Equip Unit "Roku"
local function equipRoku()
    pcall(function()
        vu:InvokeServer("EQUIP_UNIT", {["Name"] = "Roku", ["Type"] = "Unit"})
    end)
    wait(1)
end

-- Auto Join Map Act 1
local function joinAct1()
    pcall(function()
        vu:InvokeServer("START_MATCH", {["World"] = "Planet Nemak", ["Mission"] = "Act 1"})
    end)
    wait(10)
end

-- Auto Place Unit at specific position
local function placeRoku()
    pcall(function()
        vu:InvokeServer("SPAWN_UNIT", {
            ["Unit"] = "Roku",
            ["Position"] = Vector3.new(146.8177490234375, 7.105718612670898, 120.36512756347656)
        })
    end)
end

-- Check for EndScreen (win or lose) and retry
local function autoRetry()
    while true do
        if workspace:FindFirstChild("EndScreen") then
            wait(10)
            pcall(function()
                vu:InvokeServer("LEAVE_MATCH")
            end)
            wait(5)
            mainLoop()
            break
        end
        wait(5)
    end
end

-- Main Logic
function mainLoop()
    equipRoku()
    joinAct1()
    wait(15)
    placeRoku()
    autoRetry()
end

mainLoop()