local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")


local LocalPlayer     = Players.LocalPlayer
local LocalCharacter  = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local NormalHeadSize  = LocalCharacter:WaitForChild("Head").Size

local Functions = {} do
    for i,v in ipairs(getgc(true)) do
        if typeof(v) == "table" then
            if rawget(v, "lol") then 
                Functions["RaycastCheck1"] = rawget(v, "lol") 
            elseif rawget(v, "ONRH_S4") then
                Functions["RaycastCheck2"] = rawget(v, "ONRH_S4") 
            end
        end
    end

    for i,v in pairs(getconstants(Functions["RaycastCheck1"])) do 
        if v == 1.75 or v == 10 then 
            setconstant(Functions["RaycastCheck1"], i, 20)
        end
    end

    for i,v in pairs(getconstants(Functions["RaycastCheck2"])) do 
        if v == 1.5 or v == 10 then 
            setconstant(Functions["RaycastCheck2"], i, 20)
        end
    end
end

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, idx)
    if tostring(self) == "Head" and idx == "Size" then
        return NormalHeadSize
    end

    return OldIndex(self, idx)
end)

RunService.Stepped:Connect(function()
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            v.Character.Head.Size         = Vector3.new(5,5,5)
            v.Character.Head.Transparency = 0.5
            v.Character.Head.CanCollide   = false
        end
    end
end)
