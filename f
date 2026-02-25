local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- DATENBANK (Basierend auf deinen Listen)
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Curgete"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Fia-Te 10026p"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Auidy RF3 Limousine"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi V8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K5 e60"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi RF3"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Camarao"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Four Rex"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["BNV K5 e39"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Four Traffic"] = {Rarity = "Ungewöhnlich", Color = Color3.fromRGB(0, 255, 0)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! Precision-Scanner",
   LoadingTitle = "Scanne Workspace.Vehicles...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({
   Name = "MASTER AUTO-BUY AKTIVIEREN",
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

-- Zentrale Erkennungs-Logik
local function GetCarRealName(model)
    local valuesFolder = model:FindFirstChild("Values")
    if valuesFolder then
        -- Oft heißt der Name im 'Values' Ordner "CarName" oder "VehicleName"
        -- Wir prüfen alle Kinder des Values-Ordners
        for _, val in pairs(valuesFolder:GetChildren()) do
            if val:IsA("StringValue") or val.Name == "Model" then
                return val.Value
            end
        end
    end
    return nil
end

local function ProcessVehicle(obj)
    if not obj:IsA("Model") then return end
    
    local realName = GetCarRealName(obj)
    if not realName then return end

    for dbName, data in pairs(CarDatabase) do
        if string.find(realName, dbName) then
            -- 1. Highlight (ESP)
            if not obj:FindFirstChild("EliteHighlight") then
                local hl = Instance.new("Highlight", obj)
                hl.Name = "EliteHighlight"
                hl.OutlineColor = data.Color
                hl.FillTransparency = 0.8
            end
            
            -- 2. Radar
            if not TrackedObjects[obj] then
                RadarTab:CreateButton({
                   Name = "ZU: " .. realName .. " [" .. data.Rarity .. "]",
                   Callback = function() 
                       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
                   end,
                })
                TrackedObjects[obj] = true
            end
            
            -- 3. Auto-Buy
            if AutoBuyActive and SelectedForAutoBuy[dbName] then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
            end
        end
    end
end

-- PRÄZISIONS-SCANNER (Nur im Vehicles Ordner)
local vehiclesFolder = workspace:FindFirstChild("Vehicles")

if vehiclesFolder then
    vehiclesFolder.ChildAdded:Connect(function(child)
        task.wait(0.2)
        ProcessVehicle(child)
    end)

    -- Initialer Check
    for _, child in pairs(vehiclesFolder:GetChildren()) do
        ProcessVehicle(child)
    end
else
    warn("Ordner 'Workspace.Vehicles' wurde nicht gefunden!")
end

Rayfield:Notify({
   Title = "Präzisions-Scan Aktiv",
   Content = "Suche gezielt in Workspace.Vehicles nach IDs.",
   Duration = 5,
})
