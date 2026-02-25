local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Datenbank (Namen müssen nur im Objektnamen VORKOMMEN)
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Curgete"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Four Traffic"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Lokswag Passar"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! Junkyard Scanner",
   LoadingTitle = "Suche im Schrottplatz...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY",
   CurrentValue = false,
   Callback = function(Value) AutoBuyActive = Value end,
})

-- Auswahl-Liste
for carName, data in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({
       Name = carName .. " (" .. data.Rarity .. ")",
       CurrentValue = false,
       Callback = function(Value) SelectedForAutoBuy[carName] = Value end,
    })
end

-- EFFIZIENTE SCAN-LOGIK
task.spawn(function()
    while task.wait(1) do -- 1 Sekunde Intervall ist der "Sweet Spot" gegen Lag
        -- Wir scannen ALLES, aber filtern sofort nach Modellen
        for _, obj in pairs(workspace:GetDescendants()) do 
            
            -- Prüfen, ob es ein Modell ist
            if obj:IsA("Model") then
                local foundData = nil
                
                -- Prüfen, ob der Name eines Autos aus unserer Liste im Modellnamen enthalten ist
                for dbName, data in pairs(CarDatabase) do
                    if string.find(obj.Name, dbName) then
                        foundData = data
                        break
                    end
                end

                if foundData then
                    -- 1. Highlighting
                    if not obj:FindFirstChild("EliteHighlight") then
                        local hl = Instance.new("Highlight", obj)
                        hl.Name = "EliteHighlight"
                        hl.OutlineColor = foundData.Color
                        hl.FillTransparency = 0.7
                    end

                    -- 2. Radar Button (Manuell)
                    if not TrackedObjects[obj] then
                        RadarTab:CreateButton({
                           Name = "ZU: " .. obj.Name,
                           Callback = function() 
                               game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0,5,0)
                           end,
                        })
                        TrackedObjects[obj] = true
                    end

                    -- 3. Auto-Buy Teleport (Nur falls ausgewählt)
                    for dbName, selected in pairs(SelectedForAutoBuy) do
                        if selected and string.find(obj.Name, dbName) and AutoBuyActive then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0,5,0)
                            task.wait(2)
                        end
                    end
                end
            end
        end
    end
end)
