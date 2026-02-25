local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- DEINE DATENBANK (image_a819be.png)
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Auidy RF3 Limousine"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi V8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K5 e60"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi RF3"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Camarao"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Four Rex"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Peujo 400e6"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local IdentifiedCars = {} -- Hier speichern wir die entzifferten IDs

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! ID-DECODER",
   LoadingTitle = "Starte Dauer-Überwachung...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY AKTIVIEREN",
   CurrentValue = false,
   Callback = function(Value) AutoBuyActive = Value end,
})

for name, _ in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({
       Name = name,
       CurrentValue = false,
       Callback = function(v) SelectedForAutoBuy[name] = v end,
    })
end

-- FUNKTION: Die ID "knacken"
local function DecipherID(model)
    -- Wir suchen tief in allen Values (inkl. Cache-Ordner)
    for _, item in pairs(model:GetDescendants()) do
        if item:IsA("StringValue") and item.Value ~= "" then
            for carName, data in pairs(CarDatabase) do
                -- Wir prüfen, ob der Inhalt der Value einen Namen aus unserer Liste enthält
                if string.find(string.lower(item.Value), string.lower(carName)) then
                    return carName
                end
            end
        end
    end
    return nil
end

-- ESP FUNKTION (Billboard über dem Auto)
local function applyESP(model, name, color)
    if not model:FindFirstChild("DecodedTag") then
        local bbg = Instance.new("BillboardGui", model:FindFirstChild("Body") or model:FindFirstChild("DriveSeat") or model)
        bbg.Name = "DecodedTag"
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(0, 200, 0, 50)
        bbg.StudsOffset = Vector3.new(0, 4, 0)
        
        local label = Instance.new("TextLabel", bbg)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "★ " .. name .. " ★"
        label.TextColor3 = color
        label.TextSize = 18
        label.Font = Enum.Font.GothamBold

        local hl = Instance.new("Highlight", model)
        hl.FillColor = color
        hl.FillTransparency = 0.5
    end
end

-- DER DAUER-SCANNER (Optimiert auf Vehicles)
task.spawn(function()
    while true do
        local vFolder = workspace:FindFirstChild("Vehicles")
        if vFolder then
            for _, car in pairs(vFolder:GetChildren()) do
                if car:IsA("Model") and not IdentifiedCars[car] then
                    -- Versuch die ID zu entziffern
                    local realName = DecipherID(car)
                    
                    if realName then
                        IdentifiedCars[car] = realName
                        local data = CarDatabase[realName]
                        
                        -- Radar Button hinzufügen
                        RadarTab:CreateButton({
                           Name = "ENTZIFFERT: " .. realName,
                           Callback = function() 
                               game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = car:GetModelCFrame() + Vector3.new(0, 5, 0)
                           end,
                        })
                        
                        -- ESP anbringen
                        applyESP(car, realName, data.Color)
                        
                        -- Auto-Buy Logik
                        if AutoBuyActive and SelectedForAutoBuy[realName] then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = car:GetModelCFrame() + Vector3.new(0, 5, 0)
                        end
                    end
                end
            end
        end
        task.wait(1) -- Scannt jede Sekunde den Vehicles-Ordner (Lag-frei)
    end
end)
