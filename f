local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- DATENBANK
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Four Traffic"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Lokswag Passar"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! Spawn-Scanner",
   LoadingTitle = "Optimiere Koordinaten-Scan...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY",
   CurrentValue = false,
   Callback = function(Value) AutoBuyActive = Value end,
})

for carName, _ in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({
       Name = carName,
       CurrentValue = false,
       Callback = function(Value) SelectedForAutoBuy[carName] = Value end,
    })
end

-- NEUE LOGIK: Wir scannen nur Modelle in der Nähe der Spawnpoints
task.spawn(function()
    while task.wait(1) do
        -- Wir schauen in den Ordner, wo die Autos gespawnt werden. 
        -- Falls die Autos im Junkyard in einem speziellen Ordner liegen,
        -- ersetze 'workspace' durch 'workspace.Junkyard' oder ähnliches.
        local potentialCars = workspace:GetPartBoundsInBox(CFrame.new(0,0,0), Vector3.new(5000, 5000, 5000)) -- Großer Bereich um den Junkyard

        for _, part in pairs(potentialCars) do
            local obj = part.Parent
            if obj and obj:IsA("Model") and CarDatabase[obj.Name] then
                
                -- 1. Highlight
                if not obj:FindFirstChild("EliteHighlight") then
                    local hl = Instance.new("Highlight", obj)
                    hl.Name = "EliteHighlight"
                    hl.OutlineColor = CarDatabase[obj.Name].Color
                end

                -- 2. Radar Update (Manuell)
                if not TrackedObjects[obj] then
                    RadarTab:CreateButton({
                       Name = "ZU: " .. obj.Name,
                       Callback = function() 
                           game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0,5,0)
                       end,
                    })
                    TrackedObjects[obj] = true
                end

                -- 3. Auto-Buy
                if AutoBuyActive and SelectedForAutoBuy[obj.Name] then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0,5,0)
                    task.wait(1.5)
                end
            end
        end
    end
end)
