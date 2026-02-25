local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- VOLLSTÄNDIGE DATENBANK
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Curgete"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Fia-Te 10026p"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Toyoda AFF67"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Auidy RF3 Limousine"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Lokswag Brasiuiu"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi V8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K5 e60"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Ratos Rotos Esporte"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi RF3"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Camarao"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Four Rex"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi V5"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis Z73"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K3 e92"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Lokswag Golo GT"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Toyoda Yapp"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K5 e39"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Four Traffic"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Merquis C203"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Toyoda Hellox"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Leskus not200"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["BNV K3"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Holde Ciwiq"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Audi V4"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Lokswag Passar"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
    ["Sacode Oitava"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! NO-LAG HUB",
   LoadingTitle = "Optimierter Koordination-Scan...",
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

-- ANTI-LAG SCANNER (Scant nur 1x pro Sekunde und nur Modelle)
task.spawn(function()
    while true do
        -- Wir prüfen nur Modelle im Workspace (keine Descendants!), das verhindert Lag
        for _, obj in pairs(workspace:GetChildren()) do
            -- Falls die Autos in einem speziellen Ordner liegen, bitte den Namen hier prüfen
            if obj:IsA("Model") and CarDatabase[obj.Name] then
                
                -- 1. ESP Highlight
                if not obj:FindFirstChild("EliteHighlight") then
                    local hl = Instance.new("Highlight", obj)
                    hl.Name = "EliteHighlight"
                    hl.OutlineColor = CarDatabase[obj.Name].Color
                    hl.FillTransparency = 1
                end

                -- 2. Radar Button
                if not TrackedObjects[obj] then
                    RadarTab:CreateButton({
                       Name = "ZU: " .. obj.Name .. " (" .. CarDatabase[obj.Name].Rarity .. ")",
                       Callback = function() 
                           local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                           if hrp then hrp.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0) end
                       end,
                    })
                    TrackedObjects[obj] = true
                end

                -- 3. Auto-Buy
                if AutoBuyActive and SelectedForAutoBuy[obj.Name] then
                    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0) end
                    task.wait(1)
                end
            end
            -- Kleiner Yield innerhalb der Schleife für maximale Performance
            if _ % 10 == 0 then task.wait() end 
        end
        task.wait(1.5) -- Haupt-Pause zwischen den Scans
    end
end)
