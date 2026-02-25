local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- AKTUALISIERTE DATENBANK (Basierend auf image_a819be.png)
local CarDatabase = {
    ["BNV K3 F"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Skami Truk"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["BNV K8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Merquis SLX"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Chule Curgete"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Auidy RF3 Limousine"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Audi V8"] = {Rarity = "Episch", Color = Color3.fromRGB(255, 0, 255)},
    ["Peujo 400e6"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Vovo Sr60"] = {Rarity = "Selten", Color = Color3.fromRGB(0, 0, 255)},
    ["Lokswag Passar"] = {Rarity = "Häufig", Color = Color3.fromRGB(0, 255, 0)},
    ["Sacode Oitava"] = {Rarity = "Häufig", Color = Color3.fromRGB(0, 255, 0)},
}

local SelectedForAutoBuy = {}
local AutoBuyActive = false
local TrackedObjects = {}

local Window = Rayfield:CreateWindow({
   Name = "Fix It Up! FINAL SENSOR",
   LoadingTitle = "Deep-Cache Scan...",
})

local RadarTab = Window:CreateTab("Live-Radar", 4483362458)
local AutoBuyTab = Window:CreateTab("Auto-Buy", 4483362458)

AutoBuyTab:CreateToggle({Name = "MASTER AUTO-BUY AKTIVIEREN", CurrentValue = false, Callback = function(Value) AutoBuyActive = Value end})

for carName, _ in pairs(CarDatabase) do
    AutoBuyTab:CreateToggle({Name = carName, CurrentValue = false, Callback = function(Value) SelectedForAutoBuy[carName] = Value end})
end

-- DEEP-CACHE SUCHE
local function IdentifyVehicle(model)
    local values = model:FindFirstChild("Values")
    if not values then return nil end
    
    -- Wir suchen im 'Cache' Ordner oder direkt in den Values
    local searchAreas = {values, values:FindFirstChild("Cache")}
    
    for _, area in pairs(searchAreas) do
        if area then
            for _, item in pairs(area:GetChildren()) do
                if item:IsA("StringValue") then
                    -- Wir prüfen, ob der Text der StringValue in unserer Liste vorkommt
                    for carName, _ in pairs(CarDatabase) do
                        if string.find(item.Value, carName) or string.find(item.Name, carName) then
                            return carName
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function ProcessVehicle(obj)
    if not obj:IsA("Model") or TrackedObjects[obj] then return end
    
    local realName = IdentifyVehicle(obj)
    if realName then
        local data = CarDatabase[realName]
        
        -- ESP
        if not obj:FindFirstChild("EliteHighlight") then
            local hl = Instance.new("Highlight", obj)
            hl.Name = "EliteHighlight"
            hl.OutlineColor = data.Color
        end
        
        -- Radar
        RadarTab:CreateButton({
           Name = "GEFUNDEN: " .. realName .. " (" .. data.Rarity .. ")",
           Callback = function() 
               game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
           end,
        })
        TrackedObjects[obj] = true
        
        -- Auto-Buy
        if AutoBuyActive and SelectedForAutoBuy[realName] then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetModelCFrame() + Vector3.new(0, 5, 0)
        end
    end
end

-- AKTIVER SCANNER (Vehicles-Ordner)
local vFolder = workspace:FindFirstChild("Vehicles")
if vFolder then
    vFolder.ChildAdded:Connect(function(child)
        task.wait(1) -- Warten bis Cache geladen ist
        ProcessVehicle(child)
    end)
    for _, child in pairs(vFolder:GetChildren()) do ProcessVehicle(child) end
end
